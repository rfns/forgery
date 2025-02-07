Class Test.Forgery.ConfigurationTest Extends (%UnitTest.TestCase, Test.Forgery.Extensions.AssertiveStatus)
{

Method TestValidateRequiredConfigs()
{
  set configuration = ##class(Forgery.Configuration).%New()
  do $$$AssertEquals(..MatchStatus(configuration.Validate(), "#5001: Configuration validation error: One or more settings are missing:", "#5001: BaseURL configuration is required.", "#5001: Dispatch handler is required."), 1)
}

Method TestCanSetAndGetBaseUrl()
{
  set expectedUrl = "/testing/api"
  set config = ##class(Forgery.Configuration).%New()
  do config.SetBaseURL(expectedUrl)
  
  do $$$AssertEquals(config.GetBaseURL(), expectedUrl)
}

Method TestSetAndGetDispatchHandler()
{
  set expectedDispatcher = ##class(Test.Forgery.FakeRouteDispatcher).%New("")
  set config = ##class(Forgery.Configuration).%New()

  do config.SetDispatchHandler(expectedDispatcher)

  do $$$AssertEquals(config.GetDispatchHandler(), expectedDispatcher)
}

Method TestCanSetAndGetDeviceInterceptorLineTerminator()
{
  set config = ##class(Forgery.Configuration).%New()
  set expectedLineTerminator = $char(9)

  do config.SetDeviceLineTerminator(expectedLineTerminator)

  do $$$AssertEquals(config.GetDeviceLineTerminator(), expectedLineTerminator)
}

Method TestCanSetAndGetDeviceCharsetTerminator()
{
  set config = ##class(Forgery.Configuration).%New()
  set expectedCharset = "iso-8859-1"

  do config.SetDeviceCharset(expectedCharset)

  do $$$AssertEquals(config.GetDeviceCharset(), expectedCharset)
}

}
