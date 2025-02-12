Class Forgery.Agent Extends (%RegisteredObject, Forgery.Internal.BaseAgent)
{

Method Post(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPPOSTMETHOD, data, overrides)
}

Method Get(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPGETMETHOD, queryParams, overrides)
}

Method Put(resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPPUTMETHOD, data, overrides)
}

Method Delete(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPDELETEMETHOD, queryParams, overrides)
}

Method Head(resource As %String, queryParams As %DynamicObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  return ..DoRequest(resource, ..#HTTPHEADMETHOD, queryParams, overrides)
}

}
