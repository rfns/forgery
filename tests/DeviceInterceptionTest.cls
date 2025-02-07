Class Test.Forgery.DeviceInterception Extends %UnitTest.TestCase
{

Method TestInterceptRouteDispatcherWrites()
{
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New()
  set dispatcher = ##class(Test.Forgery.FakeRouteDispatcher).%New("reply with this")

  do $$$AssertStatusOK(interceptor.Intercept(dispatcher))
  do $$$AssertEquals(interceptor.GetInterceptedContent().Read(), "reply with this")
}

Method TestVariableLifetime()
{
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New()
  set dispatcher = ##class(Test.Forgery.FakeRouteDispatcher).%New("reply with this")

  set publicVarPreExistsPostConstrutor = $data(%forgeryDeviceInterceptedStream)
  do interceptor.Intercept(dispatcher)
  set publicVarPostExistsPostCall = $data(%forgeryDeviceInterceptedStream)

  do $$$AssertNotTrue(publicVarPreExistsPostConstrutor)
  do $$$AssertNotTrue(publicVarPostExistsPostCall)
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
