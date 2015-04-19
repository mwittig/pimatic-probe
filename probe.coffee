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
        createCallback: (config, plugin, @framework, lastState) =>
          return new HttpProbeDevice(config, @, @framework, lastState)
      })


  class HttpProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, @framework, lastState) ->
      @debug = plugin.config.debug;
      env.logger.debug("ProbeBaseDevice Initialization") if @debug
      @id = config.id
      @name = config.name
      @responseTime = lastState?.responseTime?.value or 0
      @_presence = lastState?.presence?.value or false
      @_options = url.parse(config.url, false, true)
      @_service =  if @_options.protocol is 'https' then https else http

      if config.enableResponseTime
        @addAttribute('responseTime', {
          description: "Topic Data",
          type: "number"
          acronym: "RTT"
          unit: "ms"
        })
        @['getResponseTime'] = ()-> Promise.resolve(@responseTime)

      if !@_options.hostname?
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
        start = Date.now()
        request = @_service.get(@_options, (response) =>
          @_setResponseTime(Number Date.now() - start)
          env.logger.debug "Got response status=" + response.statusCode + ", time=" + @responseTime + "ms" if @debug
          request.abort()
          resolve(@responseTime)
        ).on "error", ((error) =>
          request.abort()
          reject(error)
        )
        request.setNoDelay()
      )

    _setResponseTime: (value) ->
      if @responseTime isnt value
        @responseTime = value
        @emit "responseTime", value if @config.enableResponseTime

    getPresence: ->
      @_presence = false if @_presence?
      return Promise.resolve @_presence

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new ProbePlugin
  # and return it to the framework.
  return myPlugin