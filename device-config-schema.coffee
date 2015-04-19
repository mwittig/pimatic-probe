module.exports = {
  title: "pimatic-probe device config schemas"
  HttpProbe: {
    title: "HTTP/HTTPS Probe"
    description: "Provides a probe for pinging HTTP/HTTPS services"
    type: "object"
    extensions: ["xConfirm"]
    properties:
      url:
        description: "URL to be pinged"
        type: "string"
      interval:
        description: "Polling interval for HTTP probes in seconds"
        type: "number"
        default: 60
  }
}