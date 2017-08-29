# pimatic-probe

[![Greenkeeper badge](https://badges.greenkeeper.io/mwittig/pimatic-probe.svg)](https://greenkeeper.io/)

[![npm version](https://badge.fury.io/js/pimatic-probe.svg)](http://badge.fury.io/js/pimatic-probe)
[![Build Status](https://travis-ci.org/mwittig/pimatic-probe.svg?branch=master)](https://travis-ci.org/mwittig/pimatic-probe)

A pimatic plugin to probe HTTP(S) and TCP services.

## Contributions

Contributions to the project are  welcome. You can simply fork the project and create a pull request with 
your contribution to start with. If you like this plugin, please consider &#x2605; starring 
[the project on github](https://github.com/mwittig/pimatic-probe).

## Configuration

Note, instead of editing `config.json` as suggested in the remainder it is easier to use the plugin and device 
configuration editors provided as part of the web frontend for pimatic 0.9.

You can load the plugin by editing your `config.json` to include the following in the `plugins` section. For debugging 
purposes you may set property `debug` to `true`. This will write additional debug messages to the pimatic log. 

    {
          "plugin": "probe",
          "debug": false
    }

Then you need to add a device in the `devices` section. Currently, the following device types are supported:

* HttpProbe: This type provides a probe for HTTP/HTTPS services by sending a HTTP GET request and checking the response.
* TcpConnectProbe: This type provides a probe for TCP-based services by establishing a TCP connection and testing the 
  connection status.

### HttpProbe Configuration

As part of the device definition you need to provide the `url` for the Web Service to be probed. Note, the URL may also
 contain a port number and path if needed, for example: "http://fritz.box:88/details.html". If the property
`enableResponseTime` is set to `true` (false by default) the device will additionally expose a `responseTime` attribute,
 which allows for monitoring the response times. You may also set the `interval` property to specify the probing 
 interval in seconds (60 seconds by default). **Warning Notice: Generally, it is not advised to ping external services 
 at a high frequency as this may be regarded as a denial-of-service attack!**

    {
          "id": "probel",
          "class": "HttpProbe",
          "name": "Router Web Page",
          "url": "http://fritz.box",
          "enableResponseTime": false,
          "interval": 60
    }

### HttpProbe Advanced Configuration

This section is for advanced users with a good understanding of the HTTP protocol.

#### HTTP Response Status Codes

By default, HttpProbe accepts responses with any HTTP status code. This may not be satisfactory as this way you will 
 not be able to detect HTTP-specific errors, such as 404 (Not Found) or 502 (Bad Gateway). If you require a specific 
 accept pattern you can set the property `acceptedStatusCodes` which holds an array of accepted status codes. The 
 value 0 is provided to allow all status codes by default. 

    {
        "id": "probe2",
        "class": "HttpProbe",
        "name": "Router Web Page with Basic Auth",
        "url": "http://fritz.box",
        "enableResponseTime": false,
        "interval": 60,
        "acceptedStatusCodes": [
            200
        ],
        "maxRedirects": 0
    }

#### HTTP Basic Authentication

By default, HttpProbe accepts responses with any HTTP status code which includes code 401 (Unauthorized). However, you 
 can perform proper authentication by setting the properties `username` and `password`. In this case you also need to 
 remove status code 401 from the list of accepted status codes by setting the `acceptedStatusCodes` property. See 
 example below. **Warning Notice: Do not set username and password as part of the URL as this has been deprecated 
 and it presents a security risk!** 

    {
        "id": "probe3",
        "class": "HttpProbe",
        "name": "Router Web Page with Basic Auth",
        "url": "http://fritz.box",
        "enableResponseTime": false,
        "interval": 60
        "username": "foo",
        "password": "bar",
        "acceptedStatusCodes": [
            200
        ]
    }

#### HTTPS Server Certificate Verification

By default, HttpProbe does not verify the server certificate if connected to a HTTPS server. The verification can be 
 enabled by setting the `verifyPeerCert` property to `true`. In this case, HttpProbe will fail (`absent` state) if the 
 server certificate cannot be verified.

    {
        "id": "probe4",
        "class": "HttpProbe",
        "name": "Router Web Page with Basic Auth",
        "url": "https://fritz.box",
        "verifyPeerCert": true,
        "enableResponseTime": false,
        "interval": 60
        "username": "foo",
        "password": "bar",
        "acceptedStatusCodes": [
            200
        ]
    }
 
#### HTTP Redirect

By default, HttpProbe will follow up to 5 redirects automatically. You can change the maximum number of redirects 
 followed automatically by setting the property `maxRedirects`. If you set the `maxRedirects` to `0`, redirects will
 not be followed automatically. 

    {
        "id": "probe5",
        "class": "HttpProbe",
        "name": "Router Web Page with Redirect",
        "url": "http://fritz.box",
        "enableResponseTime": false,
        "interval": 60,
        "maxRedirects": 0
    }
    
#### xLink and xAttributeOptions properties

If you wish to hide the sparkline (the mini-graph) of `responseTime` attribute display this is possible with 
 pimatic v0.8.68 and higher using the  `xAttributeOptions` property as shown in the following example. Using the 
 `xLink` property you can also add a hyperlink to the device display.
 
    {
         "id": "probe6",
         "class": "HttpProbe",
         "name": "Router Web Page with Redirect",
         "url": "http://fritz.box",
         "enableResponseTime": true,
         "interval": 60,
         "maxRedirects": 0,
         "xLink": "http://fritz.box",
         "xAttributeOptions": [
             {
               "name": "responseTime",
               "displaySparkline": false
             }
         ]
     }

### TcpConnectProbe Configuration

As part of the device definition you need to provide the `host` and `port`for the TCP Service to be probed. If the 
 property `enableConnectTime` is set to `true` (false by default) the device will additionally expose a `connectTime` 
 attribute, which allows for monitoring the connection establishment times. You may also set the `interval` property 
 to specify the probing interval in seconds (60 seconds by default). The `timeout` property may be set to specify
 the idle timeout on the TCP socket in seconds (10 seconds by default).
 
    {
          "id": "probe7",
          "class": "TcpConnectProbe",
          "name": "Call Monitor",
          "host": "fritz.box",
          "port": 1012,
          "enableConnectTime": false,
          "interval": 10,
          "timeout": 10
    }
    
### TcpConnectProbe Advanced Configuration

#### xLink and xAttributeOptions properties

If you wish to hide the sparkline (the mini-graph) of `connectTime` attribute display this is possible with 
 pimatic v0.8.68 and higher using the `xAttributeOptions` property as shown in the following example. Using the 
 `xLink` property you can also add a hyperlink to the device display.
 
    {
        "id": "probe8",
        "class": "TcpConnectProbe",
        "name": "Call Monitor",
        "host": "fritz.box",
        "port": 1012,
        "enableConnectTime": true,
        "interval": 10,
        "timeout": 10
        "xLink": "http://fritz.box",
        "xAttributeOptions": [
             {
               "name": "connectTime",
               "displaySparkline": false
             }
        ]
    }

# History

See [Release History](https://github.com/mwittig/pimatic-probe/blob/master/HISTORY.md).

# License 

Copyright (c) 2015-2017, Marcus Wittig and contributors.
All rights reserved.

License: [GPL-2.0](https://github.com/mwittig/pimatic-probe/blob/master/LICENSE).

