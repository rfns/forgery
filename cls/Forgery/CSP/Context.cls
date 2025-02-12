Class Forgery.CSP.Context Extends %RegisteredObject
{

Property Request As Forgery.CSP.Request;

Property Response As %CSP.Response;

Property Session As %CSP.Session;

Method %OnNew(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, appInfo As %DynamicObject, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  set ..Request = ##class(Forgery.CSP.Request).%New(resource, httpMethod, data, appInfo, overrides)
  set ..Response = ##class(%CSP.Response).%New()
  set ..Session = ##class(%CSP.Session).%New($System.Encryption.GenCryptToken(), 0)

  return $$$OK
}

}
