Class Forgery.CSP.ContextFactory Extends %RegisteredObject
{

Method Create(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, appInfo As %DynamicObject, overrides As %DynamicObject = {$$$NULLOREF})
{
  return ##class(Forgery.CSP.Context).%New(resource, httpMethod, data, appInfo, overrides)
}

}
