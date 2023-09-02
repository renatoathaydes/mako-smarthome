# Mako SmartHome

This project implements a SmartHome HTTP Server for managing a smart home based on the [deCONZ REST API](https://dresden-elektronik.github.io/deconz-rest-doc/).

The HTTP Server and Lua libraries are based on the [Mako Server](https://makoserver.net/), itself an extension of the [Barracuda Application Server](https://barracudaserver.com/). Mako is incredibly light, hence the whole application can be run on the most basic Raspberry Pi or equivalent (my setup uses less than 2MB of memory for EVERYTHING).

From the [deConz-rest-plugin](https://github.com/dresden-elektronik/deconz-rest-plugin) page:

> To communicate with Zigbee devices the [RaspBee](https://phoscon.de/raspbee?ref=gh) / [RaspBee&nbsp;II](https://phoscon.de/raspbee2?ref=gh) Zigbee shield for Raspberry Pi, or a [ConBee](https://phoscon.de/conbee?ref=gh) / [ConBee&nbsp;II](https://phoscon.de/conbee2?ref=gh) USB dongle is required.

## Getting Started

1. Download the Mako Server binary on the Raspberry Pi.
2. Checkout the code in this repository.
3. Create a `mako.conf` file containing API keys and your location (see example below).
3. Run `mako -c mako.conf -l::smarthome`.
4. Open `http://<your-server>:<port>/smarthome/` on a browser.

This assumes you already have a Raspbee/ConBee device running and the smart devices connected via the [Phoscon App](https://phoscon.de/en/raspbee2/software).

### Example mako.conf

```lua
homeio='/home/renato/mako'

sensorsServerUrl = "http://192.168.1.2" -- where deconz API is running
deconzKey='<generated when you start deconz>'
weatherApiKey='<get API key at https://openweathermap.org/>'
latitude=37.2514795 -- location used for weather only
longitude=-116.3766731
```

## Blog Post

I wrote a [blog post](https://renato.athaydes.com/posts/writing-your-own-smarthome-manager.html) about coming up with my setup.

Check it out.
