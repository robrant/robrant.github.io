# Raspberry Pi and GPS over Serial

I bought a small GPS Receiver (GP-20U7) to attach to a Particle Electron to create an ocean current tracker and/or real-time open water swim tracker. I haven’t got round to that yet, but I did have the time and inclination to attach it to my Raspberry Pi (B+).

<Photo of device with scale.>

I pretty much followed this post word for word because my GPIO/UART/Serial knowledge was non-existent at the time. It didn’t quite work for me because there have been reasonably significant OS changes since that post. I thought I’d capture how I got it to work and a list of things that might help others debug any problems.

## My Setup

* I’m using a Raspberry Pi B+, which has 40 GPIO pins rather than the older version.
* I’m running the minimal Jessie install: 2016-11-25-raspbian-jessie-lite.img.
* I use [https://github.com/robrant/pi-setup](this ansible playbook) to bootstrap my Pi. 

## Hardware

* Disconnect your Pi from power.

* I fitted 3 Male-Female jumper wires to the GPS, picking colours to match those on the GPS to save confusing my little brain. Extending the leads allowed me to connect the cables to pins distributed over the GPIO header without breaking up the 3-pin female end point provided with the GPS.

* I fitted the female ends of the jumper wires to pins 1, 6 and 10 of the Raspberry Pi. Here’s the mapping between GPS cables and Pi pin numbers and names.

Pi	Pi Pin #	Pi Pin Name		GPS
GND	Pin 6		Ground			GND
RX	Pin 10		GPIO15 / UART0_RXD	TX
3V	Pin 1		3V3 / Power		VCC

* Turned the Pi on.

* Moved the GPS next to a window with good sight of the sky.

