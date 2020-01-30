# Denna fil användes istället för sketch.coffee när man ska kalibrera en ny karta
# Klicka på tydliga referenspunkter i de tre hörnen
# T ex vägskäl, hus, broar, kraftledningar, osv
# Avläs koordinaterna med tangent F12

img = null
index = -1

preload = -> img = loadImage 'alviksskolan.png'
litteras = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20'.split ' '
points = []

setup = ->
	createCanvas img.width, img.height
	image img, 0,0, width,height
	print img
	fc()
	textSize 100
	#textAlign CENTER,CENTER
	nextIndex()

draw = ->	
	image img, 0,0, width,height
	fc()
	circle mouseX,mouseY,100
	if index of litteras
		fc 0
		text litteras[index],mouseX,mouseY

nextIndex = ->
	#while index==-1 or (index<litteras.length and points[litteras[index]])
	index++

mousePressed = ->
	x = round mouseX
	y = round mouseY
	console.log x,y,index,litteras[index]
	#if x < width and y < height
	points[litteras[index]] = [x, y]
	arr = ("\t\"#{key}\": [#{value}]," for key,value of points)
	print "\n" + arr.join "\n"
	nextIndex()
