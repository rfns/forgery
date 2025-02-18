Class Forgery.Internal.BaseAgent Extends Forgery.IAgent
{

Parameter HTTPPOSTMETHOD = "POST";

Parameter HTTPGETMETHOD = "GET";

Parameter HTTPPUTMETHOD = "PUT";

Parameter HTTPDELETEMETHOD = "DELETE";

Parameter HTTPPATCHMETHOD = "PATCH";

Parameter HTTPOPTIONSMETHOD = "OPTIONS";

Parameter HTTPHEADMETHOD = "HEAD";

Property Configuration As Forgery.Configuration [ Private ];

Property RequestDispatcher As Forgery.Internal.RequestDispatcher [ Private ];

Method %OnNew(configuration As Forgery.Configuration, requestDispatcherFactory As Forgery.Internal.RequestDispatcherFactory) As %Status
{
  set ..RequestDispatcher = requestDispatcherFactory.CreateUsingConfiguration(configuration)
  return $$$OK
}

Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Post"))
}

Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Get"))
}

Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Put"))
}

Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Delete"))
}

Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Head"))
}

Method Patch(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) [ Abstract ]
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Patch"))
}

Method DoRequest(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Private ]
{
  return ..RequestDispatcher.Dispatch(resource, httpMethod, data, overrides)
}

Method GetLastContext() As Forgery.CSP.Context
{
  return ..RequestDispatcher.GetLastContext()
}

Method GetLastReply() As %Stream.Object
{
  return ..RequestDispatcher.GetLastReply()
}

}
