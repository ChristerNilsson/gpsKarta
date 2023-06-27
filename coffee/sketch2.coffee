VERSION = 225

DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this value is no bearing given.

# platform = window.navigator.platform # Win32|iPad|Linux

# DIGITS = 'zero one two three four five six seven eight niner'.split ' '
#BR = if platform in ['Win32','iPad'] then "\n" else '<br>'
#BR = "\n"

# http://www.bvsok.se/Kartor/Skolkartor/
# Högupplösta orienteringskartor: https://www.omaps.net
# https://omaps.blob.core.windows.net/map-excerpts/1fdc587ffdea489dbd69e29b10b48395.jpeg Nackareservatet utan kontroller.

#DISTLIST = [0,2,4,6,8,10,12,14,16,18,20,30,40,50,60,70,80,90,100, 120,140,160,180,200,250,300,350,400,450,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

#lastStartX = 0
#lastStartY = 0

released = true
mapName = "" # t ex skarpnäck
params = null
voices = null
measure = {}
#surplus = 0
pois = null
speed = 1
distbc = 0

start = new Date()

state = 0 # 0=uninitialized 1=normal 2=info

data = null

img = null

startX = 0
startY = 0

crossHair = null
lastTouchEnded = new Date() # to prevent double bounce in menus

fraction = (x) -> x - int x 
Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

general = {COINS: true, DISTANCE: true, TRAIL: true, SECTOR: 10, PANSPEED : true}
#loadGeneral = -> if localStorage.gpsKarta then general = _.extend general, JSON.parse localStorage.gpsKarta
#saveGeneral = -> localStorage.gpsKarta = JSON.stringify general

storage = null

[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

gps = null
TRACKED = 5 # circles shows the user position
position = null # gps position [x,y] # [lon,lat,alt,hhmmss]
track = [] # five latest GPS positions (bitmap coordinates)

speaker = null

#soundUp = null
#soundDown = null
#soundQueue = 0 # integer neg=minskat avstånd pos=ökat avstånd

messages = ['','','','','','']
gpsCount = 0

[gpsLat,gpsLon] = [0,0] # avgör om muntlig information ska ges

timeout = null

voiceQueue = []
bearingSaid = '' # förhindrar upprepning
distanceSaid = '' # förhindrar upprepning

preload = ->
	params = getParameters()
	mapName = params.map || "2023-SommarS"
	# if params.debug then dump.active = params.debug == '1'
	loadJSON "data/#{mapName}.json", (json) ->
		data = json
		console.log 'adam',data
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map
	loadJSON "data/poi.json", (json) -> pois = json

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['','','','','','Check location permissions']
window.speechSynthesis.onvoiceschanged = -> voices = window.speechSynthesis.getVoices()

setup = ->
	canvas = createCanvas innerWidth-0.0, innerHeight #-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	angleMode DEGREES
	SCALE = data.scale

	dcs = data.controls
	bmp = [dcs.A[0], dcs.A[1], dcs.B[0], dcs.B[1], dcs.C[0], dcs.C[1]]
	abc = data.ABC
	wgs = [abc[1],abc[0],abc[3],abc[2],abc[5],abc[4]] # lat lon <=> lon lat

	[cx,cy] = [img.width/2,img.height/2]

draw = ->
	bg 0,1,0
	if state == 0 
		textSize 100
		textAlign CENTER,CENTER
		x = width/2
		y = height/2 
		text mapName, x,y-100
		text 'Version: '+VERSION, x,y
		text "Click to continue!", x,y+200
		return

	if state == 1
		#lastStartX = startX
		#lastStartY = startY
		push()
		translate width/2, height/2
		scale SCALE
		image img, -cx,-cy
		pop()

touchStarted = (event) ->
	#lastTouchStarted = new Date()
	event.preventDefault()
	if not released then return
	speed = 1
	released = false
	startX = mouseX
	startY = mouseY
	#lastStartX = startX
	#lastStartY = startY

	false

touchMoved = (event) ->
	event.preventDefault()
	if state == 1
		cx += speed * (startX - mouseX)/SCALE
		cy += speed * (startY - mouseY)/SCALE
		#lastStartX = startX
		#lastStartY = startY
		startX = mouseX
		startY = mouseY
	false

touchEnded = (event) ->
	event.preventDefault()

	# if (new Date()) - lastTouchEnded < 500
	# 	lastTouchEnded = new Date()
	# 	return # to prevent double bounce
	if released then return

	#lastStartX = startX
	#lastStartY = startY

	released = true
	if state in [0,2]
		state = 1
		return false
	false
