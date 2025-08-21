Class Forgery.IAgent [ Abstract ]
{

/// Sends a HTTP POST request to a web application resource.
Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Post"))
}

/// Sends a HTTP GET request to a web application resource.
Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Get"))
}

/// Sends a HTTP PUT request to a web application resource.
Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Put"))
}

/// Sends a HTTP DELETE request to a web application resource.
Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Delete"))
}

/// Sends a HTTP HEAD request to a web application resource.
Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Head"))
}

/// Sends a HTTP PATCH request to a web application resource.
Method Patch(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF})
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "Patch"))
}

/// Shortcut method for retrieving the last operation context, on which an operation stands for the composition of three stateful CSP objects: request, response and session.
/// 
/// Please note that the behavior of these objects may slightly differ from their real implementations.
Method GetLastContext() As Forgery.CSP.Context
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "GetLastContext"))
}

/// Retrieves the last reply sent back by the dispatch class.
/// 
/// This is what you'd expect to receive in the browser and truthfully so, should be used for test assertions.
Method GetLastReply() As %Stream.Object
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "GetLastReply"))
}

/// Creates a new FormData object.
/// 
/// This is required for simulating the dispatch of multipart/form-data payloads.
Method NewFormData() As Forgery.IFormData
{
  $$$ThrowOnError($$$ERROR($$$MethodNotImplemented, "NewFormData"))
}

}
