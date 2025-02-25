Class Forgery.CSP.ContextFactory Extends %RegisteredObject
{

Property Preparer As Forgery.Internal.RequestPreparer [ Private ];

Property BaseUrl As %String [ Private ];

Method %OnNew() As %Status
{
  set ..Preparer = ##class(Forgery.Internal.RequestPreparer).%New()
  return $$$OK
}

Method Create(application As %String, resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF})
{
  set sessionId = $System.Encryption.GenCryptToken()
  set session = ##class(%CSP.Session).%New(sessionId, 0)
  set request = ##class(Forgery.CSP.Request).%New(application, resource, httpMethod)
  set response = ##class(%CSP.Response).%New()

  do ..Preparer.Prepare(request, data, overrides)

  return ##class(Forgery.CSP.Context).%New(session, request, response)
}

}
