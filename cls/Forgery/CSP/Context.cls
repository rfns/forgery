Class Forgery.CSP.Context Extends %RegisteredObject
{

Property Request As Forgery.CSP.Request [ ReadOnly ];

Property Response As %CSP.Response [ ReadOnly ];

Property Session As %CSP.Session [ ReadOnly ];

Method %OnNew(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, appInfo As %DynamicObject, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  set i%Request = ##class(Forgery.CSP.Request).%New(resource, httpMethod, data, appInfo, overrides)
  set i%Response = ##class(%CSP.Response).%New()
  set i%Session = ##class(%CSP.Session).%New(-1, 0)

  return $$$OK
}

}
