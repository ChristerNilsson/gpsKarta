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
	1: [1830,333,'',0,0] 
	2: [1506,521,'',0,0]
	3: [907,711,'',0,0]
	4: [1193,873,'',0,0]
	5: [472,617,'',0,0]
	6: [228,841,'',0,0]
	7: [672,1013,'',0,0]
	8: [1125,1196,'',0,0]
	9: [1430,1290,'',0,0]
	10: [4361,503,'',0,0]
	11: [4118,1106,'',0,0]
	12: [3830,640,'',0,0]
	13: [3192,1133,'',0,0]
	14: [2664,873,'',0,0]
	15: [2322,1862,'',0,0]
	16: [4120,2699,'',0,0]
	17: [4181,3069,'',0,0]
	19: [3340,2904,'',0,0]
	20: [2691,2554,'',0,0]
	24: [3366,3217,'',0,0]
	26: [390,1935,'',0,0]
	27: [547,2143,'',0,0]
	28: [1462,2293,'',0,0]
	29: [1055,2620,'',0,0]
	30: [371,2502,'',0,0]
	31: [1090,3104,'',0,0]
	32: [2250,2750,'',0,0]

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
# buttons = []

speaker = null

img = null 
soundUp = null
soundDown = null
soundQueue = 0 # neg=minskat avstånd pos=ökat avstånd

messages = ['','','','','']

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
	mail.href = "mailto:#{MAIL}?Subject=#{subject}&body=#{body}"
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

#showSpeed = (sp) -> # buttons[0].prompt = myround sp, 1

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
	soundIndicator p

	position = gps.gps2bmp gpsLat,gpsLon

	track.push position
	if track.length > TRACKED then track.shift()
	xdraw()
	position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['Check location permissions']

initSpeaker = (index) ->
	speaker = new SpeechSynthesisUtterance()
	voices = speechSynthesis.getVoices()
	speaker.voice = voices[index]	
	speaker.voiceURI = "native"
	speaker.volume = 1
	speaker.rate = 0.8
	speaker.pitch = 0.8
	speaker.text = 'Välkommen!'
	speaker.lang = 'sv-SE'
	dialogues.clear()

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

	# buttons.push new Button 'S',x1,y1, -> # Store Bike Position
	# 	initSpeaker()
	# 	soundUp = loadSound 'soundUp.wav'
	# 	soundDown = loadSound 'soundDown.wav'
	# 	soundUp.setVolume 0.1
	# 	soundDown.setVolume 0.1
	# 	controls['bike'] = position
	# 	buttons[2].prompt = 'bike'
	# 	clearInterval timeout
	# 	timeout = setInterval playSound, DELAY
	# 	soundQueue = 0

	# buttons.push new Button 'U',x,y1, -> cy -= 0.33*height/SCALE 
	# buttons.push new Button '',x2,y1, -> setTarget 'bike'

	# buttons.push new Button 'L',x1,y, -> cx -= 0.33*width/SCALE
	# buttons.push new Button '', x,y, ->	[cx,cy] = position

	# buttons.push new Button 'R',x2,y, -> cx += 0.33*width/SCALE
	# buttons.push new Button '-',x1,y2, -> if SCALE > 0.5 then SCALE /= 1.5
	# buttons.push new Button 'D',x,y2, -> cy += 0.33*height/SCALE
	# buttons.push new Button '+',x2,y2, ->	SCALE *= 1.5

	# buttons.push new Button 'T',(x+x2)/2,(y+y2)/2, ->
	# 	d = new Date()
	# 	sendMail currentControl, "#{currentControl} #{gpsLat} #{gpsLon} #{d.toISOString()}"

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
	messages[0] = currentControl
	messages[1] = "#{int bearing}º"
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
	fc 1,1,0
	sc 0
	sw 3
	for message,i in messages
		text message,50,100*(i+1)
	showDialogue()

setTarget = (key) ->
	if controls[currentControl] == null then return
	soundQueue = 0
	currentControl = key
	control = controls[currentControl]
	x = control[0]
	y = control[1]
	[trgLat,trgLon] = gps.bmp2gps x,y	

#myMousePressed = (mx,my) ->
	# for button in buttons
	# 	if button.contains mx,my
	# 		button.click()
	# 		xdraw()
	# 		return
	# arr = ([dist(cx-width/SCALE/2 + mx/SCALE, cy-height/SCALE/2+my/SCALE, control[0], control[1]), key] for key,control of controls)
	# closestControl = _.min arr, (item) -> item[0]
	# [d,key] = closestControl
	# if d < 85
	# 	setTarget key
	# 	xdraw()

# only for debug on laptop
#mousePressed = -> myMousePressed mouseX,mouseY

##########################

Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

menu1 = -> # Main Menu
	dialogue = new Dialogue 1,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,true,90+360/5

	dialogue.buttons[0].info 'Take', true, -> menu4()
	dialogue.buttons[1].info 'Target', true, -> menu3()
	dialogue.buttons[2].info 'PanZoom', true, -> menu2()
	dialogue.buttons[3].info 'Center', true, -> 
		[cx,cy] = position
		dialogues.clear()	
		xdraw()	
	dialogue.buttons[4].info 'Speaker', true, -> menu10() 

