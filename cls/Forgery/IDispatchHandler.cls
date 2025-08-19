Class Forgery.IDispatchHandler [ Abstract ]
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, context As Forgery.CSP.Context, interceptor As Forgery.IO.DeviceInterceptor) As %Status [ Abstract ]
{
  $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "OnDispatch"))
}

Method OnDispose() As %Status
{
 $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "OnDispose"))
}

}
