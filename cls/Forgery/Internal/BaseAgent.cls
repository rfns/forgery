/// Base class for creating agents.
/// 
/// It also provides methods that can be used to quickstart requests.
Class Forgery.Internal.BaseAgent Extends Forgery.IAgent
{

Parameter HTTPPOSTMETHOD = "POST";

Parameter HTTPGETMETHOD = "GET";

Parameter HTTPPUTMETHOD = "PUT";

Parameter HTTPDELETEMETHOD = "DELETE";

Parameter HTTPPATCHMETHOD = "PATCH";

Parameter HTTPOPTIONSMETHOD = "OPTIONS";

Parameter HTTPHEADMETHOD = "HEAD";

/// The object containing the configuration used by the agent.
Property Configuration As Forgery.Configuration [ Private ];

/// The helper that handles the communication with REST dispatch classes.
Property RequestDispatcher As Forgery.Internal.RequestDispatcher [ Private ];

Method %OnNew(configuration As Forgery.Configuration, requestDispatcherFactory As Forgery.Internal.RequestDispatcherFactory) As %Status
{
  set ..RequestDispatcher = requestDispatcherFactory.CreateUsingConfiguration(configuration)
  return $$$OK
}

/// Shortcut method for concrete agents to dispatch requests without exposing the underlaying dispatcher helper.
Method DoRequest(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status [ Private ]
{
  return ..RequestDispatcher.Dispatch(resource, httpMethod, data, overrides)
}

/// Shortcut method for retrieving the last operation context, on which operation stands for three CSP objects: request, response and session.
/// 
/// Please note that the behavior of these objects may slightly differ from their real implementations.
Method GetLastContext() As Forgery.CSP.Context
{
  return ..RequestDispatcher.GetLastContext()
}

/// Retrieves the last reply sent back by the dispatch class.
/// 
/// This is what you'd expect to receive in the browser and truthfully so, should be used for test assertions.
Method GetLastReply() As %Stream.Object
{
  return ..RequestDispatcher.GetLastReply()
}

/// Creates a new FormData object.
/// 
/// This is required for simulating the dispatch of multipart/form-data payloads.
Method NewFormData() As Forgery.IFormData
{
  return ##class(Forgery.FormData).%New()
}

}
