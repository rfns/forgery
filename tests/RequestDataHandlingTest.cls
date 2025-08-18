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

Method TestContentTypeIsSetAccordingToPayload()
{
  set payload1 = ##class(Forgery.FormData).%New()
  set payload2 = ##class(%Stream.GlobalCharacter).%New()

  set request1 = ..CreateRequestWithDefaults(payload1, "POST", "/")
  set request2 = ..CreateRequestWithDefaults(payload2, "POST", "/")

  do $$$AssertEquals(request1.ContentType, "multipart/form-data")
  do $$$AssertEquals(request2.ContentType, "application/octet-stream")
}

Method TestHandleFormDataAsMimeData()
{
  set payload = ##class(Forgery.FormData).%New()

  do payload.Append("key1", "value1")
  do payload.Append("key2", "value2")

  set request = ..CreateRequestWithDefaults(payload, "POST", "/")

  do $$$AssertEquals(request.GetMimeData("key1"), "value1")
  do $$$AssertEquals(request.GetMimeData("key2"), "value2")
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
