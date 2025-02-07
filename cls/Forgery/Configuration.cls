Class Forgery.Configuration Extends %RegisteredObject
{

Property BaseURL As %String [ Private ];

Property DispatchHandler As Forgery.IDispatchHandler [ Private ];

Property DeviceLineTerminator As %String [ InitialExpression = {$char(13,10)}, Private ];

Property DeviceCharset As %String [ InitialExpression = "utf-8", Private ];

Property RequestDefaultHeaders As %DynamicObject [ InitialExpression = {{}}, Private ];

Property RequestDefaultCookies As %DynamicArray [ InitialExpression = {[]}, Private ];

Method SetBaseURL(baseURL As %String) As %Status
{
  set ..BaseURL = baseURL
  return $$$OK
}

Method GetBaseURL() As %String [ CodeMode = expression ]
{
..BaseURL
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
..RequestDefaultHeaders
}

Method SetRequestDefaultCookies(headers As %DynamicArray) As %Status
{
  set ..RequestDefaultCookies = headers
  return $$$OK
}

Method GetRequestDefaultCookies() As %DynamicObject [ CodeMode = expression ]
{
..RequestDefaultCookies
}

Method Validate() As %Status
{
  set status = $$$OK

  if ..BaseURL = "" set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Base URL is required."))
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
