---
layout: post
title: "Raspberry Pi and GPS"
date: 2017-02-06 15:30
categories: Raspberry Pi, GPS
tags:
    - Rasberry Pi
    - GPS
    - Peripherals
    - Jessie
author: "Rich Brantingham"
---

## Background

I bought a small GPS Receiver (GP-20U7) to attach to a Particle Electron to
create an ocean current tracker and/or real-time open water swim tracker.
I haven’t got round to that yet, but I did have the time and inclination to
attach it to my Raspberry Pi (B+).

<div class='image aside'>
  <img src='/images/gps_penny_scale.png'>
  _The GP-20U7 and a Penny._
</div>

I pretty much followed [this post][nationpigeon].
word for word because my GPIO/UART/Serial knowledge was non-existent at the time.
It didn’t quite work for me because there have been Raspbian OS changes since
that post. I thought I’d capture how I got it to work and a list of things that
might help others debug any problems.

## My Setup:

*   I’m using a Raspberry Pi B+, which has 40 GPIO pins rather than the older version.
*   I’m running the minimal Jessie install: `2016-11-25-raspbian-jessie-lite.img`.
*   I use this [ansible scripts][pi-setup-repo] to bootstrap my Pi.

## Hardware

* Disconnect your Pi from the power.

* I fitted 3 Male-Female jumper wires to the GPS, picking colours to match those
on the GPS to save confusing my little brain. Extending the leads allowed me to
connect the cables to pins distributed over the GPIO header without breaking up
the 3-pin female end point provided with the GPS.

*   I fitted the female ends of the jumper wires to pins 1, 6 and 10 of the
Raspberry Pi. Here’s the mapping between GPS cables and Pi pin numbers and names.


| Pi  | Pi Pin # | Pi Pin Name        | GPS |
|-----|----------|--------------------|-----|
| GND | Pin 6    | Ground             | GND |
| RX  | Pin 10   | GPIO15 / UART0_RXD | TX  |
| 3V  | Pin 1    | 3V3 / Power        | VCC |

<div class='image aside'>
  <img src='/images/gps_extension_jumpers.jpg'>
  _GPS wiring on the GPIO_
</div>


<div class='image aside'>
  <img src='/images/gps_gpio_pins.jpg'>
  _GPS GPIO Pin Configuration_
</div>


* Move the GPS next to a window with good sight of the sky.

* Power on the Pi.

## What Worked For Me:

**Download GPS Daemon and clients**

```
$> sudo apt-get install gpsd gpsd-clients
```

## Configure Serial Correctly

The RPI comes with the serial pins bound to a TTY terminal. This lets you
plug it into a USB-TTL cable and use screen to control the PI. To use the PI
with a device that uses serial to talk you need to unbind it first
(text ripped straight from the nationpigeon blog linked above).

Remove this section of text: ```console=serial0,115200``` from `/boot/cmdline.txt`.

So what previously looked like this:

```
  dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=/dev/mmcblk0p2
  rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
```

Now looks like this:

```
  dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4
  elevator=deadline fsck.repair=yes rootwait
```

**Disable `serial-getty` Service**

```
  $> sudo systemctl disable serial-getty@ttyAMA0.service
```

(On previous versions (and the nationpigeon blog), this was handled by removing
a line in `/etc/inittab`, but as `inittab` doesn’t exist under the `systemd` empire,
you have to use the `systemctl` command to stop and disable the serial getty service.).
For what it's worth, the old line to remove from `/etc/inittab` was:

```
  T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100.
```

**GPSD ListenStream**

Change the `ListenStream` parameter in `/lib/systemd/system/gpsd.socket`. It should read:

```
  ListenStream=0.0.0.0:2947
```

If you don’t do this, you’ll get this error when running `cgps -s`. Like so:

```
  $> cgps -s
  cgps: GPS timeout
```

**Specify Device GPSD Uses**

Change these parameters in `/etc/default/gpsd`:

```
  DEVICES="/dev/serial0"
  USBAUTO="false"
```

**Check `gpsd` Service**

Check whether gpsd is running (optional - this is just good practice)

```
  $> sudo systemctl status gpsd
  ● gpsd.service - GPS (Global Positioning System) Daemon
     Loaded: loaded (/lib/systemd/system/gpsd.service; static)
     Active: inactive (dead)
```

**Start `gpsd` Service**

```
  $> sudo systemctl start gpsd
```

**Check Log**

Check that the service booted correctly using `journalctl`:

```
  $> sudo journalctl
  (either scroll down or tail it or look at this
  Feb 01 23:07:21 pibox0 systemd[1]: Starting GPS (Global Positioning System) Daemon...
  Feb 01 23:07:21 pibox0 systemd[1]: Started GPS (Global Positioning System) Daemon.
```

## Check Its Working

I assume you can kick off the following command as soon as you’ve configured the
other bits above, but I don’t know for sure. I assume that, as the GPS has power
before `gpsd` is running, it’s doing it’s ephemera download/update and getting a
fix while you’re messing around getting the service configured and there is no
dependency on gpsd itself. That said, if it doesn’t work straight away, you
might like to try waiting again before running the following command:

```
$> cgps -s
```

Here’s what the output looks like. As mentioned in the nationpigeon blog,
there is also a GUI if you’re running a desktop (or X11 forwarding?) which
comes with the `gpsd-clients`. It’s called `xgps`.

<div class='image aside'>
  <img src='/images/gps_cgps_successful_readout.png'>
  CGPS Successful Readout
</div>

[pi-setup-repo]:https://github.com/robrant/pi-setup
[nationpigeon]:https://nationpigeon.com/gps-raspberrypi/
