VERSION = 6
DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this, no bearing. Also distance voice every meter.
ANGLE = 20 # degrees. Bearing resolution.

DISTLIST = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,30,40,50,60,70,80,90,100,120,140,160,180,200,250,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]
MAIL = 'janchrister.nilsson@gmail.com'

trail = [	# insert bitmap points from mail here
	# 16
	#[3410,2885], [3415,2898], [3427,2890], [3440,2889], [3453,2887], [3468,2882], [3480,2879], [3495,2876], [3507,2873], [3519,2871], [3533,2868], [3548,2866], [3563,2865], [3575,2864], [3592,2859], [3610,2852], [3621,2842], [3636,2835], [3651,2830], [3664,2822], [3679,2820], [3697,2818], [3716,2818], [3736,2817], [3748,2814], [3768,2812], [3789,2807], [3800,2801], [3812,2793], [3821,2785], [3830,2775], [3841,2761], [3851,2747], [3860,2734], [3866,2720], [3873,2705], [3883,2690], [3895,2679], [3909,2669], [3922,2657], [3936,2640], [3952,2626], [3961,2618], [3972,2605], [3980,2593], [3988,2581], [3995,2591], [4004,2582], [4005,2595], [4012,2606], [4021,2615], [4023,2627], [4033,2636], [4039,2649], [4043,2661], [4041,2674], [4037,2686], [4026,2693], [4034,2702], [4045,2697], [4057,2688]  
	# 15
	[4009,2596], [4010,2584], [4043,2576], [4058,2575], [4072,2574], [4089,2567], [4099,2559], [4111,2548], [4124,2539], [4153,2527], [4171,2522], [4182,2513], [4190,2502], [4197,2489], [4204,2478], [4212,2469], [4223,2464], [4240,2458], [4230,2465], [4224,2452], [4225,2440], [4223,2428], [4220,2414], [4212,2402], [4200,2389], [4192,2372], [4191,2357], [4190,2343], [4187,2326], [4183,2306], [4179,2291], [4177,2277], [4177,2263], [4174,2248], [4169,2235], [4165,2221], [4161,2207], [4154,2192], [4148,2176], [4140,2166], [4132,2134], [4127,2115], [4123,2100], [4113,2107], [4102,2112], [4089,2110], [4077,2109], [4064,2106], [4052,2113], [4039,2115], [4026,2118], [4014,2120], [4007,2131], [3986,2126], [3974,2129], [3962,2132], [3956,2143], [3962,2155] 
]
recordingTrail = false

state = 0 # 0=uninitialized 1=initialized

spara = (lat,lon, x,y) -> {lat,lon, x,y}

FILENAME = '2020-Vinter.jpg'

# A = spara 59.285624, 18.150709, 338,1491  # Övre bron Ö
# B = spara 59.283048, 18.179902, 4299,1948 # Stora fårhuset
# C = spara 59.270077, 18.150339, 488,5566  # Brotorpsbron Ö
# D = spara 59.269496, 18.168739, 2963,5596 # Bergsätrav/Klisätrav

bmp = [338,1491, 4299,1948, 2963,5596] # x1,y1, x2,y2, x3,y3
wgs = [18.150709,59.285624, 18.179902,59.283048, 18.168739,59.269496] # lng1,lat1, lng2,lat2, lng3,lat3

b2w = null # new Converter bmp,wgs
w2b = null # new Converter wgs,bmp

controls = {}
	#'Brotorp':     59.2705658 18.1480179 2019-05-20 18:32:15 43 B (794)
	#'Skarpnäck T': 59.2662226 18.1331561 2019-05-20 18:37:25 bike S (973)
clearControls = ->
	controls =
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
	[trgLat,trgLon] = [0,0]
	currentControl = null
	initControls()
	saveControls()
#################

targets = [] # [id, littera, distance]
platform = null

saveControls = -> localStorage.gpsKarta = JSON.stringify controls

getControls = ->
	try
		controls = JSON.parse localStorage.gpsKarta
	catch
		clearControls()

