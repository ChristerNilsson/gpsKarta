VERSION = 144
DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this value is no bearing given.
SECTOR = 10 # Bearing resolution in degrees
DIGITS = 'zero one two three four five six seven eight niner'.split ' '
BR = '<br>'

# http://www.bvsok.se/Kartor/Skolkartor/
# Högupplösta orienteringskartor: https://www.omaps.net
# https://omaps.blob.core.windows.net/map-excerpts/1fdc587ffdea489dbd69e29b10b48395.jpeg Nackareservatet utan kontroller.

DISTLIST = [0,2,4,6,8,10,12,14,16,18,20,30,40,50,60,70,80,90,100, 120,140,160,180,200,250,300,350,400,450,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

mapName = "" # t ex skarpnäck
params = null
voices = null

state = 0 # 0=uninitialized 1=normal 2=info

data = null

img = null

b2w = null
w2b = null

startX = 0
startY = 0

menuButton = null

currentControl = null

class Storage 
	constructor : (@mapName) ->
		key = 'gpsKarta' + @mapName
		if localStorage[key]
			try
				obj = JSON.parse localStorage[key]
				@controls = obj.controls
				@trail = obj.trail
				#@tickSound = obj.tickSound
		@clear()

	save : -> localStorage['gpsKarta' + @mapName] = JSON.stringify @

	clear : ->
		@controls = data.controls
		@trail = []
		@init()
		[trgLat,trgLon] = [0,0]
		currentControl = null
		@save()

	init : ->
		for key,control of @controls
			[x,y,littera] = control
			[lon,lat] = b2w.convert x,y
			control[2] = ""
			control[3] = lat
			control[4] = lon
			if currentControl != null
				[z99,z99,z99,trgLat,trgLon] = @controls[currentControl]

	deleteControl : ->
		if ':' in currentControl
			delete @controls[currentControl]
			@save()
			currentControl = null
		else
			voiceQueue.push "computer says no"

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
		result + BR + BR
dump = new Dump()

platform = null

[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

gps = null
TRACKED = 5 # circles shows the user position
position = null # gps position [lon,lat,alt,hhmmss]
track = [] # five latest GPS positions (bitmap coordinates)

speaker = null

soundUp = null
soundDown = null
soundQueue = 0 # neg=minskat avstånd pos=ökat avstånd

messages = ['','','','','','']
gpsCount = 0

[gpsLat,gpsLon] = [0,0] # avgör om muntlig information ska ges
[trgLat,trgLon] = [0,0] # koordinater för vald target

#lastLocation = '' # används för att skippa lika koordinater

timeout = null

voiceQueue = []
bearingSaid = '' # förhindrar upprepning
distanceSaid = '' # förhindrar upprepning

sendMail = (subject,body) ->
	mail.href = encodeURI "mailto:#{data.mail}?subject=#{subject}&body=#{body}"
	#console.log mail.href
	mail.click()

say = (m) ->
	if speaker == null then return
	speechSynthesis.cancel()
	speaker.text = m
	dump.store ""
	dump.store "say #{m} #{JSON.stringify voiceQueue}"
	speechSynthesis.speak speaker

preload = ->
	params = getParameters()
	if params.debug then dump.active = params.debug == '1'
	mapName = params.map || 'skarpnäck'
	loadJSON "data/#{mapName}.json", (json) ->
		data = json
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map

sayDistance = (a,b) -> # a is newer (meter)
	# if a border is crossed, produce speech
	dump.store "D #{myRound a,1} #{myRound b,1}"
	a = round a
	b = round b
	if b == -1 then return a
	for d in DISTLIST
		if a == d and b != d then return d
		if (a-d) * (b-d) < 0 then return d
	""

sayBearing = (a0,b0) -> # a is newer (degrees)
	dump.store "B #{myRound a0,1} #{myRound b0,1}"
	# if a sector limit is crossed, tell the new bearing
	a = SECTOR * round(a0/SECTOR)
	b = SECTOR * round(b0/SECTOR)
	if a == b and b0 != -1 then return "" # samma sektor
	a = round a / 10 
	if a == 0 then a = 36 # 01..36
	tiotal = DIGITS[a // 10]
	ental = DIGITS[a %% 10]
	"#{tiotal} #{ental}"

increaseQueue = (p) ->
	dump.store "increaseQueue #{p.coords.latitude} #{p.coords.longitude}"

	if currentControl == null then return 

	a = LatLon p.coords.latitude,p.coords.longitude # newest
	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	dista = a.distanceTo c # meters
	distb = b.distanceTo c
	distance = (dista - distb)/DIST

	if trgLat != 0
		bearinga = a.bearingTo c
		bearingb = b.bearingTo c
		if dista >= LIMIT
			sBearing = sayBearing bearinga,bearingb
			if sBearing != "" then voiceQueue.push "bearing #{sBearing}"
		sDistance = sayDistance dista,distb
		if sDistance != "" then voiceQueue.push "distance #{sDistance}"

	if abs(distance) >= 0.5 # update only if DIST detected. Otherwise some beeps will be lost.
		gpsLat = myRound p.coords.latitude,6
		gpsLon = myRound p.coords.longitude,6

	if abs(distance) <= 10
		soundQueue = round distance 
	else if distance < -10 then soundQueue = -10
	else if distance > 10 then soundQueue = 10

firstInfo = (key) ->
	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	distb = round b.distanceTo c
	distance = round (distb)/DIST

	bearingb = b.bearingTo c
	voiceQueue.push "target #{key} #{sayBearing bearingb,-1} #{sayDistance distb,-1}"
	dump.store ""
	dump.store "target #{currentControl}"
	dump.store "gps #{[gpsLat,gpsLon]}"
	dump.store "trg #{[trgLat,trgLon]}"
	dump.store "voiceQueue #{voiceQueue}"
	
	if abs(distance) < 10 then soundQueue = distance # ett antal DIST

playSound = ->
	if soundQueue == 0 then return
	dump.store "playSound #{soundQueue}"
	#if not storage.tickSound then return
	if soundQueue < 0 and soundDown != null
		soundQueue++
		soundDown.play()
	else if soundQueue > 0 and soundUp != null
		soundQueue--
		soundUp.play()

decreaseQueue = ->
	if voiceQueue.length == 0 then return
	msg = voiceQueue.shift()
	arr = msg.split ' ' 

	if arr[0] == 'bearing'
		msg = arr[1] + ' ' + arr[2] # skippa ordet. t ex 'bäring etta tvåa'
		if bearingSaid != msg then say msg
		bearingSaid = msg
	else if arr[0] == 'distance'
		msg = arr[1]                # skippa ordet. t ex 'distans 30'
		if distanceSaid != msg then say msg
		distanceSaid = msg
	else if arr[0] == 'target'
		bearingSaid = arr[2] + ' ' + arr[3]
		distanceSaid = arr[4]
		msg = "#{arr[0]} #{arr[1]}. bearing #{bearingSaid}. distance #{distanceSaid} meters"
		# Example: 'target 11. bearing zero niner. distance 250 meters'
		say msg
	else if arr[0] == 'saved'
		say msg.replace ':',' and '

locationUpdate = (p) ->
	pLat = myRound p.coords.latitude,6
	pLon = myRound p.coords.longitude,6
	altitude = int p.coords.altitude
	if storage.trail.length == 0
		gpsLat = pLat
		gpsLon = pLon
	messages[5] = gpsCount++
	decreaseQueue()
	increaseQueue p # meters
	uppdatera pLat, pLon, altitude, p.timestamp

uppdatera = (pLat, pLon, altitude, timestamp) -> # senaste fem positionerna
	date = new Date()
	date.setTime timestamp
	h = addZero date.getHours()
	M = addZero date.getMinutes()
	s = addZero date.getSeconds()
	hms = "#{h}:#{M}:#{s}"

	dump.store ""
	dump.store "LU #{hms} #{pLat} #{pLon}"
	position = [pLon,pLat,altitude,hms] 

	updateTrack pLat, pLon, altitude
	updateTrail pLat, pLon, position

updateTrack = (pLat, pLon, altitude) ->
	track.push w2b.convert pLon,pLat
	if track.length > TRACKED then track.shift()
	t = _.last track
	dump.store "T #{t[0]} #{t[1]}"
	if altitude then messages[3] = altitude
	messages[4] = pLat + ' ' + pLon

updateTrail = (pLat, pLon, position)->
	if storage.trail.length == 0 
		storage.trail.push position
		return
	[qLon, qLat] = _.last storage.trail
	a = LatLon pLat, pLon # newest
	b = LatLon qLat, qLon # last
	c = LatLon trgLat, trgLon # target

	dista = a.distanceTo c # meters
	distb = b.distanceTo c
	distance = (dista - distb)/DIST
	dump.store "updateTrail #{dista} #{distb}"

	if distance > 5 then storage.trail.push position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['','','','','','Check location permissions']
window.speechSynthesis.onvoiceschanged = -> voices = window.speechSynthesis.getVoices()

initSpeaker = ->
	#dump.store "initSpeaker in #{index}"
	index = int getParameters().speaker || 5
	speaker = new SpeechSynthesisUtterance()
	speaker.voiceURI = "native"
	speaker.volume = 1
	speaker.rate = 1.0
	speaker.pitch = 0
	speaker.text = '' 
	speaker.lang = 'en-GB'
	if voices and index <= voices.length-1 then speaker.voice = voices[index]

	soundUp = loadSound 'soundUp.wav'
	soundDown = loadSound 'soundDown.wav'
	soundUp.setVolume 0.1
	soundDown.setVolume 0.1
	clearInterval timeout
	timeout = setInterval playSound, DELAY
	soundQueue = 0

	dialogues.clear()
	say "Welcome!"
	track = []
	dump.store "initSpeaker out"

fraction = (x) -> x - int x 
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

# myTest = ->
# 	getMeters 1920,1 # Smäller här
# 	getMeters 1920,1.5 # eller här. Android
# 	getMeters 1920,1.5*1.5
# 	getMeters 1920,1.5*1.5*1.5
	# assert [1434,1000], getMeters 1920,1 # Smäller här
	# assert [956,500], getMeters 1920,1.5 # eller här. Android
	# assert [638,500], getMeters 1920,1.5*1.5
	# assert [425,200], getMeters 1920,1.5*1.5*1.5
	#console.log "Ready!"

setup = ->
	canvas = createCanvas innerWidth-0.0, innerHeight #-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	platform = window.navigator.platform
	angleMode DEGREES
	SCALE = data.scale

	dcs = data.controls
	bmp = [dcs.A[0], dcs.A[1], dcs.B[0], dcs.B[1], dcs.C[0], dcs.C[1]]
	abc = data.ABC
	wgs = [abc[1],abc[0],abc[3],abc[2],abc[5],abc[4]] # lat lon <=> lon lat

	b2w = new Converter bmp,wgs,6
	w2b = new Converter wgs,bmp,0

	# myTest() Do not execute! Very dependent on .json file.

	storage = new Storage mapName
	
	[cx,cy] = [img.width/2,img.height/2]

	navigator.geolocation.watchPosition locationUpdate, locationUpdateFail,
		enableHighAccuracy: true
		maximumAge: 30000
		timeout: 27000

	menuButton = new MenuButton width-160

	addEventListener 'touchstart', (evt) ->
		touches = evt.changedTouches
		touch = touches[touches.length-1]
		mx = touch.pageX
		my = touch.pageY
		myMousePressed mx,my

info = () ->
	result = []
	result.push "MAP: #{mapName}"
	result.push "VERSION: #{VERSION}"
	result.push "dump.active: #{dump.active}"  
	result.push "dump.data.length: #{dump.data.length}"
	result.push "trail.length: #{storage.trail.length}"
	result.push "gpsCount: #{gpsCount}"
	result.push "SECTOR: #{SECTOR}"
	result.push "cx cy: #{round cx} #{round cy}"
	result.push "SCALE: #{SCALE}"
	result

drawInfo = ->
	textAlign LEFT,CENTER
	sc()
	fc 0
	for m,i in info()
		text m,20,100*(i+1)

drawTrack = ->
	fc()
	sw 2/SCALE
	sc 0
	for [x,y],i in track
		circle x-cx, y-cy, 5 * (track.length-i)

drawTrail = ->
	fc()
	sw 2
	sc 1,0,0,0.5 # RED
	for [lon,lat] in storage.trail 
		[x,y] = w2b.convert lon,lat
		point x-cx, y-cy

drawControls = ->
	sw 2
	for key,control of storage.controls
		if control == null then continue
		[x,y,littera] = control
		col = "#0008"
		if key in "ABC" then col = "#0f08"
		if key in "DEFGHIJKLMNOPQRSTUVWXYZ" then col = "#00f8"
		if ":" in key then col ="#f008"

		r = radius key

		stroke col
		fc()
		circle x-cx, y-cy, r
		sc()
		fill col
		if r == data.radius # Full Size
			textSize r
			textAlign LEFT,TOP
			text key, x-cx+0.7*r, y-cy+0.7*r
			textAlign CENTER,CENTER
			text littera, x-cx, y-cy
		else # Half Size
			textSize r*1.5
			textAlign CENTER,CENTER
			text key, x-cx, y-cy

		stroke col
		sw 2
		point x-cx, y-cy

radius = (key) -> if key in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' or ':' in key then data.radius/2 else data.radius

drawControl = ->

	if trgLat == 0 and trgLon == 0 then return
	
	if gpsLat != 0 and gpsLon != 0
		latLon2 = LatLon trgLat,trgLon
		latLon1 = LatLon gpsLat,gpsLon

		bearing = latLon1.bearingTo latLon2
		messages[0] = currentControl || ""
		messages[1] = "#{int bearing}º"
		messages[2] = "#{round(latLon1.distanceTo latLon2)} m"

	if currentControl
		[x,y] = storage.controls[currentControl]
		sc()
		fc 0,0,0,0.25
		circle x-cx, y-cy, radius currentControl

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

draw = ->
	bg 0,1,0
	if state == 0 
		textSize 100
		textAlign CENTER,CENTER
		x = width/2
		y = height/2
		text mapName, x,y-100
		text 'Version: '+VERSION, x,y
		if dump.active then text 'debug',x,y+100
		text "Click to continue!", x,y+200
		return

	if state == 1
		push()
		translate width/2, height/2
		scale SCALE
		image img, -cx,-cy
		drawTrail()
		drawTrack()
		if data.drawControls then drawControls()
		drawControl()
		pop()
	
		fc 0
		sc 1,1,0
		sw 3
		margin = 25
		for message,i in messages
			textAlign [LEFT,CENTER,RIGHT][i%3], [TOP,BOTTOM][i//3]
			textSize [100,50][i//3]
			text message, [margin,width/2,width-margin][i%3], [margin,height][i//3] 
		showDialogue()
		menuButton.draw()
		drawRuler()
		return

	if state == 2
		drawInfo()
		return

setTarget = (key) ->
	soundQueue = 0
	if key == currentControl
		currentControl = null
		messages[0] = ""
		messages[1] = ""
		messages[2] = ""
		[trgLon,trgLat] = [0,0]
	else
		if key not of storage.controls then return
		if storage.controls[currentControl] == null then return
		# soundQueue = 0
		currentControl = key
		[x,y] = storage.controls[currentControl]
		[trgLon,trgLat] = b2w.convert x,y
		firstInfo key
	storage.save()
	dialogues.clear()

executeMail = ->
	r = info().join BR
	s = ("#{timestamp} #{latitude} #{longitude} #{altitude}" for [longitude,latitude,altitude,timestamp] in storage.trail).join BR
	t = ("#{key} #{x} #{y} #{littera} #{lat} #{lon}" for key,[x,y,littera,lat, lon] of storage.controls).join BR
	content = r + BR + dump.get() + t + BR + BR + s
	if currentControl
		littera = storage.controls[currentControl][2]
		sendMail "#{mapName} #{currentControl} #{littera}", content
	else
		sendMail "#{mapName}", content

Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

savePosition = ->
	[x,y] = w2b.convert gpsLon,gpsLat
	date = new Date()
	h = addZero date.getHours()
	M = addZero date.getMinutes()
	key = "#{h}:#{M}"
	storage.controls[key] = [x,y,'',gpsLat,gpsLon]
	storage.save()
	console.log key, storage.controls[key]
	voiceQueue.push "saved #{key}"
	dialogues.clear()

menu1 = -> # Main Menu
	dialogue = new Dialogue()
	dialogue.add 'Center', ->
		[cx,cy] = w2b.convert position[0],position[1] 
		dialogues.clear()
	dialogue.add 'Out', -> if SCALE > data.scale then SCALE /= 1.5
	dialogue.add 'Take...', -> menu4()
	dialogue.add 'More...', -> menu6()
	dialogue.add 'Save', -> savePosition()
	dialogue.add 'In', -> SCALE *= 1.5
	dialogue.clock ' ',true
	dialogue.textSize *= 1.5

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
	dialogue.add 'Init', -> initSpeaker()
	dialogue.add 'Mail...', ->
		executeMail()
		dialogues.clear()
	dialogue.add 'Sector...', -> menu7()
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

menu7 = -> # Sector
	dialogue = new Dialogue()
	dialogue.add '10', -> SetSector 10 # 36
	dialogue.add '20', -> SetSector 20 # 18
	dialogue.add '30', -> SetSector 30 # 12
	dialogue.add '45', -> SetSector 45 # 8
	dialogue.add '60', -> SetSector 60 # 6
	dialogue.add '90', -> SetSector 90 # 4
	dialogue.clock()

SetSector = (sector) ->
	SECTOR = sector
	dialogues.clear()

addZero = (n) -> if n <= 9 then "0" + n else n

stdDateTime = (date) ->
	y = date.getFullYear()
	m = addZero date.getMonth() + 1
	d = addZero date.getDate()
	h = addZero date.getHours()
	M = addZero date.getMinutes()
	s =	addZero date.getSeconds()
	"#{y}-#{m}-#{d} #{h}:#{M}:#{s}"

update = (littera,index=2) ->
	control = storage.controls[currentControl]
	#[x,y] = w2b.convert gpsLon, gpsLat
	control[index] = littera
	storage.save()
	dialogues.clear()
	executeMail()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

positionClicked = (xc,yc) -> # canvas koordinater

	xi = cx + (xc - width/2) / SCALE  	# image koordinater
	yi = cy + (yc - height/2) / SCALE

	for key,control of storage.controls
		if control == null then continue
		[x,y,z99,z99,z99] = control
		if radius(key) > dist xi,yi,x,y 
			setTarget key 
			return true
	false 

touchStarted = (event) ->
	event.preventDefault()
	startX = mouseX
	startY = mouseY
	false

touchMoved = (event) ->
	event.preventDefault()
	if dialogues.length == 0 and state == 1
		cx += (startX - mouseX)/SCALE
		cy += (startY - mouseY)/SCALE
		startX = mouseX
		startY = mouseY
	false

touchEnded = (event) ->
	event.preventDefault()
	if state == 0 then initSpeaker()
	if state == 2 then dialogues.clear()
	if state in [0,2]
		state = 1
		return false
	if menuButton.inside mouseX,mouseY
		menuButton.click()
		return false

	if dialogues.length > 0
		dialogue = _.last dialogues
		if not dialogue.execute mouseX,mouseY then dialogues.pop()
	else if state == 1 and startX == mouseX and startY == mouseY
		positionClicked mouseX,mouseY

	false

keyPressed = ->
	if key == ' '
		xi = round cx + (mouseX - width/2) / SCALE  	# image koordinater
		yi = round cy + (mouseY - height/2) / SCALE
		console.log xi,yi
