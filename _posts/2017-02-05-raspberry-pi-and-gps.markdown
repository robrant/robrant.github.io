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

<div class='image'>
  <img src='/images/gps_penny_scale.png'>
  <figcaption>Figure 1. The GP-20U7 and a Penny.</figcaption>
</div>


I pretty much followed [this nationpigeon post][nationpigeon].
word for word because my GPIO/UART/Serial knowledge was non-existent at the time.
It didn’t quite work for me because there have been Raspbian OS changes since
that post. So, usual story - I thought I’d capture how I got it to work and in a
later post, a list of things that might help others debug any problems they encounter.

## My Setup:

*   I’m using a Raspberry Pi B+, which has 40 GPIO pins.
*   I’m running the minimal Jessie install: `2016-11-25-raspbian-jessie-lite.img`.
*   I use this [ansible scripts][pi-setup-repo] to bootstrap my Pi.

## Hardware

* Disconnect your Pi from the power.

* I fitted 3 Male-Female jumper wires to the GPS lead, picking colours to match
those on the GPS to save confusing my little brain. Extending the leads allowed me to
connect the cables to pins distributed over the GPIO header without breaking up
the 3-pin female end point provided with the GPS.

*   I fitted the female ends of the jumper wires to physical pins 1, 6 and 10 of the
Raspberry Pi. Below is a table showing which GPS pins need to be connected to
which Pi pin numbers and names and a couple of photos for good measure.

* Then move the GPS outside or next to a window with good sight of the sky.

* Power on the Pi.

| Pi  | Pi Pin # | Pi Pin Name        | GPS |
|-----|----------|--------------------|-----|
| GND | Pin 6    | Ground             | GND |
| RX  | Pin 10   | GPIO15 / UART0_RXD | TX  |
| 3V  | Pin 1    | 3V3 / Power        | VCC |

_Table 1. A mapping between GPS pins and Pi pins._

<div class='image'>
  <img src='/images/gps_extension_jumpers.png'>
  <figcaption>Figure 2. GPS Pins Extensions</figcaption>
</div>

<div class='image'>
  <img src='/images/gps_pi_gpio_pins.png'>
  <figcaption>Figure 3. GPS GPIO Pin Configuration</figcaption>
</div>


## What Worked For Me


### Download GPS Daemon and clients

```
$> sudo apt-get install gpsd gpsd-clients
```

### Configure Serial Correctly

The RPI comes with the serial pins bound to a TTY terminal. This lets you
plug it into a USB-TTL cable and use `screen` to control the PI. To use the Pi
with a device that uses serial to communicate you need to unbind it first
(text ripped from the _nationpigeon_ blog linked above). Follow these instructions:

**1. Edit `/boot/cmdline.txt`**

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

**2. Disable `serial-getty` Service**

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

**3. GPSD ListenStream**

Change the `ListenStream` parameter in `/lib/systemd/system/gpsd.socket`. It should read:

```
  ListenStream=0.0.0.0:2947
```

If you don’t do this, you’ll get this error when running `cgps -s`. Like so:

```
  $> cgps -s
  cgps: GPS timeout
```

### Specify Device GPSD Uses

Change these parameters in `/etc/default/gpsd`:

```
  DEVICES="/dev/serial0"
  USBAUTO="false"
```

### The `gpsd` Service

**1. Check if `gpsd` is running**

```
  $> sudo systemctl status gpsd
  ● gpsd.service - GPS (Global Positioning System) Daemon
     Loaded: loaded (/lib/systemd/system/gpsd.service; static)
     Active: inactive (dead)
```

**2. Start `gpsd` Service**

```
  $> sudo systemctl start gpsd
```

**3. Check Logs**

Check that the service booted correctly using `journalctl`:

```
  $> sudo journalctl
  (either scroll down or tail it or look at this
  Feb 01 23:07:21 pibox0 systemd[1]: Starting GPS (Global Positioning System) Daemon...
  Feb 01 23:07:21 pibox0 systemd[1]: Started GPS (Global Positioning System) Daemon.
```

## Check Its Working

Run:
```
$> cgps -s
```

Inner monologue: I assume you can kick off this command as soon as you’ve
configured the other bits above, but I don’t know for sure. I assume that,
as the GPS has power before `gpsd` is running, it’s doing it’s ephemera
download/update and getting a fix while you’re messing around getting the
service configured. I.e. there is no dependency on gpsd itself.
That said, if it doesn’t work straight away, you might like to try waiting
again before running the `cgps -s` command.

Figure 4 shows what the output looks like. As mentioned in the nationpigeon blog,
there is also a GUI if you’re running a desktop which comes with `gpsd-clients`.
It’s called `xgps`.

<div class='image'>
  <img src='/images/gps_cgps_successful_readout.png'>
  <figcaption>Figure 4. CGPS Successful Readout</figcaption>

</div>

[pi-setup-repo]:https://github.com/robrant/pi-setup
[nationpigeon]:https://nationpigeon.com/gps-raspberrypi/
