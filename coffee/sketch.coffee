PROG_VERSION = 293

# DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike 
LIMIT = 20 # meter. Under this value is no bearing given

platform = window.navigator.platform # Win32|iPad|Linux|iPhone

DIGITS = '0 1 2 3 4 5 6 7 8 9'.split ' '
BR = "\n"

# Högupplösta orienteringskartor: https://www.omaps.net

BEARINGLIST ='01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36'
DISTLIST = '2 4 6 8 10 12 14 16 18 20 30 40 50 60 70 80 90 100 120 140 160 180 200 300 400 500 600 700 800 900 1000 1200 1400 1600 1800 2000 3000 4000 5000 6000 7000 8000 9000 10000'

released = true
mapName = "" # t ex skarpnäck
params = null
voices = null
measure = {}
pois = null
speed = 1
distbc = 0

start = new Date()

state = 0 # 0=uninitialized 1=normal 2=info

data = null

img = null

b2w = null
w2b = null

startX = 0
startY = 0

menuButton = null

crossHair = null
lastTouchEnded = new Date() # to prevent double bounce in menus

distanceSounds = {}
bearingSounds = {}


fraction = (x) -> x - int x 
Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

general = {DISTANCE: true, TRAIL: true, SECTOR: 10, PANSPEED : true} # COINS: true,
#loadGeneral = -> if localStorage.gpsKarta then general = _.extend general, JSON.parse localStorage.gpsKarta
#saveGeneral = -> localStorage.gpsKarta = JSON.stringify general

class Storage
	constructor : (@mapName) ->
		key = 'gpsKarta' + @mapName
		# if localStorage[key]
		# 	try
		# 		obj = JSON.parse localStorage[key]
		# 		@controls = obj.controls
		# 		@trail = obj.trail
		@clear()

	save : -> localStorage['gpsKarta' + @mapName] = JSON.stringify @

	clear : ->
		@controls = data.controls
		@trail = []
		@init()
		crossHair = null
		@save()

	init : ->
		for key,control of @controls
			[x,y,littera] = control
			[lon,lat] = b2w.convert x,y
			control[2] = ""
			control[3] = lat
			control[4] = lon

	deleteControl : ->
		[pLon,pLat] = b2w.convert cx,cy
		b = LatLon pLat,pLon
		for key,control of @controls
			[z,z,z,qLat,qLon] = control
			c = LatLon qLat,qLon
			dbc = b.distanceTo(c) 
			if dbc < data.radius and key not in "ABC" then delete @controls[key]
		@save()

storage = null

class Dump
	constructor : ->
		@data = []
		@active = false
	store : (msg) ->
		if @active
			console.log msg
			@data.push msg
	get : ->
		result = @data.join BR
		@data = []
		result + BR
dump = new Dump()

[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

gps = null
TRACKED = 5 # circles shows the user position
position = null # gps position [x,y] # [lon,lat,alt,hhmmss]
track = [] # five latest GPS positions (bitmap coordinates)

speaker = null

messages = ['','','','','','']
errors = []
gpsCount = 0

[gpsLat,gpsLon] = [0,0] # avgör om muntlig information ska ges

timeout = null

voiceQueue = []

bearingSaid = '' # förhindrar upprepning
distanceSaid = '' # förhindrar upprepning

locationId = 0

p1 = new LatLon 52.205, 0.119
p2 = new LatLon 48.857, 2.351
assert 404279.1639886792, p1.distanceTo p2  #  m
p1 = new LatLon 59.0, 18.0
p2 = new LatLon 59.0, 18.00001
assert 0.5726962096664346, p1.distanceTo p2  #  m
p2 = new LatLon 59.00001, 18.0
assert 1.1119492665983002, p1.distanceTo p2  #  m
# fem decimaler blir bra 

sendMail = (subject,body) ->
	mail.href = "mailto:" + data.mail + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body) # encodeURI 
	console.log mail.href
	mail.click()

sayBear = (m) -> # m är en bäring i BEARINGLIST
	console.log "sayBear #{m}"
	dump.store ""
	dump.store "sayBearing #{m} #{JSON.stringify voiceQueue}"
	bearingSounds[m].play()

sayDist = (m) -> # m är en distans i DISTLIST
	console.log "sayDist #{m}"
	dump.store ""
	dump.store "sayDistance #{m} #{JSON.stringify voiceQueue}"
	distanceSounds[m].play()

