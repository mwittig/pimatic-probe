# #Probe plugin

module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  net = require 'net'
  dns = require 'dns'
  url = require 'url'
  http = require 'http'
  https = require 'https'
  redirect = require 'follow-redirects'
  commons = require('pimatic-plugin-commons')(env)

  # ###ProbePlugin class
  class ProbePlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      # register devices
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("HttpProbe", {
        configDef: deviceConfigDef.HttpProbe,
        createCallback: (config, lastState) =>
          return new HttpProbeDevice(config, @, lastState)
      })

      @framework.deviceManager.registerDeviceClass("TcpConnectProbe", {
        configDef: deviceConfigDef.TcpConnectProbe,
        createCallback: (config, lastState) =>
          return new TcpConnectProbeDevice(config, @, lastState)
      })


  class HttpProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, lastState) ->
      @base = commons.base @, @config.class
      @debug = plugin.config.debug || false
      @id = @config.id
      @name = @config.name
      @base.debug "Initialization"
      @responseTime = lastState?.responseTime?.value or 0
      @_presence = lastState?.presence?.value or false
      @_options = url.parse(@config.url, false, true)
      if @config.probeErrorLogLevel in ["error", "warn", "info"]
        @_level = @config.probeErrorLogLevel
      else
        @base.error("Bad device configuration: probeErrorLogLevel " +
          "must be one of [\"error\", \"warn\", \"info\"]")
        @_level = "error"


      if @config.maxRedirects > 0
        @_options.maxRedirects = @config.maxRedirects
        @_service = if @_options.protocol is 'https:' then redirect.https else redirect.http
      else
        @_service = if @_options.protocol is 'https:' then https else http

      @_options.rejectUnauthorized = @config.verifyPeerCert
      if _.isArray(@config.acceptedStatusCodes)
        @acceptedStatusCodes = @config.acceptedStatusCodes
      else
        @acceptedStatusCodes = []
      if @config.username isnt "" and @config.password isnt ""
        @_options.auth = @config.username + ':' + @config.password

      if @config.enableResponseTime
        @addAttribute('responseTime', {
          description: "HTTP/HTTPS Response Time",
          type: "number"
          acronym: "RT"
          unit: "ms"
        })
        @addAction('getResponseTime'
          description: 'Returns the last HTTP/HTTPS Response Time',
          returns:
            responseTime:
              type: "number"
              acronym: "RT"
              unit: "ms"
        ) if @addAction?
        @['getResponseTime'] = ()-> Promise.resolve(@responseTime)

      if !@_options.hostname?
        env.logger.error("URL must contain a hostname")
        @deviceConfigurationError = true

      @interval = Math.max 1000 * @config.interval, 10000
      @_options.timeout = Math.min @interval, 20000
      @_options.agent = false
      super()

      if not @deviceConfigurationError
        # perform an update now
        @_requestUpdate()

    destroy: () ->
      @base.cancelUpdate()
      super()

    _requestUpdate: ->
      @_ping().then( =>
        @base.resetLastError()
        @_setPresence yes
      ).catch((error) =>
        @base.logErrorWithLevel @_level, "Probe url=#{@config.url} failed: " + error
        @_setPresence no
      ).finally( =>
        @base.scheduleUpdate @_requestUpdate, @interval
      )

    _ping: ->
      return new Promise((resolve, reject) =>
        timeStart = process.hrtime()
        timeoutOccurred = false
        request = @_service.get(@_options, (response) =>
          timeEnd = process.hrtime(timeStart)
          time = (timeEnd[0] * 1e9 + timeEnd[1]) / 1e6
          @_setResponseTime(Number time.toFixed())
          @base.debug "Response, status=#{response.statusCode}, time=#{@responseTime} ms"

          if response.socket?
            response.socket.end()
            response.socket.destroy()

          if 0 in @acceptedStatusCodes or response.statusCode in @acceptedStatusCodes
            resolve(@responseTime)
          else
            reject(new Error "HTTP status code #{response.statusCode} does not match "\
                + "accepted status codes #{@acceptedStatusCodes.toString()}")
        )
        request.on "error", ((error) =>
          if (timeoutOccurred)
            error = new Error "Request timeout occurred - request aborted"
          request.abort()
          reject(error)
        )
        request.on "timeout", ((error) =>
          timeoutOccurred = true
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
      Promise.resolve(if @_presence? then @_presence else false)


  class TcpConnectProbeDevice extends env.devices.PresenceSensor
    # Initialize device by reading entity definition from middleware
    constructor: (@config, plugin, lastState) ->
      @base = commons.base @, @config.class
      @debug = plugin.config.debug
      @id = @config.id
      @name = @config.name
      @base.debug("Initialization")

      @connectTime = lastState?.connectTime?.value or 0
      @_presence = lastState?.presence?.value or false
      @_port = @config.port
      @interval = Math.max 1000 * @config.interval, 10000
      @_connectTimeout = Math.min @interval, @config.timeout * 1000
      if @config.probeErrorLogLevel in ["error", "warn", "info"]
        @_level = @config.probeErrorLogLevel
      else
        @base.error("Bad device configuration: probeErrorLogLevel must be one of [\"error\", \"warn\", \"info\"]")
        @_level = "error"

      if @config.enableConnectTime
        @addAttribute('connectTime',
          description: "TCP Connect Time"
          type: "number"
          acronym: "CT"
          unit: "ms"
        )
        @addAction('getConnectTime'
          description: 'Returns the last TCP Connect Time'
          returns:
            connectTime:
              type: "number"
              acronym: "CT"
              unit: "ms"
        ) if @addAction?
        @['getConnectTime'] = ()-> Promise.resolve(@connectTime)
      super()

      dns.lookup(@config.host, null, (error, address) =>
        if error?
          @base.error "host=#{@config.host}: Name Lookup failed: " + error
          @_setPresence no
        else
          @_host = address
          # perform an update now
          @_requestUpdate()
      )

    destroy: () ->
      @base.cancelUpdate()
      super()

    _requestUpdate: ->
      @_connect().then( =>
        @base.resetLastError()
        @_setPresence yes
      ).catch((error) =>
        @base.logErrorWithLevel @_level, "Probe host=#{@_host}, port=#{@_port} failed: " + error
        @_setPresence no
      ).finally( =>
        @base.scheduleUpdate @_requestUpdate, @interval
      )

    _connect: ->
      return new Promise((resolve, reject) =>
        timeStart = process.hrtime()
        client = new net.Socket
        client.setTimeout(@_connectTimeout, =>
          client.destroy()
          reject(new Error "TCP connect attempt timed out")
        )
        client.on "error", ((error) =>
          client.destroy()
          reject error
        )
        client.connect(@_port, @_host, =>
          timeEnd = process.hrtime(timeStart)
          time = (timeEnd[0] * 1e9 + timeEnd[1]) / 1e6
          @_setConnectTime(Number time.toFixed())
          client.destroy()
          @base.debug "Connected to server, connectTime=#{@connectTime} ms"
          resolve @connectTime
        )
      )

    _setConnectTime: (value) ->
      if @connectTime isnt value
        @connectTime = value
        @emit "connectTime", value if @config.enableConnectTime

    getPresence: ->
      Promise.resolve(if @_presence? then @_presence else false)


  # ###Finally
  # Create a instance of my plugin
  myPlugin = new ProbePlugin
  # and return it to the framework.
  return myPlugin