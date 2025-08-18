Class Forgery.Agent Extends (%RegisteredObject, Forgery.Internal.BaseAgent)
{

Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPPOSTMETHOD, resource, data, overrides)
}

Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPGETMETHOD, resource, queryParams, overrides)
}

Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPPUTMETHOD, resource, data, overrides)
}

Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPDELETEMETHOD, resource, queryParams, overrides)
}

Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(..#HTTPHEADMETHOD, resource, queryParams, overrides)
}

}
