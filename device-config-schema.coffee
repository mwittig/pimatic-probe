module.exports = {
  title: "pimatic-probe device config schemas"
  HttpProbe: {
    title: "HTTP/HTTPS Probe"
    description: "Provides a probe for pinging HTTP/HTTPS services"
    type: "object"
    properties:
      url:
        description: "HTTP/HTTPS Service URL to be probed"
        type: "string"
      interval:
        description: "Polling interval for HTTP/HTTPS probes in seconds"
        type: "number"
        default: 60
  }
}