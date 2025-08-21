Class Forgery.CSP.BasicDispatchHandler Extends (%RegisteredObject, Forgery.IDispatchHandler)
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, cspContext As Forgery.CSP.Context, interceptor As Forgery.IO.DeviceInterceptor) As %Status
{
  // Must publish these variables because of how %CSP.Page works.
  set %request = cspContext.Request
  set %response = cspContext.Response
  set %session = cspContext.Session
  
  try {
    $$$ThrowOnError($classmethod(restDispatchClass, "DispatchRequest", resource, httpMethod))
  } catch exception {
    set %response.OutputSessionToken = 0
    do interceptor.Flush()
    try {        
      do $classmethod(restDispatchClass, "Http500", exception)
    } catch errorHandlingException {
      return errorHandlingException.AsStatus()        
    }
  }
  return $$$OK
}

Method OnDispose() As %Status
{
  kill %request, %session, %response
  return $$$OK
}

}
