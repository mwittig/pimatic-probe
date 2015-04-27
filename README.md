# pimatic-probe

[![npm version](https://badge.fury.io/js/pimatic-probe.svg)](http://badge.fury.io/js/pimatic-probe)

A pimatic plugin to probe HTTP(S), TCP and UDP services.

Note: UDP is currently not supported and will be added at a later stage!

## Configuration

You can load the plugin by editing your `config.json` to include the following in the `plugins` section. For debugging 
purposes you may set property `debug` to true. This will write additional debug messages to the pimatic log. 

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
`enableResponseTime` is set to true (false by default) the device will additionally expose a `responseTime` attribute,
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
 value 0 is provided to allow all status codes by default. **Warning Notice: Do not set username and
 password as part of the URL as this has been deprecated and it presents a security risk!** 

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
 example below.

    {
        "id": "probe2",
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

#### HTTP Redirect

By default, HttpProbe will follow up to 5 redirects automatically. You can change the maximum number of redirects 
 followed automatically by setting the property `maxRedirects`. If you set the `maxRedirects` to 0, redirects will
 not be followed automatically. 

    {
        "id": "probe3",
        "class": "HttpProbe",
        "name": "Router Web Page with Redirect",
        "url": "http://fritz.box",
        "enableResponseTime": false,
        "interval": 60,
        "maxRedirects": 0
    }
    
### TcpConnectProbe Configuration

As part of the device definition you need to provide the `host` and `port`for the TCP Service to be probed. If the 
 property `enableConnectTime` is set to true (false by default) the device will additionally expose a `connectTime` 
 attribute, which allows for monitoring the connection establishment times. You may also set the `interval` property 
 to specify the probing interval in seconds (60 seconds by default). The `timeout` property may be set to specify
 the idle timeout on the TCP socket in seconds (10 seconds by default).
 
    {
          "id": "probe2",
          "class": "TcpConnectProbe",
          "name": "Call Monitor",
          "host": "fritz.box",
          "port": 1012,
          "enableConnectTime": false,
          "interval": 10,
          "timeout": 10
    }

## History

* 20150419, V0.0.1
    * Initial Version
* 20150419, V0.0.2
    * Fixed HTTP request termination to make sure HTTP connection gets closed right away
    * Added optional ``responseTime`` attribute
    * Updated README   
* 20150420, V0.0.3
    * Added TcpConnectProbe
    * Corrected definition of the responseTime attribute of HttpProbe
    * Updated README 
* 20150421, V0.0.4
    * Fixed bug: Type reference error occurred in TcpProbe if name resolution failed
    * Added support for automatic HTTP/HTTPS redirection
    * Added support for HTTP Basic Auth
    * Added support for defining the accepted HTTP Response Status Codes
    * Updated README, Added version badge
* 20150424, V0.0.5
    * Fixed bug: "Protocol:https: not supported"
    * Fixed issue with web server using an untrusted certificate resulting in an "UNABLE_TO_VERIFY_LEAF_SIGNATURE" 
      error. Untrusted cert will be accepted for now. This feature will be configurable with the next release.
* 20150427, V0.0.6
    * Reduced error log output. If "debug" is not set on the plugin, only new error states will be logged