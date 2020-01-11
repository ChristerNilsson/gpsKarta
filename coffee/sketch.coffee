DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this, no bearing. Also distance voice every meter.

DISTLIST = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,30,40,50,60,70,80,90,100,120,140,160,180,200,250,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]
MAIL = 'janchrister.nilsson@gmail.com'

spara = (lat,lon, x,y) -> {lat,lon, x,y}

# 2019-SommarN

# A = spara 59.2987921, 18.1284073, 472, 617 # kontroll  5
# B = spara 59.2985405, 18.1699098,4361, 503 # kontroll 10
# C = spara 59.2851374, 18.1336592,1090,3104 # kontroll 31
# D = spara 59.2844998, 18.1666946,4181,3069 # kontroll 17

# FILENAME = '2019-SommarN.jpg' 

# controls = # id: [x,y,littera,lat,lon]
# 	'1': [1830,333,'',0,0] 
# 	'2': [1506,521,'',0,0]
# 	'3': [907,711,'',0,0]
# 	'4': [1193,873,'',0,0]
# 	'5': [472,617,'',0,0]
# 	'6': [228,841,'',0,0]
# 	'7': [672,1013,'',0,0]
# 	'8': [1125,1196,'',0,0]
# 	'9': [1430,1290,'',0,0]
# 	'10': [4361,503,'',0,0]
# 	'11': [4118,1106,'',0,0]
# 	'12': [3830,640,'',0,0]
# 	'13': [3192,1133,'',0,0]
# 	'14': [2664,873,'',0,0]
# 	'15': [2322,1862,'',0,0]
# 	'16': [4120,2699,'',0,0]
# 	'17': [4181,3069,'',0,0]
# 	'19': [3340,2904,'',0,0]
# 	'20': [2691,2554,'',0,0]
# 	'24': [3366,3217,'',0,0]
# 	'26': [390,1935,'',0,0]
# 	'27': [547,2143,'',0,0]
# 	'28': [1462,2293,'',0,0]
# 	'29': [1055,2620,'',0,0]
# 	'30': [371,2502,'',0,0]
# 	'31': [1090,3104,'',0,0]
# 	'32': [2250,2750,'',0,0]

# 2019-SommarS

# A = spara 59.2801716, 18.152609,  2894,485  # 38 P
# B = spara 59.2810534, 18.1676281, 4303,255  # 21 B
# C = spara 59.2677013, 18.1548921, 3231,2757 # 50 K
# D = spara 59.2687144, 18.1660263, 4256,2514 # 48 M

# A = spara 59.279157, 18.149313, 2599,676 # Mellanbron
# B = spara 59.275129, 18.169590, 4531,1328 # Ulvsjön Vändplan Huset
# C = spara 59.270072, 18.150229, 2763,2334 # Brotorpsbron
# D = spara 59.267894, 18.167087, 4339,2645 # Älta huset

FILENAME = '2020-Vinter.jpg' 

A = spara 59.285624, 18.150709, 338,1491 # Övre bron Ö
B = spara 59.283048, 18.179902, 4299,1948 # Stora fårhuset
C = spara 59.270077, 18.150339, 488,5566 # Brotorpsbron Ö
D = spara 59.269496, 18.168739, 2963,5596 # Bergsätrav/Klisätrav

controls = 
	#'Brotorp':     59.2705658 18.1480179 2019-05-20 18:32:15 43 B (794)
	#'Skarpnäck T': 59.2662226 18.1331561 2019-05-20 18:37:25 bike S (973)
	1: [604,6069,'',0,0]
	2: [1415,6153,'',0,0]
	3: [918,5525,'',0,0]
	4: [2157,5841,'',0,0]
	5: [1872,5261,'',0,0]
	6: [1430,4485,'',0,0]
	7: [2460,4629,'',0,0]
	8: [1828,4044,'',0,0]
	9: [1130,3042,'',0,0]
	10: [1371,2479,'',0,0]
	11: [1088,1656,'',0,0]
	12: [1669,1684,'',0,0]
	13: [2461,2092,'',0,0]
	14: [3503,1675,'',0,0]
	15: [3965,2167,'',0,0]
	16: [4064,2716,'',0,0]
	17: [3539,3097,'',0,0]
	18: [2724,3108,'',0,0]
	19: [3282,3697,'',0,0]
	20: [2676,4189,'',0,0]
