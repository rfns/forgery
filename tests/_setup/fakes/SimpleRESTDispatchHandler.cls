Class Test.Forgery.Setup.SimpleRESTDispatchHandler Extends (%RegisteredObject, Forgery.IDispatchHandler)
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, cspContext As Forgery.CSP.Context) As %Status
{
  // Must publish these variables because of how %CSP.Page works.
  set %request = cspContext.Request
  set %response = cspContext.Response
  set %session = cspContext.Session
  
  $$$ThrowOnError($classmethod(restDispatchClass, "DispatchRequest", resource, httpMethod))
  return $$$OK
}

Method OnDispose() As %Status
{
 kill %request, %session, %request
 return $$$OK
}

}
