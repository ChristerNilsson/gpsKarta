# gpsKarta

## Digital orienteering

* [Orienteering](https://en.wikipedia.org/wiki/Orienteering)
* [Naturpasset](https://www.facebook.com/Naturpasset.Nackareservatet)
* [Compass](https://en.wikipedia.org/wiki/Compass)

Buy the paper map [here](http://www.skogsluffarna.se/Arrangemang/Naturpasset)

## Functionality

You see the map, controls and position all the time.
The size of the controls are roughly 100 meter.

* Speaker (Starts the speaker)
* Center (centers your position)
* Pan Zoom
	* Left (Move your position left)
	* Right (Move your position right)
	* Up (Move your position up)
	* Down (Move your position down)
	* Out (Zooms out)
	* In (Zooms in)
* Store Bike (stores starting position)
* Goto Bike (sets target to starting position)
* Target (choose target)
* Take (marks a target with littera)
	* ABCDE
	* FGHIJ
	* KLMNO
	* PQRST
	* UVWXYZ
* Mail (sends data in a mail)

Accuracy : Approx ten meters

Your position is shown with five black circles. The smallest circle is the most recent.

Stop screen rotation on Android like this:
* Settings
* Display
* When device is rotated: Stay in portrait view

Allow the app to work even if your phone is turned off
* Settings
* Apps & notifications
* Special app access
* Unrestricted data access
* Chrome On

## How To

* Connect your headphones.
* Click on Speaker
* Set Bike
* Choose Target
* If you have a compass
	* When the Bearing changes, turn your analog Compass house.
	* "Bearing Two Seven" => 270 degrees = West
	* Start walking in that direction.
* Distances are read now and then as "Distance One Hundred" (meter)
* Every meter closer to the target can be heard as a coin drop.
* Every meter lost to the target can be heard as a small explosion.
* When distance is less than twenty meter, no Bearing is given. The Bearing is changing very often, when you are so close to the Target.
* Click on take when you have found your target
* Goto Bike

## Methods

* 1. Listen to bearings and use a compass. Most efficient method.
* 2. Listen to distance indicating sounds (coins and explosions)
* 3. Look at the map on the screen and the five circles.

## Future Development

* Låt localStorage lagras i molnet vid wifikontakt (typ Google Photo)
* Då man går in på en annan enhet kopieras localStorage ner till den enheten (typ Google Photo)
* Fördelar: man kommer åt data insamlade på en annan enhet utan att behöva någon server.
* localStorage lagras per domän, per inloggad
* Konflikt om två olika enheter ändrar localStorage samtidigt.
* Alternativ: lagra i Google Sheets?