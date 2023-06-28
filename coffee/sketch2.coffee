VERSION = 235

released = true
mapName = "" # t ex skarpnäck
params = null
# voices = null
#measure = {}
#surplus = 0
#pois = null
#speed = 1
#distbc = 0

start = new Date()

state = 0 # 0=uninitialized 1=normal 2=info

data = null

img = null

startX = 0
startY = 0

#crossHair = null
#lastTouchEnded = new Date() # to prevent double bounce in menus

fraction = (x) -> x - int x 
Array.prototype.clear = -> @length = 0
assert = (a, b, msg='Assert failure') -> chai.assert.deepEqual a, b, msg

# general = {COINS: true, DISTANCE: true, TRAIL: true, SECTOR: 10, PANSPEED : true}
#loadGeneral = -> if localStorage.gpsKarta then general = _.extend general, JSON.parse localStorage.gpsKarta
#saveGeneral = -> localStorage.gpsKarta = JSON.stringify general

# storage = null

[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

# gps = null
# position = null # gps position [x,y] # [lon,lat,alt,hhmmss]
#track = [] # five latest GPS positions (bitmap coordinates)

messages = ['','','','','','']

preload = ->
	params = getParameters()
	mapName = "2023-SommarS"
	# if params.debug then dump.active = params.debug == '1'
	loadJSON "data/#{mapName}.json", (json) ->
		data = json
		console.log 'adam',data
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map

locationUpdateFail = (error) ->	if error.code == error.PERMISSION_DENIED then messages = ['','','','','','Check location permissions']
# window.speechSynthesis.onvoiceschanged = -> voices = window.speechSynthesis.getVoices()

setup = ->
	canvas = createCanvas innerWidth-0.0, innerHeight #-0.5
	canvas.position 0,0 # hides text field used for clipboard copy.

	SCALE = data.scale

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
		push()
		translate width/2, height/2
		scale SCALE
		console.log round(-cx),round(-cy) 
		image img, round(-cx),round(-cy)
		pop()

touchStarted = (event) ->
	event.preventDefault()
	if not released then return
	#speed = 1
	released = false
	startX = mouseX
	startY = mouseY
	false

touchMoved = (event) ->
	event.preventDefault()
	if state == 1
		cx += (startX - mouseX)/SCALE
		cy += (startY - mouseY)/SCALE
		startX = mouseX
		startY = mouseY
	false

touchEnded = (event) ->
	event.preventDefault()
	if released then return
	released = true
	if state in [0,2]
		state = 1
		return false
	false
