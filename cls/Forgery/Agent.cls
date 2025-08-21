/// End-user agent for sending requests.
/// 
/// This class provides the implementations required for dispatching requests.
/// However, it's recommended to instantiate it using the builder.
Class Forgery.Agent Extends (%RegisteredObject, Forgery.Internal.BaseAgent)
{

/// Sends a HTTP POST request to a web application resource.
Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPPOSTMETHOD, resource, data, overrides)
}

/// Sends a HTTP GET request to a web application resource.
Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPGETMETHOD, resource, queryParams, overrides)
}

/// Sends a HTTP PUT request to a web application resource.
Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPPUTMETHOD, resource, data, overrides)
}

/// Sends a HTTP DELETE request to a web application resource.
Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPDELETEMETHOD, resource, queryParams, overrides)
}

/// Sends a HTTP HEAD request to a web application resource.
Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPHEADMETHOD, resource, queryParams, overrides)
}

/// Sends a HTTP Patch request to a web application resource.
Method Patch(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPPATCHMETHOD, resource, data, overrides)
}

}
