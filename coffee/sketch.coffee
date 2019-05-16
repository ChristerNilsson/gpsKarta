DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this, no bearing. Also distance voice every meter.

MAIL = 'janchrister.nilsson@gmail.com'

spara = (lat,lon, x,y) -> {lat,lon, x,y}

# 2019-SommarN

A = spara 59.2987921, 18.1284073, 472, 617 # kontroll  5
B = spara 59.2985405, 18.1699098,4361, 503 # kontroll 10
C = spara 59.2851374, 18.1336592,1090,3104 # kontroll 31
D = spara 59.2844998, 18.1666946,4181,3069 # kontroll 17

# A = spara 59.300716, 18.125680,  197, 278 # Lilla halvön
# B = spara 59.299235, 18.169492, 4306, 367 # Kranglans väg/Östervägen
# C = spara 59.285443, 18.124585,  236,3082 # Ishockeyrink Mitten
# D = spara 59.287806, 18.170784, 4525,2454 # Mittenhus t v

FILENAME = '2019-SommarN.jpg' 

controls = # id: [x,y,littera,lat,lon]
	'1': [1830,333,'',0,0] 
	'2': [1506,521,'',0,0]
	'3': [907,711,'',0,0]
	'4': [1193,873,'',0,0]
	'5': [472,617,'',0,0]
	'6': [228,841,'',0,0]
	'7': [672,1013,'',0,0]
	'8': [1125,1196,'',0,0]
	'9': [1430,1290,'',0,0]
	'10': [4361,503,'',0,0]
	'11': [4118,1106,'',0,0]
	'12': [3830,640,'',0,0]
	'13': [3192,1133,'',0,0]
	'14': [2664,873,'',0,0]
	'15': [2322,1862,'',0,0]
	'16': [4120,2699,'',0,0]
	'17': [4181,3069,'',0,0]
	'19': [3340,2904,'',0,0]
	'20': [2691,2554,'',0,0]
	'24': [3366,3217,'',0,0]
	'26': [390,1935,'',0,0]
	'27': [547,2143,'',0,0]
	'28': [1462,2293,'',0,0]
	'29': [1055,2620,'',0,0]
	'30': [371,2502,'',0,0]
	'31': [1090,3104,'',0,0]
	'32': [2250,2750,'',0,0]

# 2019-SommarS
# A = spara 59.279157, 18.149313, 2599,676 # Mellanbron
# B = spara 59.275129, 18.169590, 4531,1328 # Ulvsjön Vändplan Huset
# C = spara 59.270072, 18.150229, 2763,2334 # Brotorpsbron
# D = spara 59.267894, 18.167087, 4339,2645 # Älta huset

# FILENAME = '2019-SommarS.jpg' 

# controls = 
# 	21: [4303,255]
# 	22: [4066,407]
# 	23: [3436,158]
# 	25: [3534,485]
# 	34: [1709,65]
# 	35: [1212,151]
# 	36: [2215,1008]
# 	37: [2571,1186]
# 	38: [2894,485]
# 	39: [3245,778]
# 	40: [4317,1003]
# 	41: [4303,685]
# 	42: [3868,1292]
# 	43: [3426,1281]
# 	44: [3536,1650]
# 	45: [4538,1763]
# 	46: [3926,2133]
# 	47: [3104,2025]
# 	48: [4256,2514]
# 	49: [3773,2493]
# 	50: [3231,2757]

#################

targets = [] # [id, littera, distance]

initControls = ->
	for key,control of controls
		[x,y,littera] = control
		[lat,lon] = gps.bmp2gps x,y
		control[3] = lat
		control[4] = lon

makeTargets = ->
	targets = []
	c = LatLon gpsLat, gpsLon 
	for key,control of controls
		[x,y,littera,lat,lon] = control
		b = LatLon lat, lon
		targets.push [key, littera, round b.distanceTo(c)]
	targets

