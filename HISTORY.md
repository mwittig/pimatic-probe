# Release History

* 20190215, V0.3.4
    * Fix set tcp-probe presence to absent if DNS look fails
* 20190214, V0.3.3
    * Added device configuration option to set the log level used for reporting probe errors, issue #19
    * Updated dependencies to follow-redirects@1.7.0 and pimatic-plugin-commons@0.9.10
* 20171204, V0.3.2
    * Fixed wrong signature for createCallback hooks which caused invalid lastState, issue #17
    * Updated dependencies to follow-redirects@1.2.6
* 20170715, V0.3.1
    * Removed extra space from unit value
* 20170715, V0.3.0
    * Conditionally add getter actions for responseTime and connectTime if supported by pimatic (>= 0.9.41)
    * Updated dependencies to follow-redirects@1.2.4 and pimatic-plugin-commons@0.9.5
* 20170310, V0.2.7
    * Updated dependencies to follow-redirects@1.2.3
    * Removed support for Node.js 0.10
    * Revised README
    * Added travis build descriptor
* 20161006, V0.2.6
    * Updated dependencies to pimatic-plugin-commons@0.9.3
* 20160426, V0.2.5
    * Added destroy method to cancel an scheduled update when the device is removed or updated
    * Updated dependencies to follow-redirects@0.1.0
    * Refactoring, now using pimatic-plugin-commons
* 20160322, V0.2.4
    * Fixed compatibility issue with Coffeescript 1.9 as required for pimatic 0.9 (thanks @sweebee)
    * Updated peerDependencies property for compatibility with pimatic 0.9
* 20160319, V0.2.3
    * Fixed config schema type definition for `acceptedStatusCodes`, thanks @sweetpi
    * Fixed typo in config schema description for `verifyPeerCert`
    * Added license info to README
* 20151125, V0.2.2
    * Bug fix for HTTP response socket not being destroyed on socket.end()
* 20151121, V0.2.1
    * Bug fix for socket not closed if HTTP request is redirected
* 20151116, V0.2.0
    * Changed strategy for probe scheduling to ensure there is only one pending probe at a time to avoid 
      resource exhaustion in edge cases, e.g. if there is no response from peer on HTTP connect
    * Minor changes
* 20150918, V0.1.1
    * Dependency updates
    * Minor changes
* 20150813, V0.1.0
    * Revised license information to provide a SPDX 2.0 license identifier according to npm v2.1 guidelines 
      on license metadata - see also https://github.com/npm/npm/releases/tag/v2.10.0
    * Dependency updates
* 20150604, V0.0.9
    * Added range checks for interval property. Updated device schema
    * Added HttpProbe & TcpProve socket timeouts. Adapt timeout to interval if interval is less than 20 secs
    * Disabled HttpProbe socket pooling
* 20150430, V0.0.8
    * Added support for xAttributeOptions property as part of the device configuration
    * Added `verifyPeerCert` property to HttpProbe device configuration to enable or disable certificate verification
      (disabled by default). This is to replace the temporary fix for the "UNABLE_TO_VERIFY_LEAF_SIGNATURE" issue
      added in v0.0.5
    * Extended documentation of device configuration option
* 20150427, V0.0.7
    * Fixed device config schema. Presence conditions should now match properly as part of rules.
* 20150427, V0.0.6
    * Reduced error log output. If "debug" is not set on the plugin, only new error states will be logged
* 20150424, V0.0.5
    * Fixed bug: "Protocol:https: not supported"
    * Fixed issue with web server using an untrusted certificate resulting in an "UNABLE_TO_VERIFY_LEAF_SIGNATURE" 
      error. Untrusted cert will be accepted for now. This feature will be configurable with the next release.
* 20150421, V0.0.4
    * Fixed bug: Type reference error occurred in TcpProbe if name resolution failed
    * Added support for automatic HTTP/HTTPS redirection
    * Added support for HTTP Basic Auth
    * Added support for defining the accepted HTTP Response Status Codes
    * Updated README, Added version badge
* 20150420, V0.0.3
    * Added TcpConnectProbe
    * Corrected definition of the responseTime attribute of HttpProbe
    * Updated README 
* 20150419, V0.0.2
    * Fixed HTTP request termination to make sure HTTP connection gets closed right away
    * Added optional ``responseTime`` attribute
    * Updated README   
* 20150419, V0.0.1
    * Initial Version







    