#################

targets = [] # [id, littera, distance]
platform = null

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
jcnindex = 0

messages = [0,1,2,3,4,5]
gpsCount = 0

[gpsLat,gpsLon] = [0,0]
[trgLat,trgLon] = [0,0]
currentControl = "1"

timeout = null

pastSayings = {} # for preventing sayings every second.
#lastBearing = ''
#lastDistance = ''

w = null
h = null
released = true 

sendMail = (subject,body) ->
	mail.href = encodeURI "mailto:#{MAIL}?subject=#{subject}&body=#{body}"
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

# coarse = (x) ->
# 	n = Math.round(x).toString().length
# 	myround(x,1-n).toString()
# assert '4000', coarse 3917.5	
# assert '400', coarse 421.2	
# assert '40', coarse 36.8
# assert '5', coarse 5.4
# assert '5', coarse 4.6

sayDistance = (a,b) -> # a is newer
	# anropa say om någon gräns passeras
	# if a border is crossed, play a sound
	for d in DISTLIST
		if (a-d) * (b-d) < 0
			distance = if a >= LIMIT then 'distans ' + d else d
			now = Date.now()
			if distance not of pastSayings then pastSayings[distance] = 0
			if now > pastSayings[distance] + 2000 # ms
				pastSayings[distance] = now
				say distance
			return

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
		now = Date.now()
		if bearing not of pastSayings then pastSayings[bearing] = 0
		if now > pastSayings[bearing] + 2000 # ms
			pastSayings[bearing] = now
			say bearing

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
	say "speaker #{jcnindex}"
	jcnindex++

setup = ->

	canvas = createCanvas innerWidth-0.5, innerHeight-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	platform = window.navigator.platform

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
	dialogues.clear()

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

getBike = -> setTarget 'bike'

setBike = ->
	[x,y] = gps.gps2bmp gpsLat,gpsLon
	controls.bike = [x,y,'',gpsLat,gpsLon]
	dialogues.clear()

menu1 = -> # Main Menu
	dialogue = new Dialogue() 
	dialogue.add 'Pan Zoom', -> menu2()
	dialogue.add 'Goto Bike', -> setTarget 'bike'
	dialogue.add 'Take', -> menu4()
	dialogue.add 'Mail', -> executeMail()
	dialogue.add 'Center', -> 
		[cx,cy] = position
		dialogues.clear()	
		xdraw()	
	dialogue.add 'Speaker', -> initSpeaker 5
	dialogue.add 'Target', -> menu3()
	dialogue.add 'Store Bike', -> setBike()

	dialogue.clock ' ',true
	dialogue.textSize *= 1.5

menu2 = -> # Pan Zoom
	dialogue = new Dialogue()
	dialogue.add 'Up', -> cy -= 0.33*height/SCALE  
	dialogue.add ' ', -> # Not Used
	dialogue.add 'Right', -> cx += 0.33*width/SCALE
	dialogue.add 'Out', -> if SCALE > 0.5 then SCALE /= 1.5
	dialogue.add 'Down', -> cy += 0.33*height/SCALE
	dialogue.add 'In', -> SCALE *= 1.5
	dialogue.add 'Left', -> cx -= 0.33*width/SCALE
	dialogue.add ' ', -> # Not used
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
	dialogue.add 'ABCDE', -> menu5 'ABCDE'
	dialogue.add 'FGHIJ', -> menu5 'FGHIJ'
	dialogue.add 'KLMNO', -> menu5 'KLMNO'
	dialogue.add 'PQRST', -> menu5 'PQRST'
	dialogue.add 'UVWXYZ', -> menu5 'UVWXYZ'
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
	control = controls[currentControl]
	a = LatLon control[3],control[4] 
	b = LatLon gpsLat, gpsLon 
	[x,y] = gps.gps2bmp gpsLat, gpsLon
	print x,y
	takes.push "[#{x}, #{y},'', #{gpsLat}, #{gpsLon}] #{stdDateTime new Date()} #{currentControl} #{littera} (#{Math.round a.distanceTo b})"
	controls[currentControl][index] = littera
	dialogues.clear()
	getBike()

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

mousePressed = -> 
	if platform == 'Win32' then myMousePressed mouseX,mouseY
	false