DATA = "gpsKarta"
WIDTH = null
HEIGHT = null
[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

gps = null
TRACKED = 5 # circles shows the player's position
position = null # gps position (pixels)
track = [] # five latest GPS positions (pixels)
trail = [] # all gps points
takes = [] # all littera takes

speaker = null

img = null 
soundUp = null
soundDown = null
soundQueue = 0 # neg=minskat avstånd pos=ökat avstånd

messages = [0,1,2,3,4,5]
gpsCount = 0

[gpsLat,gpsLon] = [0,0]
[trgLat,trgLon] = [0,0]
currentControl = "1"

timeout = null

lastBearing = ''
lastDistance = ''

w = null
h = null
released = true 

sendMail = (subject,body) ->
	s = encodeURI "mailto:#{MAIL}?subject=#{subject}&body=#{body}"
	#print escape s
	#print encodeURI s  
	#print encodeURIComponent s 
	mail.href = s
	mail.click()

say = (m) ->
	if speaker == null then return 
	speechSynthesis.cancel()
	speaker.text = m
	speechSynthesis.speak speaker

preload = -> img = loadImage FILENAME

myround = (x,dec=6) ->
	x *= 10**dec
	x = Math.round x
	x/10**dec

#show = (prompt,p) -> print prompt,"http://maps.google.com/maps?q=#{p.lat},#{p.lon}"	

vercal = (a,b,y) ->
	x = map y, a.y,b.y, a.x,b.x
	lat = map y, a.y,b.y, a.lat,b.lat
	lon = map y, a.y,b.y, a.lon,b.lon  
	{lat,lon,x,y} 	

hortal = (a,b,x) ->
	y = map x, a.x,b.x, a.y,b.y
	lat = map x, a.x,b.x, a.lat,b.lat
	lon = map x, a.x,b.x, a.lon,b.lon  
	{lat,lon,x,y} 	

corner = (a,b,c,d,x,y)->
	lat = map y, c.y,d.y, c.lat,d.lat  
	lon = map x, a.x,b.x, a.lon,b.lon
	{lat,lon,x,y}

makeCorners = ->

	ac0 = vercal A,C,0  	                  # beräkna x
	ac1 = vercal A,C,HEIGHT
	bd0 = vercal B,D,0
	bd1 = vercal B,D,HEIGHT

	ab0 = hortal A,B,0                      # beräkna y
	ab1 = hortal A,B,WIDTH
	cd0 = hortal C,D,0
	cd1 = hortal C,D,WIDTH

	nw = corner ac0,bd0,ab0,cd0, 0,    0		# beräkna hörnen
	ne = corner ac0,bd0,ab1,cd1, WIDTH,0
	se = corner ac1,bd1,ab1,cd1, WIDTH,HEIGHT
	sw = corner ac1,bd1,ab0,cd0, 0,    HEIGHT

	gps = new GPS nw,ne,se,sw,WIDTH,HEIGHT

coarse = (x) ->
	n = Math.round(x).toString().length
	myround(x,1-n).toString()
assert '4000', coarse 3917.5	
assert '400', coarse 421.2	
assert '40', coarse 36.8
assert '5', coarse 5.4
assert '5', coarse 4.6

sayDistance = (a,b) -> # anropa say om någon gräns passeras 1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,20,30,...
	# if a border is crossed, play a sound
	if a <= LIMIT
		if Math.round(a) != Math.round(b)
			distance = (Math.round a).toString()
			if distance != lastDistance 
				say distance 
				lastDistance = distance
			return
	sa = coarse a
	sb = coarse b
	if sa == sb then return
	distance = if a >= LIMIT then 'distans ' + sa else sa
	if distance != lastDistance 
		say distance
		lastDistance = distance 

# eventuellt kräva tio sekunder sedan föregående bäring sades
sayBearing = (a,b) -> # a is newer
	# if a border is crossed, tell the new bearing
	a = Math.round a/10
	b = Math.round b/10
	if a != b # 0..35
		if a == 0 then a = 36
		tr = 'nolla ett tvåa trea fyra femma sexa sju åtta nia'.split ' '
		c = tr[a//10]
		d = tr[a%%10]
		bearing = 'bäring ' + c + ' ' + d
		if bearing != lastBearing
			say bearing
			lastbearing = bearing

soundIndicator = (p) ->

	trail.push "#{p.coords.latitude} #{p.coords.longitude} #{stdDateTime new Date()}"

	a = LatLon p.coords.latitude,p.coords.longitude # newest
	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	dista = a.distanceTo c
	distb = b.distanceTo c
	distance = Math.round (dista - distb)/DIST

	sayDistance dista,distb
	bearinga = a.bearingTo c
	bearingb = b.bearingTo c
	if dista >= LIMIT then sayBearing bearinga,bearingb

	if abs(DIST * distance) < 10 
		messages[3] = "#{DIST * distance} m/s" # abs dista-distb
	else
		messages[3] = ''

	if distance != 0 # update only if DIST detected. Otherwise some beeps will be lost.
		gpsLat = p.coords.latitude
		gpsLon = p.coords.longitude

	if abs(distance) < 10 then soundQueue = distance # ett antal DIST

playSound = ->
	if soundQueue == 0 then return
	if soundQueue < 0 and soundDown != null
		soundQueue++
		soundDown.play()
	else if soundQueue > 0 and soundUp != null
		soundQueue--
		soundUp.play()
	messages[4]	= soundQueue
	if soundQueue==0 then xdraw()

locationUpdate = (p) ->
	gpsCount++
	messages[5] = gpsCount
	soundIndicator p

	position = gps.gps2bmp gpsLat,gpsLon

	track.push position
	if track.length > TRACKED then track.shift()
	xdraw()
	position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['Check location permissions']

initSpeaker = (index) ->
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
	say "speaker #{index}"

setup = ->

	canvas = createCanvas innerWidth-0.5, innerHeight-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	w = width/8
	h = height/4 
	angleMode DEGREES

	WIDTH = img.width
	HEIGHT = img.height

	SCALE = 1
	[cx,cy] = [width,height]
	
	makeCorners()
	setTarget _.keys(controls)[0]

	x = width/2
	y = height/2
	x1 = 100
	x2 = width-100
	y1 = 100
	y2 = height-100

	initControls()

	position = [WIDTH/2,HEIGHT/2]

	navigator.geolocation.watchPosition locationUpdate, locationUpdateFail,
		enableHighAccuracy: true
		maximumAge: 30000
		timeout: 27000

	xdraw()

	addEventListener 'touchstart', (evt) ->
		touches = evt.changedTouches
		touch = touches[touches.length-1]
		mx = touch.pageX
		my = touch.pageY
		myMousePressed mx,my

drawTrack = ->
	push()
	fc()
	sw 4
	sc 0 # BLACK
	translate width/2, height/2
	scale SCALE
	for [x,y],i in track
		circle x-cx, y-cy, 10 * (track.length-i)
	pop()

drawControl = ->

	latLon2 = LatLon trgLat,trgLon
	latLon1 = LatLon gpsLat,gpsLon

	bearing = latLon1.bearingTo latLon2
	messages[0] = "#{int bearing}º"
	messages[1] = currentControl
	messages[2] = "#{Math.round(latLon1.distanceTo latLon2)} m"

	control = controls[currentControl]
	x = control[0]
	y = control[1]

	push()
	sc()
	fc 0,0,0,0.25
	translate width/2, height/2
	scale SCALE
	circle x-cx, y-cy, 75
	pop()

xdraw = ->
	bg 0,1,0
	fc()
	image img, 0,0, width,height, cx-width/SCALE/2, cy-height/SCALE/2, width/SCALE, height/SCALE
	drawTrack()
	drawControl()
	textSize 100
	fc 0
	sc 1,1,0
	sw 3
	margin = 25
	for message,i in messages
		textAlign [LEFT,CENTER,RIGHT][i%3], [TOP,BOTTOM][i//3]
		text message, [margin,width/2,width-margin][i%3], [margin,height][i//3] 
	showDialogue()

setTarget = (key) ->
	if controls[currentControl] == null then return
	soundQueue = 0
	currentControl = key
	control = controls[currentControl]
	x = control[0]
	y = control[1]
	[trgLat,trgLon] = gps.bmp2gps x,y	

executeMail = -> # Sends the trail and all the takes
	s = takes.join "\n"
	s += "\n\n"
	s += trail.join "\n"
	sendMail "Takes:#{takes.length} Trail:#{trail.length}", s
	takes = []
	trail = []

##########################

Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

menu1 = -> # Main Menu
	dialogue = new Dialogue() 
	dialogue.add 'Target..', -> menu3()
	dialogue.add 'PanZoom..', -> menu2()
	dialogue.add 'Center', -> 
		[cx,cy] = position
		dialogues.clear()	
		xdraw()	
	dialogue.add 'Mail', -> executeMail()
	dialogue.add 'Speaker', -> initSpeaker 5
	dialogue.add 'Take..', -> menu4()
	dialogue.clock ' ',true

menu2 = -> # Pan Zoom
	dialogue = new Dialogue()
	dialogue.add 'Up', -> cy -= 0.33*height/SCALE  
	dialogue.add ' ', -> 
		# setTarget 'bike'
		# dialogues.clear()
	dialogue.add 'Right', -> cx += 0.33*width/SCALE
	dialogue.add 'Out', -> if SCALE > 0.5 then SCALE /= 1.5
	dialogue.add 'Down', -> cy += 0.33*height/SCALE
	dialogue.add 'In', -> SCALE *= 1.5
	dialogue.add 'Left', -> cx -= 0.33*width/SCALE
	dialogue.add 'Bike', -> 
		[x,y] = gps.gps2bmp gpsLat,gpsLon
		controls['bike'] = [x,y,'',0,0]
		dialogues.clear()
	dialogue.clock()

menu3 = -> # Target
	dialogue = new Dialogue 0,0
	targets = makeTargets()
	lst = targets.slice()
	lst = lst.sort (a,b) -> a[2] - b[2]
	dialogue.list lst, 8, false, (arr) ->
		if arr.length > 0 then setTarget arr[0]
		dialogues.clear()		

menu4 = -> # Take
	dialogue = new Dialogue()
	dialogue.add 'ABCDE..', -> menu5 'ABCDE'
	dialogue.add 'FGHIJ..', -> menu5 'FGHIJ'
	dialogue.add 'KLMNO..', -> menu5 'KLMNO'
	dialogue.add 'PQRST..', -> menu5 'PQRST'
	dialogue.add 'UVWXYZ..', -> menu5 'UVWXYZ'
	dialogue.clock()

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
	takes.push "#{gpsLat} #{gpsLon} #{stdDateTime new Date()} #{currentControl} #{littera}"
	controls[currentControl][index] = littera
	dialogues.clear()

menu5 = (letters) -> # ABCDE
	dialogue = new Dialogue() 
	for letter in letters
		dialogue.add letter, -> update @title
	dialogue.clock()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

mouseReleased = ->
	released = true
	false

myMousePressed = (mx,my) -> 

	if not released then return false
	released = false 

	if dialogues.length == 1 and dialogues[0].number == 0 then dialogues.pop() # dölj indikatorer

	dialogue = _.last dialogues
	if dialogues.length == 0 or not dialogue.execute mx,my 
		if dialogues.length == 0 then menu1() else dialogues.pop()
		xdraw()
		return false

	xdraw()
	false 

mousePressed = -> myMousePressed mouseX,mouseY
