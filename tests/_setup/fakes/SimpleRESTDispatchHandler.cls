Class Test.Forgery.Setup.SimpleRESTDispatchHandler Extends (%RegisteredObject, Forgery.IDispatchHandler)
{

Method Handle(resource As %String, httpMethod As %String, restDispatchClass As %String) As %Status
{
  $$$ThrowOnError($classmethod(restDispatchClass, "DispatchRequest", resource, httpMethod))
  return $$$OK
}

}