menu2 = -> # Pan Zoom
	dialogue = new Dialogue 2,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.09 * height
	dialogue.clock ' ',8,r1,r2,false,45+360/8

	dialogue.buttons[0].info 'Up', true, -> cy -= 0.33*height/SCALE  
	dialogue.buttons[1].info 'Restore', true, -> 
		setTarget 'bike'
		dialogues.clear()
	dialogue.buttons[2].info 'Right', true, -> cx += 0.33*width/SCALE
	dialogue.buttons[3].info 'Out', true, -> if SCALE > 0.5 then SCALE /= 1.5
	dialogue.buttons[4].info 'Down', true, -> cy += 0.33*height/SCALE
	dialogue.buttons[5].info 'In', true, -> SCALE *= 1.5
	dialogue.buttons[6].info 'Left', true, -> cx -= 0.33*width/SCALE
	dialogue.buttons[7].info 'Save', true, -> dialogues.clear()

menu3 = -> # Target
	targets = makeTargets()
	lst = targets.slice()
	lst = lst.sort (a,b) -> a[2] - b[2]
	dialogue = new Dialogue 3, 0,0, int(0.15*h)
	dialogue.list lst, 8, false, (arr) ->
		if arr.length == 0 then return
		currentControl = arr[0]
		dialogues.clear()		

menu4 = -> # Take
	dialogue = new Dialogue 4,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,false,55+360/5

	dialogue.buttons[0].info 'ABCDE', true, -> menu5()
	dialogue.buttons[1].info 'FGHIJ', true, -> menu6()
	dialogue.buttons[2].info 'KLMNO', true, -> menu7()
	dialogue.buttons[3].info 'PQRST', true, -> menu8()
	dialogue.buttons[4].info 'UVWXYZ', true, -> menu9()

update = (littera,index=2) ->
	d = new Date()
	sendMail currentControl, "#{currentControl} #{littera} #{gpsLat} #{gpsLon} #{d.toISOString()}"
	controls[currentControl][index] = littera
	dialogues.clear()

menu5 = -> # ABCDE
	dialogue = new Dialogue 5,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,false,55+360/5

	dialogue.buttons[0].info 'A', true, -> update 'A'
	dialogue.buttons[1].info 'B', true, -> update 'B'
	dialogue.buttons[2].info 'C', true, -> update 'C'
	dialogue.buttons[3].info 'D', true, -> update 'D'
	dialogue.buttons[4].info 'E', true, -> update 'E'

menu6 = -> # FGHIJ
	dialogue = new Dialogue 6,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,false,55+360/5

	dialogue.buttons[0].info 'F', true, -> update 'F'
	dialogue.buttons[1].info 'G', true, -> update 'G'
	dialogue.buttons[2].info 'H', true, -> update 'H'
	dialogue.buttons[3].info 'I', true, -> update 'I'
	dialogue.buttons[4].info 'J', true, -> update 'J'

menu7 = -> # KLMNO
	dialogue = new Dialogue 7,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,false,55+360/5

	dialogue.buttons[0].info 'K', true, -> update 'K'
	dialogue.buttons[1].info 'L', true, -> update 'L'
	dialogue.buttons[2].info 'M', true, -> update 'M'
	dialogue.buttons[3].info 'N', true, -> update 'N'
	dialogue.buttons[4].info 'O', true, -> update 'O'

menu8 = -> # PQRST
	dialogue = new Dialogue 8,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height
	r2 = 0.11 * height
	dialogue.clock ' ',5,r1,r2,false,55+360/5

	dialogue.buttons[0].info 'P', true, -> update 'P'
	dialogue.buttons[1].info 'Q', true, -> update 'Q'
	dialogue.buttons[2].info 'R', true, -> update 'R'
	dialogue.buttons[3].info 'S', true, -> update 'S'
	dialogue.buttons[4].info 'T', true, -> update 'T'

menu9 = -> # UVWXYZ
	dialogue = new Dialogue 9,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.25 * height 
	r2 = 0.11 * height
	dialogue.clock ' ',6,r1,r2,false,60+360/6

	dialogue.buttons[0].info 'U', true, -> update 'U'
	dialogue.buttons[1].info 'V', true, -> update 'V'
	dialogue.buttons[2].info 'W', true, -> update 'W'
	dialogue.buttons[3].info 'X', true, -> update 'X'
	dialogue.buttons[4].info 'Y', true, -> update 'Y'
	dialogue.buttons[5].info 'Z', true, -> update 'Z'

menu10 = -> # speaker
	dialogue = new Dialogue 10,int(4*w),int(2*h),int(0.15*h) 

	r1 = 0.27 * height 
	r2 = 0.08 * height
	dialogue.clock ' ',10,r1,r2,false,60+360/10

	dialogue.buttons[0].info '0', true, -> initSpeaker 0
	dialogue.buttons[1].info '1', true, -> initSpeaker 1
	dialogue.buttons[2].info '2', true, -> initSpeaker 2
	dialogue.buttons[3].info '3', true, -> initSpeaker 3
	dialogue.buttons[4].info '4', true, -> initSpeaker 4
	dialogue.buttons[5].info '5', true, -> initSpeaker 5
	dialogue.buttons[6].info '6', true, -> initSpeaker 6
	dialogue.buttons[7].info '7', true, -> initSpeaker 7
	dialogue.buttons[8].info '8', true, -> initSpeaker 8
	dialogue.buttons[9].info '9', true, -> initSpeaker 9


display = -> xdraw()

showDialogue = -> if dialogues.length > 0 then (_.last dialogues).show()

mouseReleased = ->
	released = true
	false

myMousePressed = (mx,my) -> 

	if not released then return false
	released = false 

	# if speaker == null 
	# 	initSpeaker()
	# 	return false

	if dialogues.length == 1 and dialogues[0].number == 0 then dialogues.pop() # dölj indikatorer

	dialogue = _.last dialogues
	if dialogues.length == 0 or not dialogue.execute mx,my 
		if dialogues.length == 0 then menu1() else dialogues.pop()
		display()
		return false

	display()
	false 

# mousePressed = -> myMousePressed mouseX,mouseY
