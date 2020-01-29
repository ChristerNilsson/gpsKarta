# Denna fil användes istället för sketch.coffee när man ska kalibrera en ny karta
# Klicka på tydliga referenspunkter i de fyra hörnen
# T ex vägskäl, hus, broar, kraftledningar, osv
# Avläs koordinaterna med tangent F12

img = null 
index = -1

preload = -> img = loadImage 'Solvik.PNG'
litteras = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20'.split ' '
points = 
	1: [604,6069]
	2: [1415,6153]
	3: [918,5525]
	4: [2157,5841]
	5: [1872,5261]
	6: [1430,4485]
	7: [2460,4629]
	8: [1828,4044]
	9: [1130,3042]
	10: [1371,2479]
	11: [1088,1656]
	12: [1669,1684]
	13: [2461,2092]
	14: [3503,1675]
	15: [3965,2167]
	16: [4064,2716]
	17: [3539,3097]
	18: [2724,3108]
	19: [3282,3697]
	20: [2676,4189]

setup = ->
	createCanvas img.width, img.height
	image img, 0,0, width,height
	print img
	fc()
	textSize 100
	textAlign CENTER,CENTER
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
	arr = ("\t#{key}: [#{value}]" for key,value of points)
	print "\n" + arr.join "\n"
	nextIndex()
