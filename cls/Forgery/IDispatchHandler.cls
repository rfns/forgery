Class Forgery.IDispatchHandler [ Abstract ]
{

Method Handle(resource As %String, httpMethod As %String, restDispatchClass As %String) As %Status [ Abstract ]
{
  $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "Handle"))
}

}
