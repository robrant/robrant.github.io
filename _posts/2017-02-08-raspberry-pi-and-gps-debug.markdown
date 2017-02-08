---
layout: post
title: "Raspberry Pi and GPS, Part 2: Debug Notes"
date: 2017-02-08 18:00
categories: Raspberry Pi, GPS
tags:
    - Rasberry Pi
    - GPS
    - Peripherals
    - Jessie
author: "Rich Brantingham"
---

## Background

This is a bag of bits post. It's the stuff I messed with or found while trying to get a GP-20U7 GPS receiver connected to a Raspberry Pi B+.
[Here's the first part][pi_gps_part1] which outlines how to get it working. You should only really need this if that hasn't worked.

## Raspberry Pi 3

UART (see below: 'What the Hell is UART?') is disabled by default on the Pi 3.
You must enable it in `/boot/config.txt` by adding the following line and rebooting:
```
  enable_uart=true
```

The end of [this long rambling thread][rambling_blog] starts to talk about differences with the Pi 3.

And have a look at [this SO][pi3_info1] page too and this one explains [why there are changes in Serial][pi3_serial_changes] config on the Pi 3.

## Using the gpsd systemd unit (service)

**Journalctl**. Use `journalctl` to see whether `gpsd` started correctly. Use it's flags/options
to control how much information is returned (e.g. `--since yesterday`) or pipe to tail to get the most recent log entries (`journalctl | tail -n 100`).

## Not Disabling The Serial service

If you don’t stop and disable `serial-getty@ttyAMA0.service`, then you’ll get an error like this when running `journalctl | tail -n 200`.

```
  Feb 01 23:12:46 pibox0 systemd[1]: Starting GPS (Global Positioning System) Daemon...
  Feb 01 23:12:46 pibox0 systemd[1]: Started GPS (Global Positioning System) Daemon.
  Feb 01 23:12:48 pibox0 login[1803]: FAILED LOGIN (2) on '/dev/ttyAMA0' FOR 'UNKNOWN', Authentication failure
  Feb 01 23:12:49 pibox0 login[1803]: pam_unix(login:auth): check pass; user unknown
  Feb 01 23:12:49 pibox0 login[1803]: pam_unix(login:auth): authentication failure; logname=LOGIN uid=0 euid=0 tty=/dev/ttyAMA0 ruser= rhost=
```

## Relevant Files

### GPSD Unit Configuration File: Socket

[This site][socket_def] says `.socket` files encodes information about an IPC or network socket or a file system FIFO controlled and supervised by `systemd`.

Filepath: `/lib/systemd/system/gpsd.socket`

```
  [Unit]
  Description=GPS (Global Positioning System) Daemon Sockets

  [Socket]
  ListenStream=/var/run/gpsd.sock
  ListenStream=[::1]:2947
  ListenStream=0.0.0.0:2947   # Note - I changed it to this from default.
  SocketMode=0600

  [Install]
  WantedBy=sockets.target
```

### GPSD Unit Definition File: Service

Filepath: `/lib/systemd/system/gpsd.service`

```
  [Unit]
  Description=GPS (Global Positioning System) Daemon
  Requires=gpsd.socket

  [Service]
  EnvironmentFile=-/etc/default/gpsd
  ExecStart=/usr/sbin/gpsd -N $GPSD_OPTIONS $DEVICES

  [Install]
  Also=gpsd.socket
```

### Defaults for the GPSD Service

Filepath: `/etc/default/gpsd`:

```
  # Start the gpsd daemon automatically at boot time
  START_DAEMON="true"

  # Use USB hotplugging to add new USB devices automatically to the daemon
  USBAUTO="false"

  # Devices gpsd should collect to at boot time.
  # They need to be read/writeable, either by user gpsd or the group dialout.
  DEVICES="/dev/serial0"

  # Other options you want to pass to gpsd
  GPSD_OPTIONS="D5”
```

The `GPSD_OPTIONS` in this file allows us to specify `gpsd`
options that might help with debugging. `D` defines the debugging level (from 1 - 8 I think).

## Baud Rate?

I saw some references to tweaking the baud rate of the serial
connection. I didn't have to change it, so didn't explore much
further.

## Running gpsd not as a service

```
  $> gpsd -N (other options) /dev/serial0
```

## Useful Links:

* [A guide to Raspberry Pi Pins][pi_pins]

* [What the hell is UART?][what_is_uart]


[pi_gps_part1]: https://robrant.github.io/2017/02/raspberry-pi-and-gps/
[rambling_blog]: https://www.raspberrypi.org/forums/viewtopic.php?f=45&t=18115
[what_is_uart]: https://learn.sparkfun.com/tutorials/serial-communication/uarts
[pi_pins]: https://projects.drogon.net/raspberry-pi/wiringpi/special-pin-functions/
[socket_def]: https://www.freedesktop.org/software/systemd/man/systemd.socket.html
[pi3_info1]: http://raspberrypi.stackexchange.com/questions/45570/how-do-i-make-serial-work-on-the-raspberry-pi3
[pi3_info2]: https://learn.adafruit.com/adafruit-ultimate-gps-on-the-raspberry-pi/using-uart-instead-of-usb
[pi3_serial_changes]: https://www.element14.com/community/thread/55627/l/how-to-use-serial-port-in-raspberry-pi-3?displayFullThread=true
