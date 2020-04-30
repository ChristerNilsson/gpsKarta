VERSION = 15
DELAY = 100 # ms, delay between sounds
DIST = 1 # meter. Movement less than DIST makes no sound 1=walk. 5=bike
LIMIT = 20 # meter. Under this, no bearing. Also distance voice every meter.
ANGLE = 20 # degrees. Bearing resolution.
NR = null # json file

# http://www.bvsok.se/Kartor/Skolkartor/
# Högupplösta orienteringskartor: https://www.omaps.net
# https://omaps.blob.core.windows.net/map-excerpts/1fdc587ffdea489dbd69e29b10b48395.jpeg Nackareservatet utan kontroller.

DISTLIST = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,30,40,50,60,70,80,90,100,120,140,160,180,200,250,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

trail = [	# insert bitmap points from mail here
	# 16
	# [3410,2885], [3415,2898], [3427,2890], [3440,2889], [3453,2887], [3468,2882], [3480,2879], [3495,2876], [3507,2873], [3519,2871], [3533,2868], [3548,2866], [3563,2865], [3575,2864], [3592,2859], [3610,2852], [3621,2842], [3636,2835], [3651,2830], [3664,2822], [3679,2820], [3697,2818], [3716,2818], [3736,2817], [3748,2814], [3768,2812], [3789,2807], [3800,2801], [3812,2793], [3821,2785], [3830,2775], [3841,2761], [3851,2747], [3860,2734], [3866,2720], [3873,2705], [3883,2690], [3895,2679], [3909,2669], [3922,2657], [3936,2640], [3952,2626], [3961,2618], [3972,2605], [3980,2593], [3988,2581], [3995,2591], [4004,2582], [4005,2595], [4012,2606], [4021,2615], [4023,2627], [4033,2636], [4039,2649], [4043,2661], [4041,2674], [4037,2686], [4026,2693], [4034,2702], [4045,2697], [4057,2688]  
	# 15
	# [4009,2596], [4010,2584], [4043,2576], [4058,2575], [4072,2574], [4089,2567], [4099,2559], [4111,2548], [4124,2539], [4153,2527], [4171,2522], [4182,2513], [4190,2502], [4197,2489], [4204,2478], [4212,2469], [4223,2464], [4240,2458], [4230,2465], [4224,2452], [4225,2440], [4223,2428], [4220,2414], [4212,2402], [4200,2389], [4192,2372], [4191,2357], [4190,2343], [4187,2326], [4183,2306], [4179,2291], [4177,2277], [4177,2263], [4174,2248], [4169,2235], [4165,2221], [4161,2207], [4154,2192], [4148,2176], [4140,2166], [4132,2134], [4127,2115], [4123,2100], [4113,2107], [4102,2112], [4089,2110], [4077,2109], [4064,2106], [4052,2113], [4039,2115], [4026,2118], [4014,2120], [4007,2131], [3986,2126], [3974,2129], [3962,2132], [3956,2143], [3962,2155] 
	# 3
	#[-1844.745302,6939.858144], [-1851.053971,6954.449413], [-1851.608178,6967.425995], [-1843.270118,6987.022503], [-1833.748693,6994.688128], [-1820.407793,6986.188343], [-1805.967332,6987.6458], [-1819.638895,6988.49175], [-1834.892808,6988.3982], [-1846.476778,6995.797544], [-1854.335532,7005.519032], [-1855.450408,6992.34605], [-1867.751747,6991.902327], [-1857.003406,6985.103531], [-1844.654428,6985.122732], [-1831.121866,6986.789308], [-1813.300319,6995.334013], [-1794.499204,7007.224932], [-1780.056977,7017.67295], [-1767.847431,7024.238634], [-1753.02801,7030.051519], [-1735.312995,7031.984442], [-1721.807174,7022.104397], [-1711.852706,7010.446134], [-1702.629043,6997.299659], [-1693.746337,6986.387017], [-1685.85006,6974.580545], [-1678.15385,6959.647791], [-1673.068404,6947.181649], [-1664.657306,6933.685268], [-1655.381033,6920.509477], [-1646.328719,6907.161689], [-1636.413629,6894.371915], [-1627.672952,6883.019025], [-1618.991086,6871.27395], [-1610.516034,6859.435014], [-1602.694486,6847.184518], [-1595.909635,6833.542065], [-1590.158681,6820.300358], [-1584.159304,6807.176544], [-1578.259063,6793.952828], [-1572.335303,6782.098803], [-1566.266169,6769.023807], [-1557.434129,6755.582912], [-1550.808624,6740.552022], [-1544.154514,6727.866064], [-1535.008152,6713.642937], [-1526.556903,6698.984219], [-1520.018016,6685.276466], [-1512.167001,6667.302989], [-1503.582895,6650.000262], [-1492.984321,6634.509228], [-1483.467453,6618.973406], [-1476.618989,6605.248288], [-1467.054198,6590.738035], [-1459.730178,6574.771536], [-1453.16534,6556.131965], [-1444.652822,6541.918026], [-1432.950911,6530.689058], [-1421.487706,6518.972534], [-1406.979596,6509.748139], [-1393.436911,6500.656994], [-1378.599847,6490.385891], [-1361.577137,6481.257741], [-1347.075512,6470.161755], [-1334.667543,6459.025011], [-1322.222425,6450.127257], [-1308.307836,6440.619768], [-1293.398443,6431.030113], [-1277.767188,6421.004484], [-1261.427304,6411.70371], [-1245.528308,6400.476612], [-1228.770621,6387.698513], [-1213.187176,6377.227351], [-1197.223054,6367.393976], [-1181.705394,6358.402977], [-1166.855928,6348.974877], [-1153.724584,6338.878547], [-1140.54923,6328.568823], [-1126.220012,6318.115282], [-1112.679842,6308.681525], [-1100.36798,6300.397654], [-1085.92157,6294.762438], [-1072.946976,6290.264401], [-1062.269132,6279.646552], [-1055.465963,6265.818513], [-1047.397222,6253.659614], [-1038.140039,6242.963257], [-1030.252193,6231.842762], [-1020.518828,6222.095222], [-1011.702136,6211.50267], [-1002.158837,6199.709276], [-992.197167,6187.338739], [-981.783662,6176.551157], [-970.761493,6168.392357], [-959.71329,6161.94586], [-952.618918,6147.996025], [-939.43419,6135.57653], [-925.733274,6128.427561], [-912.424323,6119.244064], [-894.345825,6109.028435], [-882.948284,6086.953925], [-875.558454,6075.861364], [-868.04117,6065.763546], [-858.181694,6056.404416], [-847.487192,6049.60864], [-840.688677,6030.771403], [-836.086501,6018.648755], [-823.367075,6017.065244], [-807.027484,6018.732563], [-794.193095,6023.074857], [-780.441375,6025.388278], [-766.06587,6026.322067], [-749.867021,6027.865453], [-732.256284,6028.433215], [-715.064145,6028.418048], [-696.678707,6029.680592], [-678.863329,6031.739713], [-664.294185,6034.218209], [-648.613673,6038.242667], [-632.10768,6046.070197], [-617.083129,6049.630502], [-601.799236,6046.611234], [-585.206535,6047.341561], [-569.824394,6046.136007], [-554.349718,6042.578726], [-538.178156,6036.029412], [-522.700534,6028.780786], [-508.567128,6018.180034], [-494.31338,6003.512234], [-480.338147,5991.259323], [-465.063279,5979.671751], [-454.863163,5972.692781], [-444.200146,5955.115252], [-435.451209,5942.20633], [-427.01945,5927.99692], [-418.39065,5913.961017], [-411.712078,5901.220955], [-404.078969,5888.981029], [-392.41175,5875.565665], [-382.91146,5862.851889], [-374.313096,5849.60866], [-367.144165,5835.232794], [-358.597753,5819.144997], [-350.769744,5802.411992], [-351.104972,5783.974896], [-359.703514,5721.548945], [-349.414209,5713.879467], [-334.655422,5710.019589], [-315.111709,5696.215154], [-305.656306,5673.010398], [-299.790381,5653.276311], [-290.498043,5634.668312], [-274.258229,5614.273244], [-264.392747,5598.11146], [-262.78381,5584.891158], [-256.929807,5572.988315], [-248.877814,5562.781408], [-239.486317,5550.627411], [-223.14155,5547.495906], [-203.241036,5556.055827], [-184.96034,5566.05125], [-169.393683,5576.014348], [-152.318232,5586.209203], [-132.959174,5597.910633], [-115.504389,5608.136941], [-98.580968,5616.81112], [-82.722564,5623.198501], [-66.336766,5629.609032], [-49.568777,5638.133736], [-31.857367,5646.631888], [-12.746357,5653.891449], [7.496799,5662.563979], [27.903417,5668.66988], [48.369735,5673.454154], [69.497817,5677.093955], [90.948937,5680.715636], [112.970718,5680.376838], [135.123583,5680.821655], [156.67264,5678.452858], [178.844483,5675.838204], [201.287638,5671.520935], [222.613452,5666.396275], [242.99556,5659.848076], [262.555443,5653.609653], [281.89991,5647.093292], [303.576796,5641.395263], [324.04698,5634.710297], [342.84825,5628.698984], [358.566433,5625.15441], [375.861481,5619.54397], [390.579433,5613.366212], [405.377086,5608.027682], [420.262814,5602.552384], [434.308885,5595.858635], [447.539446,5592.506326], [459.556988,5587.165542], [470.515545,5579.089407], [484.967496,5576.749577], [500.250845,5577.184229], [514.062866,5575.012122], [529.357078,5568.459288], [544.559211,5566.578325], [562.970828,5564.069124], [580.477833,5559.817805], [601.520672,5559.322993], [613.268097,5561.775203], [629.384242,5565.880688], [639.622499,5572.425117], [655.084536,5579.282945], [668.293857,5586.161669], [679.692236,5593.273799], [692.949138,5599.437983], [708.898417,5607.481298], [724.027644,5614.436891], [739.088229,5620.789926], [753.590472,5625.302324], [765.525106,5627.717668], [780.472665,5638.005513], [797.261145,5644.947134], [816.12611,5645.497276], [834.286644,5648.011617], [852.539566,5653.658278], [867.623702,5655.316921], [880.725376,5656.137601], [908.943451,5654.686644], [921.303749,5650.038505], [938.513579,5646.647553], [960.361838,5647.504939], [972.910371,5648.040259], [985.666832,5648.115701], [1002.582912,5650.568017], [1014.667185,5642.323277], [1002.60661,5640.389578], [986.907177,5639.714608], [974.935246,5640.544321], [968.825807,5629.075231], [969.981022,5617.119561], [967.783154,5603.585476], [974.179182,5591.441305], [973.103627,5579.109816], [961.377068,5570.750547], [948.370899,5570.240896], [948.373365,5557.875305], [942.962554,5546.050641], [929.52907,5544.19395], [916.302489,5536.657055], [914.577605,5520.248958], [902.727074,5516.167865] 
	# 1
	[-1848,6992], [-1834,6998], [-1830,7010], [-1834,6997], [-1822,6999], [-1810,6990], [-1822,6997], [-1810,6992], [-1821,6997], [-1833,6995], [-1843,6988], [-1855,6980], [-1867,6977], [-1873,6966], [-1866,6954], [-1848,6949], [-1835,6955], [-1808,6981], [-1796,6991], [-1787,6999], [-1772,7010], [-1761,7019], [-1747,7028], [-1726,7021], [-1713,7011], [-1706,6997], [-1698,6981], [-1692,6966], [-1687,6953], [-1680,6941], [-1673,6930], [-1665,6918], [-1657,6906], [-1651,6894], [-1645,6883], [-1632,6863], [-1626,6852], [-1621,6841], [-1614,6827], [-1606,6814], [-1594,6796], [-1582,6784], [-1573,6769], [-1568,6758], [-1562,6746], [-1554,6735], [-1545,6724], [-1535,6712], [-1528,6699], [-1521,6685], [-1514,6672], [-1506,6660], [-1497,6647], [-1490,6633], [-1483,6619], [-1477,6605], [-1469,6594], [-1459,6583], [-1451,6570], [-1441,6559], [-1429,6551], [-1416,6543], [-1405,6531], [-1392,6520], [-1377,6509], [-1364,6502], [-1351,6494], [-1339,6484], [-1325,6471], [-1313,6458], [-1301,6448], [-1292,6437], [-1283,6427], [-1270,6417], [-1256,6406], [-1241,6396], [-1227,6386], [-1212,6376], [-1198,6365], [-1184,6353], [-1170,6343], [-1157,6334], [-1146,6321], [-1131,6313], [-1119,6303], [-1105,6299], [-1090,6295], [-1079,6288], [-1069,6279], [-1062,6267], [-1053,6256], [-1043,6247], [-1033,6236], [-1024,6225], [-1014,6215], [-1005,6204], [-995,6193], [-984,6181], [-970,6171], [-959,6165], [-941,6151], [-933,6131], [-919,6127], [-911,6115], [-901,6099], [-891,6088], [-883,6077], [-876,6067], [-865,6052], [-851,6051], [-843,6029], [-829,6022], [-814,6025], [-800,6026], [-782,6028], [-763,6029], [-746,6030], [-731,6030], [-717,6031], [-703,6033], [-689,6034], [-674,6036], [-657,6038], [-638,6039], [-619,6040], [-603,6040], [-589,6039], [-575,6038], [-559,6034], [-543,6027], [-530,6018], [-516,6008], [-504,5997], [-494,5985], [-483,5975], [-473,5963], [-463,5951], [-452,5937], [-440,5921], [-426,5904], [-413,5893], [-401,5882], [-389,5871], [-380,5860], [-371,5850], [-363,5841], [-351,5825], [-348,5807], [-350,5793], [-354,5762], [-354,5745], [-351,5729], [-333,5698], [-324,5689], [-315,5681], [-307,5671], [-297,5659], [-289,5645], [-275,5613], [-258,5587], [-235,5552], [-213,5544], [-197,5545], [-182,5548], [-167,5554], [-153,5562], [-141,5571], [-127,5579], [-112,5590], [-95,5601], [-76,5613], [-57,5624], [-39,5635], [-20,5645], [-1,5654], [20,5662], [40,5670], [62,5677], [84,5684], [108,5687], [133,5689], [157,5689], [179,5684], [201,5679], [223,5672], [244,5665], [262,5658], [281,5651], [299,5642], [318,5632], [338,5624], [356,5619], [372,5614], [387,5610], [404,5608], [419,5606], [435,5603], [449,5601], [461,5600], [482,5592], [495,5584], [532,5579], [571,5576], [585,5568], [603,5563], [644,5566], [659,5572], [671,5579], [686,5591], [694,5600], [699,5611], [684,5620], [667,5624], [631,5628], [577,5642], [572,5654], [574,5667], [574,5692], [573,5714], [574,5727], [573,5740], [578,5751], [588,5766], [596,5781], [607,5793], [619,5805], [629,5815], [636,5826], [648,5828], [642,5855], [636,5890], [638,5913], [645,5925], [660,5949], [667,5960], [655,5962], [644,5967], [634,5976], [623,5984], [601,6000], [593,6009], [602,6021], [600,6038], [591,6051], [593,6065], [597,6078] 
]
recordingTrail = false

