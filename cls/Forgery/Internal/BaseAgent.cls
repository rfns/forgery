Class Forgery.Internal.BaseAgent Extends (%RegisteredObject, Forgery.IAgent)
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

Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPPOSTMETHOD, data, overrides)
}

Method Get(resource As %String, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPGETMETHOD,, overrides)
}

Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPPUTMETHOD, data, overrides)
}

Method Delete(resource As %String, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPDELETEMETHOD, overrides)
}

Method Head(resource As %String, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPHEADMETHOD, overrides)
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
