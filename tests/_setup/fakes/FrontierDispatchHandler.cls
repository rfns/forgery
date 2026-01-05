Class Test.Forgery.Setup.FrontierDispatchHandler Extends (%RegisteredObject, Forgery.IDispatchHandler)
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, context As Forgery.CSP.Context) As %Status
{
  set %request = context.Request
  set %response = context.Response
  set %session = context.Session

  set %frontier = ##class(Frontier.Context).%New(%session, %request, %response)

  $$$ThrowOnError($classmethod(restDispatchClass, "HandleRequest", resource, httpMethod))
  return $$$OK
}

Method OnDispose() As %Status
{
 kill %request, %session, %request
 return $$$OK
}

}
