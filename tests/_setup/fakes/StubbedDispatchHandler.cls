Class Test.Forgery.Setup.StubbedDispatchHandler Extends (Forgery.IDispatchHandler, %RegisteredObject)
{

Property Message As %String;

Method %OnNew(message As %String = "") As %Status
{
  set ..Message = message

  return $$$OK
}

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, cspContext As Forgery.CSP.Context, interceptor As Forgery.IO.DeviceInterceptor) As %Status
{
  
  // Must publish these variables because of how %CSP.Page works.
  set %request = cspContext.Request
  set %response = cspContext.Response
  set %session = cspContext.Session
  
  if ..Message '= "" {
    write ..Message
    return $$$OK
  }

  set reply = ""
  
  if httpMethod = "GET" {
    write { "message": (%request.Get("message")) }.%ToJSON()
  } elseif (httpMethod = "POST") || (httpMethod = "PATCH") || (httpMethod = "PUT") {
    do %request.Content.Rewind()
    do %request.Content.OutputToDevice()
  } elseif httpMethod = "HEAD" {
    write ""
  }

  return $$$OK
}

Method OnDispose() As %Status
{
 kill %request, %session, %request
 return $$$OK
}

}