state = 0 # 0=uninitialized 1=initialized

spara = (lat,lon, x,y) -> {lat,lon, x,y}

data = null
img = null

b2w = null
w2b = null

controls = {}
clearControls = ->
	controls = data.controls
	[trgLat,trgLon] = [0,0]
	currentControl = null
	initControls()
	saveControls()

targets = [] # [id, littera, distance]
platform = null

saveControls = -> localStorage['gpsKarta'+NR] = JSON.stringify controls

getControls = ->
	try
		controls = JSON.parse localStorage['gpsKarta'+NR]
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
	mail.click()

say = (m) ->
	if speaker == null then return
	speechSynthesis.cancel()
	speaker.text = m
	speechSynthesis.speak speaker

preload = ->
	params = getParameters()
	NR = params.nr
	if NR == undefined then NR = 4
	loadJSON "data/#{NR}.json", (json) ->
		data = json
		for key,control of data.controls
			control.push ""
			control.push 0
			control.push 0
		img = loadImage "data/" + data.map

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
	#messages[4]	= soundQueue
	if soundQueue==0 then xdraw()

locationUpdate = (p) ->
	if gpsLat != 0 
		position = w2b.convert gpsLon,gpsLat
		messages[4] = myRound(gpsLon,6) + ' ' + myRound(gpsLat,6)

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
	sc 0 # BLACK
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

draw = -> xdraw()

xdraw = ->
	bg 0,1,0
	if state==0 
		textSize 200
		textAlign CENTER,CENTER
		text VERSION, width/2,height/2
		return

	#fc()

	push()
	translate width/2, height/2
	scale SCALE
	image img, -cx,-cy
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
	say 'target: ' + key
	soundQueue = 0
	currentControl = key
	control = controls[currentControl]
	x = control[0]
	y = control[1]
	[trgLon,trgLat] = b2w.convert x,y
	dialogues.clear()

executeMail = -> # Sends the trail
	littera = controls[currentControl][2]
	arr = ("[#{x},#{y}]" for [x,y] in trail)
	s = arr.join ",\n"
	sendMail "#{data.map} #{currentControl} #{littera}", s

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