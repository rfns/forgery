Class Test.Forgery.ConfigurationTest Extends (%UnitTest.TestCase, Test.Forgery.Extensions.AssertiveStatus)
{

Method TestValidateRequiredConfigs()
{
  set configuration = ##class(Forgery.Configuration).%New()
  do $$$AssertEquals(..MatchStatus(configuration.Validate(), "#5001: Configuration validation error: One or more settings are missing or wrong:", "#5001: BaseURL configuration is required.", "#5001: Dispatch handler is required."), 1)
}

Method TestCanSetAndGetBaseUrl()
{
  set expectedUrl = "/testing/api"
  set config = ##class(Forgery.Configuration).%New()

  do $$$AssertStatusOK(config.SetBaseURL(expectedUrl))
  do $$$AssertEquals(config.GetBaseURL(), expectedUrl)
}

Method TestSetAndGetDispatchHandler()
{
  set expectedDispatcher = ##class(Test.Forgery.FakeRouteDispatcher).%New("")
  set config = ##class(Forgery.Configuration).%New()

  do $$$AssertStatusOK(config.SetDispatchHandler(expectedDispatcher))
  do $$$AssertEquals(config.GetDispatchHandler(), expectedDispatcher)
}

Method TestCanSetAndGetDeviceInterceptorLineTerminator()
{
  set config = ##class(Forgery.Configuration).%New()
  set expectedLineTerminator = $char(9)

  do $$$AssertStatusOK(config.SetDeviceLineTerminator(expectedLineTerminator))
  do $$$AssertEquals(config.GetDeviceLineTerminator(), expectedLineTerminator)
}

Method TestCanSetAndGetDeviceCharsetTerminator()
{
  set config = ##class(Forgery.Configuration).%New()
  set expectedCharset = "iso-8859-1"

  do $$$AssertStatusOK(config.SetDeviceCharset(expectedCharset))
  do $$$AssertEquals(config.GetDeviceCharset(), expectedCharset)
}

Method TestCanSetAndGetRequestDefaultHeaders()
{
  set config = ##class(Forgery.Configuration).%New()
  set headers = { "X-Authorization": "Basic blahblahblah" }
  
  do $$$AssertStatusOK(config.SetRequestDefaultHeaders(headers))
  do $$$AssertEquals(config.GetRequestDefaultHeaders(), headers)
}

Method TestCanSetAndGetDefaultCookies()
{
  set config = ##class(Forgery.Configuration).%New()
  set cookies = [{"key": "test_cookies", "value": "blah" }]
  
  do $$$AssertStatusOK(config.SetRequestDefaultCookies(cookies))
  do $$$AssertEquals(config.GetRequestDefaultCookies(), cookies)
}

Method TestValidateInvalidHeaders()
{
  set config = ##class(Forgery.Configuration).%New()
  do config.SetBaseURL("/whatever")
  do config.SetDispatchHandler(##class(Test.Forgery.FakeRouteDispatcher).%New("whatever"))
  
  do $$$AssertStatusOK(config.SetRequestDefaultHeaders([]))
  do $$$AssertEquals(..MatchStatus(config.Validate(), "#5001: Configuration validation error: One or more settings are missing or wrong:", "#5001: Request default headers must be an instance of %DynamicObject if provided."), 1)
}

Method TestValidateInvalidCookies()
{
  set config = ##class(Forgery.Configuration).%New()
  do config.SetBaseURL("/whatever")
  do config.SetDispatchHandler(##class(Test.Forgery.FakeRouteDispatcher).%New("whatever"))
  
  do $$$AssertStatusOK(config.SetRequestDefaultCookies({}))
  do $$$AssertEquals(..MatchStatus(config.Validate(), "#5001: Configuration validation error: One or more settings are missing or wrong:", "#5001: Request default cookies must be an instance of %DynamicArrayObject if provided."), 1)
}

}