initControls = ->
	for key,control of controls
		[x,y,littera] = control
		
		# [lat,lon] = gps.bmp2gps x,y
		[lon,lat] = b2w.convert x,y

		control[3] = lat
		control[4] = lon
	if currentControl != null
		[gpsLat,gpsLon,z99,trgLat,trgLon] = controls[currentControl]

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
SCALE = null

gps = null
TRACKED = 5 # circles shows the player's position
position = null # gps position (pixels)
track = [] # five latest GPS positions (pixels)

speaker = null

img = null
soundUp = null
soundDown = null
soundQueue = 0 # neg=minskat avstånd pos=ökat avstånd
jcnindex = 0

messages = ['','','','','','']
gpsCount = 0

[gpsLat,gpsLon] = [0,0]
[trgLat,trgLon] = [0,0]
currentControl = null

timeout = null

voiceQueue = []
lastBearing = ''
lastDistance = ''

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

# vercal = (a,b,y) ->
# 	x = map y, a.y,b.y, a.x,b.x
# 	lat = map y, a.y,b.y, a.lat,b.lat
# 	lon = map y, a.y,b.y, a.lon,b.lon
# 	{lat,lon,x,y}

# hortal = (a,b,x) ->
# 	y = map x, a.x,b.x, a.y,b.y
# 	lat = map x, a.x,b.x, a.lat,b.lat
# 	lon = map x, a.x,b.x, a.lon,b.lon
# 	{lat,lon,x,y}

# corner = (a,b,c,d,x,y)->
# 	lat = map y, c.y,d.y, c.lat,d.lat
# 	lon = map x, a.x,b.x, a.lon,b.lon
# 	{lat,lon,x,y}

# makeCorners = ->

# 	ac0 = vercal A,C,0  	                  # beräkna x
# 	ac1 = vercal A,C,HEIGHT
# 	bd0 = vercal B,D,0
# 	bd1 = vercal B,D,HEIGHT

# 	ab0 = hortal A,B,0                      # beräkna y
# 	ab1 = hortal A,B,WIDTH
# 	cd0 = hortal C,D,0
# 	cd1 = hortal C,D,WIDTH

# 	nw = corner ac0,bd0,ab0,cd0, 0,    0		# beräkna hörnen
# 	ne = corner ac0,bd0,ab1,cd1, WIDTH,0
# 	se = corner ac1,bd1,ab1,cd1, WIDTH,HEIGHT
# 	sw = corner ac1,bd1,ab0,cd0, 0,    HEIGHT

# 	gps = new GPS nw,ne,se,sw,WIDTH,HEIGHT

sayDistance = (a,b) -> # a is newer
	# if a border is crossed, play a sound
	for d in DISTLIST
		if (a-d) * (b-d) < 0
			voiceQueue.push 'distans ' + d
			return

