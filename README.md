# 043-gpsKarta

## Digital orienteering.

Buy the paper map [here](http://www.skogsluffarna.se/Arrangemang/Naturpasset)

## Functionality

You see the map, controls and position all the time.
The size of the controls are rougly 100 meter.

* Center : Centers your position
* Left : Move your position left
* Right : Move your position right
* Up : Move your position up
* Down : Move your position down
* Out : Zooms ut
* In : Zooms in
* Vehicle : Saves current position.

Accuracy : Ten meters

Your position is shown with five black circles. The smallest circle is the most recent.

Stop screen rotation on Android like this:
* Settings
* Display
* When device is rotated: Stay in portrait view

## How To

* Connect your headphones.
* Choose Target
* Read the Bearing and turn your analog Compass house.
* Start walking in that direction.
* Modify the Compass when the voice speaks a new bearing.
* "Bearing Two Seven" => 270 degrees = West
* Distances are read now an then as "Distance One Hundred" (meter)
* Every meter closer to the target can be heard as a click.
* When distance is less than 20 meter, no Bearing is given. The Bearing is changing every second, when you are so close to the Target.

## Future Development

* Låt localStorage lagras i molnet vid wifikontakt (typ Google Photo)
* Då man går in på en annan enhet kopieras localStorage ner till den enheten (typ Google Photo)
* Fördelar: man kommer åt data insamlade på en annan enhet utan att behöva någon server.
* localStorage lagras per domän, per inloggad
* Konflikt om två olika enheter ändrar localStorage samtidigt.
* Alternativ: lagra i Google Sheets?