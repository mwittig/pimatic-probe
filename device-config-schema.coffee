module.exports = {
  title: "pimatic-probe device config schemas"
  HttpProbe: {
    title: "HTTP/HTTPS Probe"
    description: "Provides a probe for pinging HTTP/HTTPS services"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel", "xAttributeOptions"]
    properties:
      url:
        description: "HTTP/HTTPS Service URL to be probed"
        type: "string"
      verifyPeerCert:
        description: "Enables or Disables verification verification of the peer certificates."
        type: "boolean"
        default: false
      enableResponseTime:
        description: "Adds an attribute to monitor response times"
        type: "boolean"
        default: false
      interval:
        description: "Polling interval for HTTP/HTTPS probes in seconds"
        type: "number"
        default: 60
      acceptedStatusCodes:
        description: "HTTP Status Codes regarded as a successful probe result (set 0 for 'Accept All')"
        type: "array"
        default: [0]
      maxRedirects:
        description: "Maximum number of HTTP redirects to follow automatically (set 0 to disable)"
        type: "number"
        default: 5
      username:
        description: "Username if HTTP Basic Authentication shall be applied"
        type: "string"
        default: ""
      password:
        description: "Password if HTTP Basic Authentication shall be applied"
        type: "string"
        default: ""
  },
  TcpConnectProbe: {
    title: "TCP Connect Probe"
    description: "Provides a probe for a TCP connect to the given host and port"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel", "xAttributeOptions"]
    properties:
      host:
        description: "Hostname or IP address of the server"
        type: "string"
      port:
        description: "Server port"
        type: "number"
      enableConnectTime:
        description: "Adds an attribute to monitor connect times"
        type: "boolean"
        default: false
      interval:
        description: "Polling interval for TCP connect probes in seconds"
        type: "number"
        default: 60
      timeout:
        description: "Timeout (in seconds) of inactivity on the TCP socket"
        type: "number"
        default: 10
  }
}