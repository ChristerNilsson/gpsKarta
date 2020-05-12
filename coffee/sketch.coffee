VERSION = 108 
DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this value is no bearing given.
SECTOR = 10 # Bearing resolution in degrees
#MAP = null # json file
DIGITS = 'nolla ett tvåa trea fyra femma sexa sju åtta nia'.split ' '
BR = '<br>'

# http://www.bvsok.se/Kartor/Skolkartor/
# Högupplösta orienteringskartor: https://www.omaps.net
# https://omaps.blob.core.windows.net/map-excerpts/1fdc587ffdea489dbd69e29b10b48395.jpeg Nackareservatet utan kontroller.

DISTLIST = [0,2,4,6,8,10,12,14,16,18,20,30,40,50,60,70,80,90,100, 120,140,160,180,200,250,300,350,400,450,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

mapName = "" # t ex skarpnäck

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
				#@mapName = obj.mapName
				console.log 'controls read from localStorage'
			catch
				@clear()
		else
			@clear()
			console.log 'controls read from json file'
		console.log 'Storage',@

	save : -> localStorage['gpsKarta' + @mapName] = JSON.stringify @

	clear : ->
		@controls = data.controls
		@trail = []
		@init()
		[trgLat,trgLon] = [0,0]
		currentControl = null
		@save()
		console.log 'clear',@

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
		console.log 'deleteControl',currentControl
		@controls[currentControl] = null
		@save()
		currentControl = null


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
TRACKED = 5 # circles shows the player's position
position = null # gps position (pixels)
track = [] # five latest GPS positions (pixels)

speaker = null

soundUp = null
soundDown = null
soundQueue = 0 # neg=minskat avstånd pos=ökat avstånd
jcnindex = 0

messages = ['','','','','','']
gpsCount = 0

[gpsLat,gpsLon] = [0,0] # avgör om muntlig information ska ges
[trgLat,trgLon] = [0,0] # koordinater för valt target

lastLocation = '' # används för att skippa lika koordinater

timeout = null

voiceQueue = []
bearingSaid = ''
distanceSaid = ''

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
	#dump.store "soundIndicator #{p.coords.latitude} #{p.coords.longitude}"
	a = LatLon p.coords.latitude,p.coords.longitude # newest
	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	dista = a.distanceTo c
	distb = b.distanceTo c
	distance = round (dista - distb)/DIST

	if trgLat != 0
		bearinga = a.bearingTo c
		bearingb = b.bearingTo c
		if dista >= LIMIT
			sBearing = sayBearing bearinga,bearingb
			if sBearing != "" then voiceQueue.push "bäring #{sBearing}"
		sDistance = sayDistance dista,distb
		if sDistance != "" then voiceQueue.push "distans #{sDistance}"

	if distance != 0 # update only if DIST detected. Otherwise some beeps will be lost.
		gpsLat = myRound p.coords.latitude,6
		gpsLon = myRound p.coords.longitude,6

	if abs(distance) < 10 then soundQueue = distance # ett antal DIST

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

	if arr[0] == 'bäring'
		msg = arr[1] + ' ' + arr[2] # skippa ordet. t ex 'bäring etta tvåa'
		if bearingSaid != msg then say msg
		bearingSaid = msg
	else if arr[0] == 'distans'
		msg = arr[1]                # skippa ordet. t ex 'distans 30'
		if distanceSaid != msg then say msg
		distanceSaid = msg
	else if arr[0] == 'target'
		# 'target 11. bäring etta tvåa. distans 250 meter'
		msg = "#{arr[0]} #{arr[1]}. bäring #{arr[2]} #{arr[3]}. distans #{arr[4]} meter"
		bearingSaid = arr[2] + ' ' + arr[3]
		distanceSaid = arr[4]
		say msg
	else if arr[0] == 'sparade'
		say msg


locationUpdate = (p) ->
	pLat = myRound p.coords.latitude,6
	pLon = myRound p.coords.longitude,6
	nextLocation = "#{pLat} #{pLon}"
	gpsCount++
	messages[5] = gpsCount
	decreaseQueue()
	if nextLocation == lastLocation then return
	lastLocation = nextLocation
	updateTrack p.timestamp, pLat, pLon
	increaseQueue p
	#if currentControl == null then return
	updateTrail()

updateTrack = (timestamp, pLat, pLon) ->
	d = new Date()
	d.setTime timestamp
	dump.store ""
	dump.store "LU #{d.toLocaleString 'SWE'} #{pLat} #{pLon}"
	if gpsLat != 0
		position = w2b.convert pLon,pLat
		track.push position
		if track.length > TRACKED then track.shift()
		t = _.last track
		dump.store "T #{t[0]} #{t[1]}"
		messages[4] = pLat + ' ' + pLon

updateTrail = ->
	if storage.trail.length == 0
		storage.trail.push position
	else
		[x1,y1] = _.last storage.trail
		[x2,y2] = position
		if 12 < dist x1,y1,x2,y2 then storage.trail.push position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['Check location permissions']

initSpeaker = (index=5) ->
	dump.store "initSpeaker in #{index}"
	soundUp = loadSound 'soundUp.wav'
	soundDown = loadSound 'soundDown.wav'
	soundUp.setVolume 0.1
	soundDown.setVolume 0.1
	clearInterval timeout
	timeout = setInterval playSound, DELAY
	soundQueue = 0

	speaker = new SpeechSynthesisUtterance()
	voices = speechSynthesis.getVoices()
	speaker.voice = voices[index]
	speaker.voiceURI = "native"
	speaker.volume = 1
	speaker.rate = 0.8
	speaker.pitch = 0.8
	speaker.text = '' 
	speaker.lang = 'sv-SE'
	dialogues.clear()
	say "Välkommen!"
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
	#return [425,200]
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

	[cx,cy] = [img.width/2,img.height/2]
	
	dcs = data.controls
	bmp = [dcs.A[0], dcs.A[1], dcs.B[0], dcs.B[1], dcs.C[0], dcs.C[1]]

	b2w = new Converter bmp,data.wgs,6
	w2b = new Converter data.wgs,bmp,0

	# myTest() Do not execute! Very dependent on .json file.

	storage = new Storage mapName
	
	position = [img.width/2,img.height/2]

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
	result.push "cx cy: #{cx} #{cy}"
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
	sw 1/SCALE
	sc 0
	for [x,y],i in track
		circle x-cx, y-cy, 5 * (track.length-i)

drawTrail = ->
	fc()
	sw 12
	sc 1,0,0,0.5 # RED
	for [x,y] in storage.trail
		point x-cx, y-cy

drawControls = ->
	textSize data.radius
	sw 2
	for key,control of storage.controls
		if control == null then continue
		[x,y,littera] = control
		col = "#000"
		if key in "ABC" then col = "#0f0"
		if ":" in key then col ="#f00"
		stroke col
		fc()
		circle x-cx,y-cy,data.radius
		sc()
		fc 0
		textAlign LEFT,TOP
		text key,x-cx+0.7*data.radius,y-cy+0.7*data.radius
		textAlign CENTER,CENTER
		text littera,x-cx,y-cy

drawControl = ->

	if trgLat == 0 and trgLon == 0 then return

	latLon2 = LatLon trgLat,trgLon
	latLon1 = LatLon gpsLat,gpsLon

	bearing = latLon1.bearingTo latLon2
	messages[0] = "#{int bearing}º"
	messages[1] = currentControl
	messages[2] = "#{round(latLon1.distanceTo latLon2)} m"

	if currentControl 
		control = storage.controls[currentControl]
		x = control[0]
		y = control[1]
		sc()
		fc 0,0,0,0.25
		circle x-cx, y-cy, data.radius

drawScale = ->
	[w1,w0] = getMeters width, SCALE
	d = (w1-w0)/2/w1 * width
	x = d
	y = height * 0.9
	w = w0/w1 * width
	h = 10
	sc 0
	sw 2
	line x,y,x+w,y
	line x,y,x,y-10
	line x+w,y,x+w,y-10
	textSize height/30
	textAlign CENTER,CENTER
	sc()
	fc 0
	text w0+"m",width/2,y-20

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
		drawScale()
		return

	if state == 2
		drawInfo()
		return

setTarget = (key) ->
	console.log 'setTarget',key
	if key not of storage.controls then return
	if storage.controls[currentControl] == null then return
	storage.trail = []
	soundQueue = 0
	currentControl = key
	control = storage.controls[currentControl]
	x = control[0]
	y = control[1]
	[trgLon,trgLat] = b2w.convert x,y
	console.log trgLon,trgLat
	firstInfo key
	storage.save()
	dialogues.clear()

executeMail = -> # Sends the trail
	r = info().join BR
	if currentControl 
		littera = storage.controls[currentControl][2]
		arr = ("[#{x},#{y}]" for [x,y] in storage.trail)
		s = arr.join ","
	else
		s = ""
	sendMail "#{data.mapName} #{currentControl} #{littera}", r + BR + dump.get() + s

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
	voiceQueue.push "sparade #{key}"
	dialogues.clear()

menu1 = -> # Main Menu
	dialogue = new Dialogue()
	dialogue.add 'Center', ->
		[cx,cy] = position
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
	dialogue.add 'Init', -> initSpeaker jcnindex++
	dialogue.add 'Mail...', ->
		executeMail()
		dialogues.clear()
	dialogue.add 'Sector...', -> menu7()
	dialogue.add 'Delete', -> storage.deleteControl()
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
	[x,y] = w2b.convert gpsLon, gpsLat
	storage.controls[currentControl][index] = littera
	storage.save()
	dialogues.clear()
	executeMail()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

positionClicked = (xc,yc) -> # canvas koordinater

	# image koordinater
	xi = cx + (xc - width/2) / SCALE
	yi = cy + (yc - height/2) / SCALE

	console.log storage.controls

	for key,control of storage.controls
		if control == null then continue
		[x,y,z99,z99,z99] = control
		if data.radius > dist xi,yi,x,y 
			console.log key
			setTarget key 
			return true
	false 

touchStarted = (event) ->
	event.preventDefault()
	startX = mouseX
	startY = mouseY
	#state = 1
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
