Class Forgery.IAgent [ Abstract ]
{

Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Post"))
}

Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Get"))
}

Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Put"))
}

Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Delete"))
}

Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Head"))
}

Method Patch(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF})
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Patch"))
}

Method GetLastContext() As Forgery.CSP.Context
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "GetLastContext"))
}

Method GetLastReply() As %Stream.Object
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "GetLastReply"))
}

Method NewFormData() As Forgery.IFormData
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "NewFormData"))
}

}
