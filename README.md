# pimatic-probe

A pimatic plugin to probe HTTP(S), TCP and UDP services.

Note: UDP is currently not supported and will be added at a later stage!

## Configuration

You can load the plugin by editing your `config.json` to include the following in the `plugins` section. For debugging 
purposes you may set property `debug` to true. This will write additional debug messages to the pimatic log. 

    {
          "plugin": "probe",
          "debug": false
    }

Then you need to add a device in the `devices` section. Currently, only the following device type is supported:

* HttpProbe: This type provides a probe for pinging HTTP/HTTPS services
* TcpConnectProbe: This type provides a probe for TCP connect

### HttpProbe Configuration

As part of the device definition you need to provide the `url` for the Web Service to be probed. If the property
`enableResponseTime` is set to true (false by default) the device will additionally expose a `responseTime` attribute,
 which allows for monitoring the response times. You may also set the `interval` property to specify the probing 
 interval in seconds (60 seconds by default). **Warning Notice: Generally, it is not advised to ping external services 
 at a high frequency as this may be regarded as a denial-of-service attack!**

    {
          "id": "probel",
          "class": "HttpProbe",
          "name": "Router Web Page",
          "url": "http://fritz.box",
          "enableResponseTime": false
          "interval": 60
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