VERSION = 40
DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this value is no bearing given.
SECTOR = 10 # Bearing resolution in degrees
MAP = null # json file
DIGITS = 'nolla ett tvåa trea fyra femma sexa sju åtta nia'.split ' '

# http://www.bvsok.se/Kartor/Skolkartor/
# Högupplösta orienteringskartor: https://www.omaps.net
# https://omaps.blob.core.windows.net/map-excerpts/1fdc587ffdea489dbd69e29b10b48395.jpeg Nackareservatet utan kontroller.

DISTLIST = [0,2,4,6,8,10,12,14,16,18,20,30,40,50,60,70,80,90,100,120,140,160,180,200,250,300,350,400,450,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

trail = [	# insert bitmap points from mail here
	# [840,957], [842,943], [844,931], [855,925], [851,913], [842,903], [834,893], [828,882], [832,870], [833,858], [827,847], [818,839], [807,832], [800,822], [794,811], [787,801], [779,792], [767,787], [767,774], [767,760], [762,747], [754,738], [754,725], [754,711], [757,699], [756,687], [754,674], [754,661], [759,650], [757,638], [753,626], [746,615], [741,604], [741,591], [739,578], [738,566], [737,554], [734,542], [724,533], [714,525], [703,520], [691,516], [684,506], [684,493], [675,485], [672,473], [676,461], [680,449], [683,437], [686,425], [691,413], [692,401], [693,389], # A
	# [694,382], [699,371], [706,360], [714,351], [726,347], [737,340], [749,339], [763,339], [775,340], [787,336], [800,336], [812,335], [822,328], [828,317], [836,308], [848,304], [860,303], [867,293], [872,282], [873,270], [883,262], [896,257], [908,253], [920,251], [932,247], [938,236], [947,227], # B
	# [946,224], [956,233], [967,238], [978,245], [988,252], [996,262], [1007,268], [1017,276], [1027,283], [1040,286], [1052,284], [1064,285], [1077,285], [1089,288], [1102,289], [1111,297], [1121,290], [1130,282], [1143,283], [1156,280], [1168,274], [1179,269], [1191,268], [1203,266], [1215,268], [1226,273], [1239,273], [1250,279], [1263,280], [1268,291], [1279,286], [1291,283], [1300,275], [1312,271], [1323,266], [1333,273], [1346,273], [1359,269], [1372,272], [1382,279], [1394,281], [1407,280], [1416,288], # C
	# [1417,285], [1429,287], [1440,293], [1451,299], [1459,309], [1471,313], [1484,313], [1496,314], [1508,318], [1517,310], [1528,315], [1540,317], [1552,316], [1564,317], [1575,322], [1587,326], [1599,330], [1611,327], [1621,319], [1633,314], [1644,320], [1652,330], [1663,335], [1676,335], [1688,337], [1701,337], [1713,338], [1725,342], [1737,343], [1749,342], [1760,347], [1773,352], [1784,358], [1796,361], [1808,365], [1821,365], [1834,365], [1846,367], [1858,369], [1870,368], [1882,364], [1893,369], [1903,376], [1910,386], [1923,386], [1934,391], [1944,398], [1955,403], [1966,409], [1978,413], [1989,418], [2001,420], [2011,427], [2020,435], [2032,433], [2043,439] , # D
	# [2063,437], [2067,449], [2070,462], [2071,474], [2078,484], [2077,496], [2071,508], [2076,519], [2078,532], [2081,544], [2083,556], [2085,568], [2084,580], [2084,594], [2087,606], [2088,618], [2092,630], [2089,642], [2076,643], [2079,655], [2083,667], [2085,679], [2077,688], [2066,693], [2057,701], [2050,711], [2047,723], [2048,736], [2047,748], [2044,760], [2036,769], [2034,781], [2029,792], [2025,804], [2023,816], [2020,829], [2016,841], [2014,853], [2009,865], [1997,870], [1988,878], [1984,890], [1977,901], [1974,914], [1967,925], [1964,938], [1961,950], [1956,962], [1948,971], [1936,976], [1923,980], [1915,989], [1908,999], [1896,1004], [1883,1002], [1870,1003], [1857,1006], [1850,1016], [1851,1028], [1844,1039], [1835,1048], [1836,1060] , # E
	# [1845,1072], [1844,1085], [1842,1097], [1830,1103], [1820,1110], [1809,1117], [1798,1123], [1786,1125], [1774,1126], [1762,1125], [1750,1129], [1738,1134], [1726,1133], [1723,1145], [1712,1150], [1702,1158], [1692,1166], [1686,1177], [1675,1183], [1666,1192], [1654,1195], [1665,1201], [1660,1213], [1664,1225], [1668,1237], [1670,1249], [1660,1256], [1647,1256], [1635,1259], [1623,1263], [1611,1267], [1601,1274], [1588,1276], [1576,1273], [1565,1278], [1554,1283], [1542,1281] , # F
	# [1533,1269], [1521,1272], [1513,1282], [1508,1294], [1508,1310], [1499,1318], [1488,1323], [1477,1329], [1466,1334], [1456,1342], [1449,1353], [1441,1363], [1429,1365], [1420,1373], [1407,1374], [1395,1377], [1382,1380], [1370,1374], [1361,1382], [1349,1385], [1336,1384], [1324,1389], [1312,1391], [1300,1393], [1288,1394], [1276,1393], [1267,1402], [1255,1398], [1247,1407], [1235,1412], [1229,1423], [1223,1435], [1222,1447], [1216,1458], [1211,1469], [1203,1479], [1205,1491], [1200,1502], [1192,1511], [1182,1519], [1171,1524], [1159,1519], [1149,1511], [1145,1498], [1138,1487], [1126,1483], [1114,1480], [1105,1472], [1094,1477], [1082,1481], [1074,1490] # G
]
recordingTrail = false


state = 0 # 0=uninitialized 1=initialized

spara = (lat,lon, x,y) -> {lat,lon, x,y}

data = null
img = null

b2w = null
w2b = null

controls = {}

mailDump = []
dump = (msg) -> 
	console.log msg
	mailDump.push msg

clearControls = ->
	controls = data.controls
	[trgLat,trgLon] = [0,0]
	currentControl = null
	initControls()
	saveControls()

targets = [] # [id, littera, distance]
platform = null

saveControls = -> localStorage['gpsKarta'+MAP] = JSON.stringify controls

getControls = ->
	try
		controls = JSON.parse localStorage['gpsKarta'+MAP]
	catch
		clearControls()

initControls = ->
	for key,control of controls
		[x,y,littera] = control
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

[cx,cy] = [0,0] # center (image coordinates)
SCALE = null

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

[gpsLat,gpsLon] = [0,0]
[trgLat,trgLon] = [0,0]
currentControl = null

timeout = null

voiceQueue = []
lastBearing = ''
lastDistance = ''

released = true

sendMail = (subject,body) ->
	mail.href = encodeURI "mailto:#{data.mail}?subject=#{subject}&body=#{body}"
	#console.log mail.href
	mail.click()

say = (m) ->
	if speaker == null then return
	speechSynthesis.cancel()
	speaker.text = m
	dump "say #{m} #{JSON.stringify voiceQueue}"
	speechSynthesis.speak speaker
	m

preload = ->
	params = getParameters()
	MAP = params.map || 'skarpnäck'
	loadJSON "data/#{MAP}.json", (json) ->
		data = json
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map

sayDistance = (a,b) -> # a is newer (meter)
	# if a border is crossed, produce speech
	dump "sayDistance #{a} #{b}"
	if b == -1 then return a
	for d in DISTLIST
		if (a-d) * (b-d) <= 0 then return d

sayBearing = (a0,b0) -> # a is newer (degrees)
	dump "sayBearing #{a0} #{b0}"
	# if a sector limit is crossed, tell the new bearing
	a = SECTOR * Math.round a0/SECTOR
	b = SECTOR * Math.round b0/SECTOR
	if a == b and b0 != -1 then return # samma sektor
	a = Math.round a / 10
	if a == 0 then a = 36 # 01..36
	tiotal = DIGITS[a // 10]
	ental = DIGITS[a %% 10]
	"#{tiotal} #{ental}"
	#console.log JSON.stringify voiceQueue

soundIndicator = (p) ->
	dump "soundIndicator #{p.coords.latitude} #{p.coords.longitude}"
	a = LatLon p.coords.latitude,p.coords.longitude # newest
	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	dista = Math.round a.distanceTo c
	distb = Math.round b.distanceTo c
	distance = Math.round (dista - distb)/DIST

	if trgLat != 0
		bearinga = a.bearingTo c
		bearingb = b.bearingTo c
		if dista >= LIMIT 
			sBearing = sayBearing bearinga,bearingb
			if sBearing then voiceQueue.push "bäring #{sBearing}" 
		sDistance = sayDistance dista,distb
		if sDistance then voiceQueue.push "distans #{sDistance}" 

	if distance != 0 # update only if DIST detected. Otherwise some beeps will be lost.
		gpsLat = p.coords.latitude
		gpsLon = p.coords.longitude

	if abs(distance) < 10 then soundQueue = distance # ett antal DIST

firstInfo = ->

	#console.log 'firstInfo',trgLat,trgLon,gpsLat,gpsLon
	#a = LatLon p.coords.latitude,p.coords.longitude # newest

	b = LatLon gpsLat, gpsLon
	c = LatLon trgLat, trgLon # target

	#	dista = Math.round a.distanceTo c
	distb = Math.round b.distanceTo c
	distance = Math.round (distb)/DIST

	#console.log b,c,distb,distance

	if trgLat != 0
		bearingb = b.bearingTo c
		dump "gps #{[gpsLat,gpsLon]}" 
		dump "trg #{[trgLat,trgLon]}"
		dump "target #{currentControl}"
		voiceQueue.push "bäringDistans #{sayBearing bearingb,-1}. #{sayDistance distb,-1}"

		#bearinga = a.bearingTo c
		dump "voiceQueue #{voiceQueue}"
	
	#if distance != 0 # update only if DIST detected. Otherwise some beeps will be lost.
	#	gpsLat = p.coords.latitude
	#	gpsLon = p.coords.longitude

	if abs(distance) < 10 then soundQueue = distance # ett antal DIST

playSound = ->
	if soundQueue == 0 then return
	if soundQueue < 0 and soundDown != null
		soundQueue++
		soundDown.play()
	else if soundQueue > 0 and soundUp != null
		soundQueue--
		soundUp.play()
	#messages[4]	= soundQueue
	if soundQueue==0 then xdraw()

locationUpdate = (p) ->
	dump "locationUpdate #{p.coords.latitude} #{p.coords.longitude}"
	if gpsLat != 0
		position = w2b.convert gpsLon,gpsLat
		track.push position
		if track.length > TRACKED then track.shift()
		dump "track #{JSON.stringify track}"
		messages[4] = myRound(gpsLon,6) + ' ' + myRound(gpsLat,6)

	soundIndicator p

	gpsCount++
	messages[5] = gpsCount

	if currentControl == null then return

	if voiceQueue.length > 0

		msg = voiceQueue.shift()
		arr = msg.split ' ' 

		if arr[0] == 'bäring'
			msg = arr[1] + ' ' + arr[2] # skippa ordet. t ex 'bäring etta tvåa'
			if msg != lastBearing then lastBearing = say msg # Upprepa aldrig
		if arr[0] == 'distans'
			msg = arr[1]                # skippa ordet. t ex 'distans 30'
			if msg != lastDistance then lastDistance = say msg # Upprepa aldrig
		if arr[0] == 'bäringDistans'
			msg = arr[1] + ' ' + arr[2] + ' ' + arr[3] # skippa ordet. t ex 'bäringDistans etta tvåa tvåhundra'
			# if msg != lastBearing then lastBearing = say msg 
			say msg 

	if recordingTrail
		if trail.length == 0
			trail.push position
		else
			[x1,y1] = _.last trail
			[x2,y2] = position
			if 12 < dist x1,y1,x2,y2 then trail.push position

	#xdraw()
	#position

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['Check location permissions']

initSpeaker = (index=5) ->
	dump "initSpeaker in #{index}"
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
	dump "initSpeaker out"

setup = ->

	canvas = createCanvas innerWidth-0.0, innerHeight #-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	platform = window.navigator.platform

	angleMode DEGREES

	SCALE = data.scale

	[cx,cy] = [img.width/2,img.height/2]
	
	b2w = new Converter data.bmp,data.wgs,6
	w2b = new Converter data.wgs,data.bmp,0

	getControls()

	position = [img.width/2,img.height/2]

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
	fc()
	sw 4
	sc 0
	for [x,y],i in track
		circle x-cx, y-cy, 10 * (track.length-i)

drawTrail = ->
	fc()
	sw 12
	sc 1,0,0,0.5 # RED
	for [x,y] in trail
		point x-cx, y-cy

drawControls = ->
	textAlign LEFT,TOP
	textSize data.radius
	sw 2
	for key,control of data.controls
		[x,y] = control
		sc 0
		fc()
		circle x-cx,y-cy,data.radius
		sc()
		fc 0
		text key,x-cx+0.7*data.radius,y-cy+0.7*data.radius

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

	sc()
	fc 0,0,0,0.25
	circle x-cx, y-cy, data.radius

drawReferencePoints = ->
	push()
	textAlign CENTER,CENTER
	textSize 20
	for i in range 3
		p = w2b.convert data.wgs[2*i], data.wgs[2*i+1]
		sw 1
		fc()
		sc 0
		circle data.bmp[2*i]-cx,data.bmp[2*i+1]-cy,9
		circle p[0]-cx, p[1]-cy, 12
		sw 2
		fc 0
		sc()
		text i, data.bmp[2*i]-cx,1.5+data.bmp[2*i+1]-cy
	pop()

draw = -> xdraw()

xdraw = ->
	bg 0,1,0
	if state==0 
		textSize 200
		textAlign CENTER,CENTER
		text MAP, width/2,height/2-200
		text VERSION, width/2,height/2
		return

	#fc()

	push()
	translate width/2, height/2
	scale SCALE
	image img, -cx,-cy
	drawReferencePoints()
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

setTarget = (key) ->
	if key not of controls then return
	if controls[currentControl] == null then return
	trail = []
	recordingTrail = true
	soundQueue = 0
	currentControl = key
	control = controls[currentControl]
	x = control[0]
	y = control[1]
	[trgLon,trgLat] = b2w.convert x,y
	say 'target: ' + key
	firstInfo()
	dialogues.clear()

executeMail = -> # Sends the trail
	if currentControl 
		littera = controls[currentControl][2]
		arr = ("[#{x},#{y}]" for [x,y] in trail)
		s = arr.join ",\n"
	else
		s = ""
	r = mailDump.join "xxx"
	mailDump = []
	sendMail "#{data.map} #{currentControl} #{littera}", r + s

Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

getBike = -> setTarget 'bike'

setBike = ->
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
	dialogue.add 'Up', -> cy -= height/SCALE/3
	dialogue.add ' ', -> # Not Used
	dialogue.add 'Right', -> cx += width/SCALE/3
	dialogue.add 'Out', -> if SCALE > data.scale then SCALE /= 1.5
	dialogue.add 'Down', -> cy += height/SCALE/3
	dialogue.add 'In', -> SCALE *= 1.5
	dialogue.add 'Left', -> cx -= width/SCALE/3
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
	dialogue.add 'Sector', -> menu7()
	dialogue.add 'Clear', ->
		clearControls()
		dialogues.clear()
	dialogue.clock()

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
	recordingTrail = false
	control = controls[currentControl]
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

# mouseMoved = ->
# 	messages[3] = myRound(mouseX/SCALE) + ' ' + myRound(mouseY/SCALE)