sayBearing = (a,b) -> # a is newer
	# if a border is crossed, tell the new bearing
	a = ANGLE * Math.round a/ANGLE
	b = ANGLE * Math.round b/ANGLE
	if a == b then return
	if a == 0 then a = 360
	a = Math.round a / 10
	tr = 'nolla ett tvåa trea fyra femma sexa sju åtta nia'.split ' '
	c = tr[a // tr.length]
	d = tr[a %% tr.length]
	voiceQueue.push 'bäring ' + c + ' ' + d

soundIndicator = (p) ->

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

	if 10 > abs DIST * distance
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
	if gpsLat != 0 then position = w2b.convert gpsLon,gpsLat

	soundIndicator p

	gpsCount++
	messages[5] = gpsCount
	if currentControl == null then return

	if voiceQueue.length > 0

		msg = voiceQueue.shift()

		if 0 == msg.indexOf 'bearing'
			if msg != lastBearing
				lastBearing = msg
				say msg
		else
			arr = msg.split ' '
			if LIMIT > parseInt arr[1] then msg = arr[1]
			if msg != lastDistance
				lastDistance = msg
				say msg

	if recordingTrail
		if trail.length == 0
			trail.push position
		else
			[x1,y1] = _.last trail
			[x2,y2] = position
			if 12 < dist x1,y1,x2,y2 then trail.push position

	track.push position
	if track.length > TRACKED then track.shift()
	xdraw()
	position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['Check location permissions']

initSpeaker = (index=5) ->
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

setup = ->

	canvas = createCanvas innerWidth-0.5, innerHeight-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	platform = window.navigator.platform

	w = width/8
	h = height/4
	angleMode DEGREES

	WIDTH = img.width
	HEIGHT = img.height

	SCALE = 1/2
	[cx,cy] = [width,height]
	
	# makeCorners()
	b2w = new Converter bmp,wgs
	w2b = new Converter wgs,bmp

	x = width/2
	y = height/2
	x1 = 100
	x2 = width-100
	y1 = 100
	y2 = height-100

	getControls()

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

drawTrail = ->
	push()
	fc()
	sw 12
	sc 1,0,0,0.5 # RED
	translate width/2, height/2
	scale SCALE
	for [x,y] in trail
		point x-cx, y-cy
	pop()

drawControl = ->

	if trgLat == 0 and trgLon == 0 then return

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
	if state==0 
		textSize 200
		text VERSION, width/2,height/2
		return

	fc()
	image img, 0,0, width,height, cx-width/SCALE/2, cy-height/SCALE/2, width/SCALE, height/SCALE
	drawTrail()
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
	if key not of controls then return
	if controls[currentControl] == null then return
	trail = []
	recordingTrail = true
	say 'target: ' + key
	soundQueue = 0
	currentControl = key
	control = controls[currentControl]
	x = control[0]
	y = control[1]

	# [trgLat,trgLon] = gps.bmp2gps x,y
	[trgLon,trgLat] = b2w.convert x,y

	dialogues.clear()

executeMail = -> # Sends the trail
	littera = controls[currentControl][2]
	arr = ("[#{x},#{y}]" for [x,y] in trail)
	s = arr.join ",\n"
	sendMail "#{FILENAME} #{currentControl} #{littera}", s

##########################

Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

getBike = -> setTarget 'bike'

setBike = ->

	# [x,y] = gps.gps2bmp gpsLat,gpsLon
	[x,y] = w2b.convert gpsLon,gpsLat

	controls.bike = [x,y,'',gpsLat,gpsLon]
	dialogues.clear()

menu1 = -> # Main Menu
	dialogue = new Dialogue()
	dialogue.add 'Pan Zoom', -> menu2()
	dialogue.add 'Goto Bike', -> setTarget 'bike'
	dialogue.add 'Take', -> menu4()
	dialogue.add 'More', -> menu6()
	dialogue.add 'Center', ->
		[cx,cy] = position
		dialogues.clear()
		xdraw()
	dialogue.add 'Init', -> initSpeaker jcnindex++

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
	dialogue.add 'Mail', -> executeMail()
	dialogue.add 'Angle', -> menu7()
	dialogue.add 'Clear', ->
		clearControls()
		dialogues.clear()
	dialogue.clock()

menu7 = -> # Angle
	dialogue = new Dialogue()
	dialogue.add '10', -> setAngle 10
	dialogue.add '20', -> setAngle 20
	dialogue.add '30', -> setAngle 30
	dialogue.add '45', -> setAngle 45
	dialogue.add '60', -> setAngle 60
	dialogue.add '90', -> setAngle 90
	dialogue.clock()

setAngle = (angle) ->
	ANGLE = angle
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
	recordingTrail = false
	control = controls[currentControl]
	a = LatLon control[3],control[4]
	b = LatLon gpsLat, gpsLon

	# [x,y] = gps.gps2bmp gpsLat, gpsLon
	[x,y] = w2b.convert gpsLon, gpsLat

	controls[currentControl][index] = littera
	saveControls()
	dialogues.clear()
	executeMail()
	getBike()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

mouseReleased = ->
	released = true
	false

myMousePressed = (mx,my) ->
	if not released then return false
	released = false

	if state == 0
		initSpeaker()
		state = 1

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
