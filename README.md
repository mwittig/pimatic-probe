# pimatic-probe

A pimatic plugin to probe HTTP(S), TCP or UDP services

NOTE: Currently, this a basic implementation of the HTTP(S) probe is provided, only!

## Configuration

You can load the plugin by editing your `config.json` to include the following in the `plugins` section. For debugging 
purposes you may set property `debug` to true. This will write additional debug messages to the pimatic log. 

    {
          "plugin": "probe",
          "debug": false
    }

Then you need to add a device in the `devices` section. Currently, only the following device type is supported:

* HttpProbe: This type provides a probe for pinging HTTP/HTTPS services
  
As part of the device definition you need to provide the `url` for the Web Service to be pinged. You may also set
the `interval` property for the probing interval in seconds (60 seconds by default). BE WARNED: Generally, it is not 
advised to ping external services at a high frequency as this may be regarded as denial of service attempt!

    {
          "id": "probel",
          "class": "HttpProbe",
          "name": "Router Web Page",
          "url": "http://fritz.box",
          "interval": 60
        }

## History

* 20150419, V0.0.1
    * Initial Version