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

Method NewFormData() As Forgery.IFormData
{
  return ##class(Forgery.FormData).%New()
}

}
