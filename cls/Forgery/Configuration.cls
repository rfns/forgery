Class Forgery.Configuration Extends %RegisteredObject
{

Property WebApplication As %String [ Private ];

Property DispatchHandler As Forgery.IDispatchHandler [ Private ];

Property DeviceLineTerminator As %String [ InitialExpression = {$char(13,10)}, Private ];

Property DeviceCharset As %String [ InitialExpression = "utf-8", Private ];

Property RequestDefaultHeaders As %DynamicObject [ Private ];

Property RequestDefaultCookies As %DynamicArray [ Private ];

/// Caché does not honour an InitialExpression of {} or [] on a dynamic
/// property, which leaves it holding a NULLOREF. Validate() then rejects the
/// configuration for headers and cookies the caller never had to provide, and
/// the agent cannot be built at all. Initialising here works on both platforms.
Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
  set ..RequestDefaultHeaders = {}
  set ..RequestDefaultCookies = []
  return $$$OK
}

Method SetWebApplication(webApplication As %String) As %Status
{
  set ..WebApplication = webApplication
  return $$$OK
}

Method GetWebApplication() As %String [ CodeMode = expression ]
{
..WebApplication
}

Method SetDispatchHandler(handler As Forgery.IDispatchHandler) As %Status
{
  set ..DispatchHandler = handler
  return $$$OK
}

Method GetDispatchHandler() As Forgery.IDispatchHandler [ CodeMode = expression ]
{
..DispatchHandler
}

Method SetDeviceLineTerminator(lineTerminator As %String) As %Status
{
  set ..DeviceLineTerminator = lineTerminator
  return $$$OK
}

Method GetDeviceLineTerminator() As %String [ CodeMode = expression ]
{
..DeviceLineTerminator
}

Method SetDeviceCharset(charset As %String) As %Status
{
  set ..DeviceCharset = charset
  return $$$OK
}

Method GetDeviceCharset() As %String [ CodeMode = expression ]
{
..DeviceCharset
}

Method SetRequestDefaultHeaders(headers As %DynamicObject) As %Status
{
  set ..RequestDefaultHeaders = headers
  return $$$OK
}

Method GetRequestDefaultHeaders() As %DynamicObject [ CodeMode = expression ]
{
$select($isobject(..RequestDefaultHeaders) : ..RequestDefaultHeaders, 1: {})
}

Method SetRequestDefaultCookies(headers As %DynamicArray) As %Status
{
  set ..RequestDefaultCookies = headers
  return $$$OK
}

Method GetRequestDefaultCookies() As %DynamicObject [ CodeMode = expression ]
{
$select($isobject(..RequestDefaultCookies) : ..RequestDefaultCookies, 1: {})
}

Method Validate() As %Status
{
  set status = $$$OK

  if ..WebApplication = "" set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Web application name is required."))
  if '$isobject(..DispatchHandler) set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Dispatch handler is required."))
  if '$isobject(..RequestDefaultHeaders) || '..RequestDefaultHeaders.%Extends("%DynamicObject") {
    set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Request default headers must be an instance of %DynamicObject if provided."))
  }
  if '$isobject(..RequestDefaultCookies) || '..RequestDefaultCookies.%Extends("%DynamicArray") {
    set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Request default cookies must be an instance of %DynamicArrayObject if provided."))
  }  

  if $$$ISERR(status) {
    set status = $$$EMBEDSC($$$ERROR($$$GeneralError, "Configuration validation error: One or more settings are missing or wrong:"), status)
  }

  return status
}

}