sayDistance = (a,b) -> # a is newer (meter)
	# if a border is crossed, produce a distance
	dump.store "D #{round a,1} #{round b,1}"
	a = round a
	b = round b
	if b == -1 then return a
	for d in DISTLIST.split ' '
		d = parseInt d
		if a == d and b != d then return d
		if (a-d) * (b-d) < 0 then return d
	""

sayBearing = (a0,b0) -> # a is newer (degrees)
	dump.store "B #{round a0,1} #{round b0,1}"
	# if a sector limit is crossed, tell the new bearing
	a = general.SECTOR * round(a0/general.SECTOR)
	b = general.SECTOR * round(b0/general.SECTOR)
	if a == b and b0 != -1 then return "" # samma sektor
	a = round a / 10 
	if a == 0 then a = 36 # 01..36
	str(DIGITS[a // 10]) + str(DIGITS[a %% 10])

increaseQueue = (p) ->
	# errors.push "increaseQueue #{round p.coords.latitude,6} #{round p.coords.longitude,6}"

	if crossHair == null then return
	#errors.push "incQA #{crossHair}"

	[trgLon,trgLat] = b2w.convert crossHair[0],crossHair[1]
	#errors.push "incQB #{round trgLon,6} #{round trgLat,6}"
	#errors.push "incQC #{round p.coords.longitude,6} #{round p.coords.latitude,6}"

	a = LatLon p.coords.latitude, p.coords.longitude # newest
	#errors.push "a #{a}" VISAS EJ!
	b = LatLon gpsLat, gpsLon
	#errors.push "b #{b}"
	c = LatLon trgLat, trgLon # target
	#errors.push "c #{c}"

	distac = a.distanceTo c # meters
	distbc = b.distanceTo c
	distance = (distac - distbc)/DIST
	#errors.push "distac #{distac}"
	#errors.push "distbc #{distbc}"
	#errors.push "distance #{distance}"

	bearingac = a.bearingTo c
	bearingbc = b.bearingTo c
	sBearing = if distac >= LIMIT then sayBearing bearingac,bearingbc else ""
	if sBearing  != "" then voiceQueue.push "bearing #{sBearing}"

	# sDistance = sayDistance distac,distbc
	# if sDistance != "" then voiceQueue.push "distance #{sDistance}" Vi kan inte säga godtyckligt avstånd numera

	#for voice in voiceQueue
	#	errors.push "vQ #{voice}"

	if abs(distance) >= 0.5 # update only if DIST detected. Otherwise some beeps will be lost.
		gpsLat = round p.coords.latitude,6
		gpsLon = round p.coords.longitude,6

firstInfo = ->
	[x,y] = crossHair
	[lon,lat] = b2w.convert x,y

	#errors.push "firstInfo #{round(x)} #{round(y)}"
	#errors.push "lon #{lon} lat #{lat}"
	#errors.push "gps #{gpsLon} #{gpsLat}"

	b = LatLon gpsLat, gpsLon # senaste position
	c = LatLon lat, lon # target

	distb = round b.distanceTo c
	distance = round (distb)/DIST

	bearingb = b.bearingTo c
	voiceQueue.push "bearing #{sayBearing bearingb,-1}"
	voiceQueue.push "distance #{sayDistance distb,-1}"

	#increaseQueue {coords: {latitude:gpsLat, longitude:gpsLon}}

	dump.store ""
	dump.store "target #{crossHair}"
	dump.store "gps #{[gpsLat,gpsLon]}"
	dump.store "trg #{[lat,lon]}"
	dump.store "voiceQueue #{voiceQueue}"

	# if distance < LIMIT then soundQueue = distance else soundQueue = 0 ett antal DIST

decreaseQueue = ->
	if voiceQueue.length == 0 then return
	msg = voiceQueue.shift()
	arr = msg.split ' '
	dump.store "decreaseQueue #{msg}"
	#errors.push "decreaseQueue #{msg}"
	if arr[0] == 'bearing'
		bearing = arr[1]
		if bearingSaid != bearing then sayBear bearing
		bearingSaid = bearing
	else if arr[0] == 'distance'
		#errors.push general.DISTANCE
		if general.DISTANCE or arr[1] < LIMIT
			distance = arr[1]
			#errors.push "#{distanceSaid} #{distance}" 
			if distanceSaid != distance then sayDist distance
			distanceSaid = distance

locationUpdate = (p) ->
	reason = 0
	try
		pLat = round p.coords.latitude,6
		pLon = round p.coords.longitude,6
		if storage.trail.length == 0
			gpsLat = pLat
			gpsLon = pLon
		messages[5] = gpsCount++
		decreaseQueue()
		reason = 1
		increaseQueue p # meters
		reason = 2
		uppdatera pLat, pLon
		reason = 3
	catch error
		errors.push "locationUpdate #{error} #{reason}"

uppdatera = (pLat, pLon) ->
	[x,y] = w2b.convert pLon,pLat
	dump.store "uppdatera #{pLon} #{pLat} #{x} #{y}"
	updateTrack pLat, pLon, x,y
	updateTrail pLat, pLon, x,y

updateTrack = (pLat, pLon, x,y) -> # senaste fem positionerna
	track.push [x,y]
	if track.length > TRACKED then track.shift()
	t = _.last track
	dump.store "T #{t[0]} #{t[1]}"
	messages[TRACKED-1] = pLat + ' ' + pLon

updateTrail = (pLat, pLon, x,y)->
	position = [x,y]
	if storage.trail.length == 0
		storage.trail.push position
		return
	[qx, qy] = _.last storage.trail
	[qLon,qLat] = b2w.convert qx,qy
	a = LatLon pLat, pLon # newest
	b = LatLon qLat, qLon # last
	dist = a.distanceTo b # meters
	if dist > 5
		dump.store "updateTrail #{dist} #{x} #{y}"
		storage.trail.push position

locationUpdateFail = (error) ->	errors.push 'locationUpdateFail #{error.code}'

initSounds = ->

	bearingSounds = {}
	for bearing in BEARINGLIST.split ' '
		sound = loadSound "sounds/bearing/male/#{bearing}.mp3"
		if sound then console.log "sounds/bearing/male/#{bearing}.mp3"
		sound.setVolume 0.5
		bearingSounds[bearing] = sound

	distanceSounds = {}
	for distance in DISTLIST.split ' '
		sound = loadSound "sounds/distance/female/#{distance}.mp3"
		if sound then console.log "sounds/distance/female/#{distance}.mp3"
		sound.setVolume 0.5
		distanceSounds[distance] = sound

getMeters = (w,skala) ->
	[lon0,lat0] = b2w.convert 0,height
	[lon1,lat1] = b2w.convert w,height
	p0 = LatLon lat0, lon0
	p1 = LatLon lat1, lon1
	distans = p0.distanceTo(p1) / skala
	d = Math.log10 distans
	fract = fraction d
	for i in [1,2,5]
		if 10**fract > i then n = i
	[round(distans), n * 10**int d]


preload = ->

	initSounds()

	params = getParameters()
	mapName = params.map || "2023-SommarS"
	if params.debug then dump.active = params.debug == '1'
	loadJSON "data/poi.json", (json) -> pois = json
	loadJSON "data/#{mapName}.json", (json) ->
		data = json
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map


setup = ->

	try

		#console.log "PI #{round Math.PI,6}"
		#console.log "setup starts"

		dialogues.clear()
		track = []

		canvas = createCanvas innerWidth, innerHeight
		canvas.position 0,0 # hides text field used for clipboard copy.

		#loadGeneral()

		angleMode DEGREES
		SCALE = data.scale

		dcs = data.controls
		bmp = [dcs.A[0], dcs.A[1], dcs.B[0], dcs.B[1], dcs.C[0], dcs.C[1]]
		abc = data.ABC
		wgs = [abc[1],abc[0],abc[3],abc[2],abc[5],abc[4]] # lat lon <=> lon lat

		b2w = new Converter bmp,wgs,6
		w2b = new Converter wgs,bmp,0

		storage = new Storage mapName
		storage.trail = []
		if params.trail then storage.trail = decodeAll params.trail

		[cx,cy] = [img.width/2,img.height/2]

		options = {
			enableHighAccuracy: false,
			timeout: 5000,
			maximumAge: 0,
		}

		locationId = navigator.geolocation.watchPosition locationUpdate, locationUpdateFail, options
			# enableHighAccuracy: true
			# maximumAge: 30000
			# timeout: 27000

		errors.push "watchPosition locationId = #{locationId}"

		menuButton = new MenuButton width-160
		#throw "myerror"

	catch error
		errors.push "setup failed: #{error}"

info = () ->
	if position
		[x,y] = position
	else
		[x,y] = [cx,cy]
	[lon,lat] = b2w.convert x,y

	if crossHair
		[trgLon,trgLat] = b2w.convert crossHair[0],crossHair[1]
	else
		[trgLon,trgLat] = b2w.convert cx,cy

	[
		"Map: #{mapName}"
		"Program Version: #{PROG_VERSION}"
		"GpsPosition: #{messages[4]}"
		"  GpsPoints: #{gpsCount}"
		"Target: #{trgLat} #{trgLon}"
		"  Bearing: #{messages[1]}"
		"  Distance: #{messages[2]}"
		"Setup"
		"  PanSpeed: #{general.PANSPEED}"
		"  Sector: #{general.SECTOR}"
		"  Hear Distance: #{general.DISTANCE}"
		"  See Trail: #{general.TRAIL}"
		"TrailPoints: #{storage.trail.length}"
		"Scale: #{SCALE}"
		"Dump: #{dump.data.length}"
		"Platform: #{platform}"
	]

drawCrossHair = (x,y) ->
	r = 0.9 * data.radius
	if crossHair
		sw 1
		sc 1,1,1,0.5
		fc 1,0,0,0.5
	else
		sw 1
		sc 1,0,0
		fc 0,0,0,0.25
		r *= SCALE
	circle x,y,r
	line x,y-r,x,y+r
	line x-r,y,x+r,y

drawInfo = ->
	textAlign LEFT,CENTER
	sc()
	fc 0
	for m,i in info()
		text m,20,(i+0.5) * height / info().length

drawTrack = ->
	fc()
	sw 2/SCALE
	sc 0
	for [x,y],i in track
		dump.store "drawTrack #{i} #{track.length} #{x} #{y} #{cx} #{cy} #{x-cx} #{y-cy}"
		circle x-cx, y-cy, 5 * (track.length-i)

drawTrail = ->
	if not general.TRAIL then return
	textSize 20/SCALE
	sw 1/SCALE
	if storage.trail.length < 1 then return
	[x0,y0] = storage.trail[0]
	for [x,y] in storage.trail
		index = 0
		if x < x0 then index += 1
		if y > y0 then index += 2
		fill '#0ff #0f0 #f00 #ff0'.split(' ')[index]
		[x0,y0] = [x,y]
		sc 0
		circle x-cx, y-cy, 2
		if SCALE > 10
			fc 0
			sc()
			text x,x-cx, y-cy-1
			text y,x-cx, y-cy+1

drawControls = ->
	sw 2
	for key,control of storage.controls
		if control == null then continue
		[x,y,littera] = control

		r = data.radius

		if key in 'ABC' # Half Size
			stroke "#0f08"
			fill "#ff08"
			circle x-cx, y-cy, r/2
			sc()
			fc 0
			textSize r*0.75
			textAlign CENTER,CENTER
			text key, x-cx, y-cy
		else # Full Size
			if littera == ''
				stroke 0
				fc()
				circle x-cx, y-cy, r
				sc()
				fc 0
				textSize 1.5*data.radius
				textAlign CENTER,CENTER
				text key, x-cx, y-cy
			else
				sc()
				fc 0
				textSize 1.5*data.radius
				textAlign CENTER,CENTER
				text littera, x-cx, y-cy

		stroke 0
		point x-cx, y-cy

drawControl = ->
	if gpsLat == 0 or gpsLon == 0
		messages[0] = ""
		messages[1] = ""
		messages[2] = ""
		return
	if crossHair
		[trgLon,trgLat] = b2w.convert crossHair[0],crossHair[1]
	else
		[trgLon,trgLat] = b2w.convert cx,cy
	latLon2 = LatLon trgLat,trgLon
	latLon1 = LatLon gpsLat,gpsLon
	bearing = latLon1.bearingTo latLon2
	messages[0] = ""
	messages[1] = "#{int bearing}º"
	messages[2] = "#{round(latLon1.distanceTo latLon2)} m"

drawRuler = ->
	[w1,w0] = getMeters width, SCALE
	d = (w1-w0)/2/w1 * width
	x = d
	y = height * 0.9
	w = w0/w1 * width
	h = height * 0.03
	sc 0
	sw 1
	fc()
	rect x,y,w,h
	textSize height/30
	textAlign CENTER,CENTER
	sc()
	fc 0
	text w0+"m",width/2,y+h*0.6

drawPois = ->
	for key,poi of pois
		[lat,lon] = poi
		[x,y] = w2b.convert lon,lat
		sw 1
		stroke "#ff0"
		fill "#000"
		textSize 0.25 * data.radius
		textAlign CENTER,CENTER
		text key, x-cx, y-cy

draw = ->
	bg 0,1,0
	if state == 0 
		textSize 100
		textAlign CENTER,CENTER
		x = width/2
		y = height/2 
		text mapName, x,y-100
		text 'Version: '+PROG_VERSION, x,y
		if dump.active then text 'debug',x,y+100
		text "Click to continue!", x,y+200
		return

	if state == 1
		push()
		translate round(width/2), round(height/2)
		scale SCALE

		image img, round(-cx), round(-cy)
		drawTrail()
		drawTrack()

		if data.drawControls then drawControls()
		drawControl()
		if crossHair then drawCrossHair crossHair[0]-cx, crossHair[1]-cy # detached
		drawPois()
		pop()
		if not crossHair then drawCrossHair width/2,height/2 # attached
		fc 0
		sc 1,1,0
		sw 3
		margin = 25
		for message,i in messages
			textAlign [LEFT,CENTER,RIGHT][i%3], [TOP,BOTTOM][i//3]
			textSize [100,50][i//3]
			text message, [margin,width/2,width-margin][i%3], [margin,height][i//3] 
		drawRuler()

		showDialogue()
		menuButton.draw()
		#messages[3] = round frameRate()
		push()
		textAlign LEFT
		for i in range errors.length
			text errors[i], 10, 50 + 50*i
		pop()
		return

	if state == 2
		drawInfo()
		return

setTarget = ->
	firstInfo()
	storage.save()
	dialogues.clear()

executeMail = ->
	pairs = ("[#{x},#{y}]" for [x,y] in storage.trail).join ',' + BR
	link = "https://christernilsson.github.io/gpsKarta/index.html?map=" + mapName + "&trail=" + encodeAll storage.trail
	r = info().join BR
	t = ("#{key} #{x} #{y} #{littera} #{lat} #{lon}" for key,[x,y,littera,lat, lon] of storage.controls).join BR
	sendMail "#{mapName}", link + BR+BR + r + BR+BR + t + BR+BR + dump.get() + pairs
	storage.clear()

findKey = ->
	for key in 'DEFGHIJKLMNOPQRSTUVWXYZ'
		if key not of storage.controls then return key
	false

savePosition = ->
	[x,y] = w2b.convert gpsLon,gpsLat
	key = findKey()
	storage.controls[key] = [x,y,'',gpsLat,gpsLon]
	storage.save()
	voiceQueue.push "saved #{key}"
	dialogues.clear()

aim = ->
	if crossHair == null
		crossHair = [round(cx),round(cy)]
		setTarget()
	else
		crossHair = null
	dialogues.clear()

menu1 = -> # Main Menu
	dialogue = new Dialogue()
	dialogue.add 'Center', ->
		[cx,cy] = position
		dump.store 'Center #{cx} #{cy} #{position.coord.} #{}'
		dialogues.clear()
	dialogue.add 'Out', -> SCALE /= 1.5
		#if SCALE > data.scale then SCALE /= 1.5
		#dialogues.clear()
	dialogue.add 'Take...', -> menu4()
	dialogue.add 'More...', -> menu6()
	dialogue.add 'Setup...', -> menu2()
	dialogue.add 'Aim', -> aim()
	dialogue.add 'Save', -> savePosition()
	dialogue.add 'In', -> SCALE *= 1.5
		#dialogues.clear()
	dialogue.clock ' ',true
	dialogue.textSize *= 1.5

menu2 = -> # Setup
	dialogue = new Dialogue()
	dialogue.add 'PanSpeed', ->
		general.PANSPEED = not general.PANSPEED
		#saveGeneral()
		dialogues.clear()
	dialogue.add 'Distance', ->
		general.DISTANCE = not general.DISTANCE
		#saveGeneral()
		dialogues.clear()
	dialogue.add 'Trail', ->
		general.TRAIL = not general.TRAIL
		#saveGeneral()
		dialogues.clear()
	dialogue.add 'Sector...', -> menu3()
	dialogue.clock()
	dialogue.textSize *= 1.5

menu3 = -> # Sector
	dialogue = new Dialogue()
	dialogue.add '10', -> SetSector 10 # 36
	dialogue.add '20', -> SetSector 20 # 18
	dialogue.add '30', -> SetSector 30 # 12
	dialogue.add '45', -> SetSector 45 # 8
	dialogue.add '60', -> SetSector 60 # 6
	dialogue.add '90', -> SetSector 90 # 4
	dialogue.clock()

menu4 = -> # Take
	dialogue = new Dialogue()
	dialogue.add 'ABCDE', -> menu5 'ABCDE'
	dialogue.add 'KLMNO', -> menu5 'KLMNO'
	dialogue.add 'UVWXYZ', -> menu5 'UVWXYZ'
	dialogue.add 'Clear', -> update ' '
	dialogue.add 'PQRST', -> menu5 'PQRST'
	dialogue.add 'FGHIJ', -> menu5 'FGHIJ'
	dialogue.clock()

menu5 = (letters) -> # ABCDE
	dialogue = new Dialogue()
	for letter in letters
		dialogue.add letter, -> update @title
	dialogue.clock()

menu6 = -> # More
	dialogue = new Dialogue()

	dialogue.add 'Exit', ->
		navigator.geolocation.clearWatch locationId
		locationId = 0
		dialogues.clear()

	# dialogue.add 'Talk', ->
	# 	console.log 'talk'
	# 	decreaseQueue()
	# 	dialogues.clear()

	dialogue.add 'Mail...', ->
		executeMail()
		dialogues.clear()
	dialogue.add 'Delete', ->
		storage.deleteControl()
		dialogues.clear()
	dialogue.add 'Clear', ->
		storage.clear()
		dialogues.clear()
	dialogue.add 'Info...', ->
		state = 2
		dialogues.clear()
	dialogue.clock()
	dialogue.textSize *= 1.5

SetSector = (sector) ->
	general.SECTOR = sector
	#saveGeneral()
	dialogues.clear()

update = (littera) ->
	key = findKey()
	[x,y] = crossHair
	[lon,lat] = b2w.convert x,y
	storage.controls[key] = [x,y,littera,lat,lon]
	storage.save()
	crossHair = null
	dialogues.clear()
	#executeMail()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

touchStarted = (event) ->
	lastTouchStarted = new Date()
	event.preventDefault()
	if not released then return
	speed = 1
	if general.PANSPEED then speed = 0.1 + 0.9 * dist(mouseX,mouseY,width/2,height/2) / dist(0,0,width/2,height/2)
	dump.store "touchStarted #{(new Date())-start} #{JSON.stringify touches}"
	released = false
	startX = mouseX
	startY = mouseY
	false

touchMoved = (event) ->
	dump.store "touchMoved #{(new Date())-start} #{JSON.stringify touches}"
	event.preventDefault()
	if dialogues.length == 0 and state == 1
		cx += speed * (startX - mouseX)/SCALE
		cy += speed * (startY - mouseY)/SCALE
		startX = mouseX
		startY = mouseY
	false

touchEnded = (event) ->
	#console.log 'touchEnded',released,state
	event.preventDefault()
	console.log 'touchEnded',cx,cy
	if (new Date()) - lastTouchEnded < 500
		lastTouchEnded = new Date()
		return # to prevent double bounce
	if released then return
	dump.store "touchEnded #{(new Date())-start} #{JSON.stringify touches}"
	released = true
	#if state == 0 then initSounds()
	if state == 2 then dialogues.clear()
	if state in [0,2]
		state = 1
		return false
	if menuButton.inside mouseX,mouseY
		menuButton.click()
		return false
	if dialogues.length > 0
		dialogue = _.last dialogues
		#if not dialogue.execute mouseX,mouseY then dialogues.pop()
		dialogue.execute mouseX,mouseY # then dialogues.pop()
	false

keyPressed = -> # Används för att avläsa ABC bitmapskoordinater

	if key == ' '
		x = round cx + (mouseX - width/2) / SCALE  	# image koordinater
		y = round cy + (mouseY - height/2) / SCALE

		# [lon,lat] = b2w.convert x,y
		# p = {coords:{longitude:lon,latitude:lat}}
		# console.log 'keyPressed',x,y,p
		# increaseQueue p # meters
		#decreaseQueue()

		letter = "ABC"[_.size measure]
		measure[letter] = [x,y]
		if letter == 'C' then console.log '"controls": ' + JSON.stringify measure