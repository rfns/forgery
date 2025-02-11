Class Test.Forgery.WebApplicationResolving Extends (%UnitTest.TestCase, Test.Forgery.Extensions.AssertiveStatus)
{

Property BaseURL As %String;

Property DispatchClass As %String;

Method OnBeforeAllTests() As %Status
{
  set ..BaseURL = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL
  set ..DispatchClass = ##class(Test.Forgery.Setup.Parameters).#TESTDISPATCHCLASS
  
  new $namespace 
  set $namespace = "%SYS"

  set app = ##class(Security.Applications).%New()
  set app.Name = ..BaseURL
  set app.DispatchClass = ..DispatchClass
  set app.MatchRoles = "%:All"
  set app.InbndWebServicesEnabled = 1
  set app.Enabled = 1
  set app.NameSpace = "USER"

  return app.%Save()
}

Method OnAfterAllTests() As %Status
{
  set baseUrl = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL

  new $namespace
  set $namespace = "%SYS"

  return ##class(Security.Applications).%DeleteId(baseUrl)
}

Method WithBaseURL(resource As %String)
{
  return $$$FormatText("%1/%2", ..BaseURL, resource)
}

Method TestResolveAPIThroughUrl()
{
  set resolver = ##class(Forgery.Internal.WebApplicationResolver).%New(..BaseURL)

  do $$$AssertStatusOK(resolver.Resolve(..WithBaseURL("/hello"), .info))
  do $$$AssertEquals(info.DispatchClass, ..DispatchClass)
}

Method TestGetErrorIfWebAppDoesntExist()
{
  set resolver = ##class(Forgery.Internal.WebApplicationResolver).%New("/invalid/app")
  do $$$AssertEquals(..MatchStatus(resolver.Resolve("/doesnt/exist", .info), "#5001: Web application resolver error: No application matching the url '/invalid/app/doesnt/exist' has been found."), 1)
}

}
