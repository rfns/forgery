Class Forgery.IDispatchHandler [ Abstract ]
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, context As Forgery.CSP.Context) As %Status [ Abstract ]
{
  $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "Handle"))
}

Method OnDispose() As %Status
{
 $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "AfterHandle"))
}

}
