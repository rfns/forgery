Class Forgery.Configuration Extends %RegisteredObject
{

Property BaseURL As %String [ Private ];

Property DispatchHandler As Forgery.IDispatchHandler [ Private ];

Property DeviceLineTerminator As %String [ InitialExpression = {$char(13,10)}, Private ];

Property DeviceCharset As %String [ InitialExpression = "utf-8", Private ];

Property DefaultRequestHeaders As %DynamicObject [ InitialExpression = {{}}, Private ];

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

Method SetDefaultRequestHeaders(headers As %DynamicObject) As %Status
{
  set ..DefaultRequestHeaders = headers
  return $$$OK
}

Method GetDefaultRequestHeaders() As %DynamicObject [ CodeMode = expression ]
{
..DefaultRequestHeaders
}

Method Validate() As %Status
{
  set status = $$$OK

  if ..BaseURL = "" set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Base URL is required."))
  if '$isobject(..DispatchHandler) set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Dispatch handler is required."))
  if '$isobject(..DefaultRequestHeaders) || ..DefaultRequestHeaders.%Extends("%DynamicObject") {
    set status = $$$ADDSC(status, $$$ERROR($$$GeneralError, "Default request headers must be an instance of %DynamicObject if provided."))
  }

  if $$$ISERR(status) {
    set status = $$$EMBEDSC($$$ERROR($$$GeneralError, "Configuration validation error: One or more settings are missing:"), status)
  }

  return status
}

}
