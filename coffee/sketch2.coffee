VERSION = 241

released = true
mapName = "" # t ex skarpnäck

start = new Date()

state = 0 # 0=uninitialized 1=normal 2=info

data = null

img = null

startX = 0
startY = 0

[cx,cy] = [0,0] # center (image coordinates)
SCALE = 1

preload = ->
	mapName = "2023-SommarS"
	loadJSON "data/#{mapName}.json", (json) ->
		data = json
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map

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
		start = new Date()
		push()
		translate width/2, height/2
		scale SCALE
		image img, round(-cx),round(-cy)
		pop()
		console.log new Date() - start

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
