Class Test.Forgery.RequestDataHandlingTest Extends %UnitTest.TestCase
{

Method CreateRequestWithDefaults(data As %Any, method As %String = "GET", resource As %String = "", overrides = {{ "headers": {}, "cookies": [] }}) As Forgery.CSP.Request
{
  set baseUrl = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL
  set appInfo = { "AppUrl": (baseUrl) }

  set preparer = ##class(Forgery.Internal.RequestPreparer).%New()
  set request = ##class(Forgery.CSP.Request).%New(
    baseUrl,
    resource,
    method
  )

  do preparer.Prepare(request, data, overrides)

  return request
}

Method TestTransformDynamicObjectToContentStream()
{
  set payload = { "message": "hello from dynamic object!" }
  set request = ..CreateRequestWithDefaults(payload, "POST")

  do $$$AssertTrue($isobject(request.Content) && request.Content.%IsA("%CSP.CharacterStream"))
  do $$$AssertEquals(request.Content.Read(), payload.%ToJSON())
}

Method TestConsumeQueryParametersFromUrl()
{
  set request = ..CreateRequestWithDefaults("", "GET", "?q1=consume&q2=this&q3=message")

  do $$$AssertEquals(request.Get("q1"), "consume")
  do $$$AssertEquals(request.Get("q2"), "this")
  do $$$AssertEquals(request.Get("q3"), "message")
}

Method TestConsumeQueryParametersFromDataWhenHTTPGET()
{
  set payload = { "q1": "consume", "q2": "this", "q3": "message" }
  set request = ..CreateRequestWithDefaults(payload, "GET")

  do $$$AssertEquals(request.Get("q1"), "consume")
  do $$$AssertEquals(request.Get("q2"), "this")
  do $$$AssertEquals(request.Get("q3"), "message")
}

Method TestConsumeHeadersFromOverrides()
{
  set request = ..CreateRequestWithDefaults("", "GET", "/", { "headers": { "X-Add-This-Header": "here" } })

  do $$$AssertEquals(request.CgiEnvs("HTTP_X_ADD_THIS_HEADER"), "here")
}

Method TestConsumeAuthorizationHeaderFromOverrides()
{
  set request = ..CreateRequestWithDefaults("", "GET", "/", { "headers": { "Authorization": "Basic blah blah blah" } })

  do $$$AssertEquals(request.Authorization, "Basic blah blah blah")
}

Method TestConsumePayloadAsMimeDataIfHeaderIsSet()
{
  set payload = [{ "key": "value1" }, { "key": "value2" }, { "key": "value3" }]
  set request = ..CreateRequestWithDefaults(payload, "POST", "/", { "headers": { "Content-Type": "multipart/form-data" } })

  do $$$AssertEquals(request.MimeData("key", 1), "value1")
  do $$$AssertEquals(request.MimeData("key", 2), "value2")
  do $$$AssertEquals(request.MimeData("key", 3), "value3")
}

Method TestConsumeBinaryPayloadAsData()
{
  set payload = ##class(%Stream.FileBinary).%New()
  do payload.LinkToFile("/usr/bin/file")
  
  set request = ..CreateRequestWithDefaults(payload, "POST", "/")

  do $$$AssertTrue(request.Content.%IsA("%CSP.BinaryStream"))
  do $$$AssertNotTrue(request.Content.IsCharacter())
}

}
