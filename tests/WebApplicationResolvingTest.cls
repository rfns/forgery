Class Test.Forgery.WebApplicationResolving Extends (%UnitTest.TestCase, Test.Forgery.Extensions.AssertiveStatus)
{

Parameter TESTBASEURL = "/test/integration/forgery/api";

Method OnBeforeAllTests() As %Status
{
  new $namespace 
  set $namespace = "%SYS"

  set app = ##class(Security.Applications).%New()
  set app.Name = ..#TESTBASEURL
  set app.DispatchClass = "Test.Forgery.FakeAPI"
  set app.MatchRoles = "%:All"
  set app.InbndWebServicesEnabled = 1
  set app.Enabled = 1
  set app.NameSpace = "USER"

  return app.%Save()
}

Method OnAfterAllTests() As %Status
{
  new $namespace
  set $namespace = "%SYS"

  return ##class(Security.Applications).%DeleteId(..#TESTBASEURL)
}

Method WithBaseURL(resource As %String)
{
  return $$$FormatText("%1/%2", ..#TESTBASEURL, resource)
}

Method TestResolveAPIThroughUrl()
{
  set resolver = ##class(Forgery.Internal.WebApplicationResolver).%New()

  do $$$AssertStatusOK(resolver.Resolve(..WithBaseURL("/hello"), .info))
  do $$$AssertEquals(info.DispatchClass, "Test.Forgery.FakeAPI")
}

Method TestGetErrorIfWebAppDoesntExist()
{
  set resolver = ##class(Forgery.Internal.WebApplicationResolver).%New()
  do $$$AssertEquals(1, ..MatchStatus(resolver.Resolve("/doesnt/exist", .info), "#5001: Web application resolver error: No application matching the url '/doesnt/exist' has been found."))
}

}
