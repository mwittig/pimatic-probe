# #Probe plugin

module.exports = (env) ->

  # Require the bluebird promise library
  Promise = env.require 'bluebird'

  # Require the nodejs net API
  net = require 'net'

  url = require 'url'
  http = require 'http'
  https = require 'https'

  # ###ProbePlugin class
  class ProbePlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      # register devices
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("HttpProbe", {
        configDef: deviceConfigDef.HttpProbe,
        createCallback: (config, plugin, lastState) =>
          return new HttpProbeDevice(config, @, lastState)
      })


  class HttpProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, lastState) ->
      @debug = plugin.config.debug;
      env.logger.debug("ProbeBaseDevice Initialization") if @debug
      @id = config.id
      @name = config.name
      @_presence = lastState?.presence?.value or false

      @options = url.parse(config.url, false, true)
      @service =  if @options.protocol is 'https' then https else http

      if !@options.hostname?
        env.logger.error("URL must contain a hostname")
        @deviceConfigurationError = true;

      @interval = 1000 * config.interval
      super()

      if not @deviceConfigurationError
        @_scheduleUpdate()


    # poll device according to interval
    _scheduleUpdate: () ->
      if typeof @intervalObject isnt 'undefined'
        clearInterval(=>
          @intervalObject
        )

      # keep updating
      if @interval > 0
        @intervalObject = setInterval(=>
          @_requestUpdate()
        , @interval
        )

      # perform an update now
      @_requestUpdate()

    _requestUpdate: ->
      @_ping().then( =>
        @_setPresence (yes)
      ).catch((error) =>
        env.logger.error("Probe for device id=" + @id + ": failed" + error.toString())
        @_setPresence (no)
      )

    _ping: ->
      return new Promise( (resolve, reject) =>
        @service.get(@options, (response) =>
          env.logger.debug "Got response: " + response.statusCode if @debug
          resolve()
        ).on "error", (error) =>
          reject(error)
      )

    getPresence: ->
      if @_presence? then return Promise.resolve @_presence
      return new Promise( (resolve, reject) =>
        @once('presence', ( (state) -> resolve state ) )
      ).timeout(@config.timeout + 5*60*1000)

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new ProbePlugin
  # and return it to the framework.
  return myPlugin