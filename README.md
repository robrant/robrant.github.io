# Raspberry Pi and GPS over Serial.

I bought a small GPS Receiver (GP-20U7) to attach to a Particle Electron to create an ocean current tracker and/or real-time open water swim tracker. I haven’t got round to that yet, but I did have the time and inclination to attach it to my Raspberry Pi (B+).

<Photo of device with scale.>

I pretty much followed this post word for word because my GPIO/UART/Serial knowledge was non-existent at the time. It didn’t quite work for me because there have been reasonably significant OS changes since that post. I thought I’d capture how I got it to work and a list of things that might help others debug any problems.
