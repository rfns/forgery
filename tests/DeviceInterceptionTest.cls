Class Test.Forgery.DeviceInterception Extends %UnitTest.TestCase
{

Property Context As %DynamicObject [ Private ];

Method OnBeforeOneTest() As %Status
{
  set baseUrl = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL
  set ..Context = {
    "Request": (##class(Forgery.CSP.Request).%New(baseUrl, "GET",, { "AppUrl": (baseUrl) })),
    "Response": (##class(%CSP.Response).%New())
  }

  return $$$OK
}

Method TestInterceptionCycle()
{
  set expectedContent = "intercepted messsage"
  
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New()

  set interceptionStatus1 = interceptor.StartInterception()
  write expectedContent
  set interceptionStatus2 = interceptor.EndInterception()

  do $$$AssertStatusOK(interceptionStatus1)
  do $$$AssertStatusOK(interceptionStatus2)

  do $$$AssertEquals(interceptor.GetInterceptedContent().Read(), expectedContent)
}

Method TestVariableLifetime()
{
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New()
  set publicVarPreExistsPostConstrutor = $data(%forgeryDeviceInterceptedStream)

  do interceptor.StartInterception()
  set publicVarExistsPostStartedInterception = $data(%forgeryDeviceInterceptedStream)

  set interceptor = "" // calls EndInterception on %OnClose.

  set publicVarExistsPostEndedInterception = $data(%forgeryDeviceInterceptedStream)

  do $$$AssertNotTrue(publicVarPreExistsPostConstrutor)
  do $$$AssertTrue(publicVarExistsPostStartedInterception)
  do $$$AssertNotTrue(publicVarExistsPostEndedInterception)
}

Method TestCanChangeCharset()
{
 
  set interceptor1 = ##class(Forgery.IO.DeviceInterceptor).%New("utf-8")
  set expectedTable1 = ##class(%Net.Charset).GetTranslateTable("utf-8")

  set interceptor2 = ##class(Forgery.IO.DeviceInterceptor).%New("iso-8859-1")
  set expectedTable2 = ##class(%Net.Charset).GetTranslateTable("iso-8859-1")

  write interceptor1.GetInterceptedContent().TranslateTable, " ", interceptor2.GetInterceptedContent().TranslateTable

  do $$$AssertEquals(interceptor1.GetInterceptedContent().TranslateTable, expectedTable1)
  do $$$AssertEquals(interceptor2.GetInterceptedContent().TranslateTable, expectedTable2)
}

}
