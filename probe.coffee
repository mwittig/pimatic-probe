# #Probe plugin

module.exports = (env) ->

  # Require the bluebird promise library
  Promise = env.require 'bluebird'

  # Require the nodejs net API
  net = require 'net'

  dns = require 'dns'
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

      @framework.deviceManager.registerDeviceClass("TcpConnectProbe", {
        configDef: deviceConfigDef.TcpConnectProbe,
        createCallback: (config, plugin, @framework, lastState) =>
          return new TcpConnectProbeDevice(config, @, @framework, lastState)
      })


  class HttpProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, @framework, lastState) ->
      @debug = plugin.config.debug
      env.logger.debug("HttpProbeDevice Initialization") if @debug
      @id = config.id
      @name = config.name
      @responseTime = lastState?.responseTime?.value or 0
      @_presence = lastState?.presence?.value or false
      @_options = url.parse(config.url, false, true)
      @_service = if @_options.protocol is 'https' then https else http

      if config.enableResponseTime
        @addAttribute('responseTime', {
          description: "HTTP/HTTPS Response Time",
          type: "number"
          acronym: "RT"
          unit: " ms"
        })
        @['getResponseTime'] = ()-> Promise.resolve(@responseTime)

      if !@_options.hostname?
        env.logger.error("URL must contain a hostname")
        @deviceConfigurationError = true

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
      @_ping().then(=>
        @_setPresence (yes)
      ).catch((error) =>
        env.logger.error "Probe for device id=" + @id + " failed: " + error
        @_setPresence (no)
      )

    _ping: ->
      return new Promise((resolve, reject) =>
        timeStart = process.hrtime()
        request = @_service.get(@_options, (response) =>
          timeEnd = process.hrtime(timeStart)
          time = (timeEnd[0] * 1e9 + timeEnd[1]) / 1e6
          @_setResponseTime(Number time.toFixed())
          env.logger.debug "Got response , device id=" + @id + ", status=" + response.statusCode + ", time=" + @responseTime + " ms" if @debug
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
      Promise.resolve(@_presence)


  class TcpConnectProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, @framework, lastState) ->
      @debug = plugin.config.debug
      env.logger.debug("TcpConnectProbeDevice Initialization") if @debug
      @id = config.id
      @name = config.name
      @connectTime = lastState?.connectTime?.value or 0
      @_presence = lastState?.presence?.value or false
      @_port = config.port
      @_timeout = config.timeout * 1000

      if config.enableConnectTime
        @addAttribute('connectTime', {
          description: "TCP Connect Time",
          type: "number"
          acronym: "CT"
          unit: " ms"
        })
        @['getConnectTime'] = ()-> Promise.resolve(@connectTime)

      @interval = 1000 * config.interval
      super()

      dns.lookup(config.host, null, (err, address, family) =>
        if err?
          env.logger.error "Name Lookup failed: " + error
        else
          @_host = address
          @_scheduleUpdate()
      )

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
      @_connect().then(=>
        @_setPresence (yes)
      ).catch((error) =>
        env.logger.error "Probe for device id=" + @id + ", host=" + @_host + ", port=" + @_port + " failed: " + error
        @_setPresence (no)
      )

    _connect: ->
      return new Promise((resolve, reject) =>
        timeStart = process.hrtime()
        client = new net.Socket
        client.setTimeout(@_timeout, =>
          client.destroy()
          reject(new Error "TCP connect attempt timed out")
        )
        client.on "error", ((error) =>
          client.destroy()
          reject(error)
        )
        client.connect(@_port, @_host, =>
          timeEnd = process.hrtime(timeStart)
          time = (timeEnd[0] * 1e9 + timeEnd[1]) / 1e6
          @_setConnectTime(Number time.toFixed())
          client.destroy()
          env.logger.debug "Connected to server, device id=" + @id + ", connectTime=" + @connectTime + " ms" if @debug
          resolve(@connectTime)
        )
      )

    _setConnectTime: (value) ->
      if @connectTime isnt value
        @connectTime = value
        @emit "connectTime", value if @config.enableConnectTime

    getPresence: ->
      @_presence = false if @_presence?
      return Promise.resolve @_presence

  # ###Finally
  # Create a instance of my plugin
  myPlugin = new ProbePlugin
  # and return it to the framework.
  return myPlugin