Class Test.Forgery.RESTClassResolvingTest Extends (%UnitTest.TestCase, Test.Forgery.Extensions.AssertiveStatus)
{

Property BaseURL As %String [ InitialExpression = {##class(Test.Forgery.Setup.Parameters).#TESTBASEURL} ];

Property DispatchClass As %String [ InitialExpression = {##class(Test.Forgery.Setup.Parameters).#TESTDISPATCHCLASS} ];

Method WithBaseURL(resource As %String)
{
  return $$$FormatText("%1/%2", ..BaseURL, resource)
}

Method TestResolveAPIThroughUrl()
{
  set resolver = ##class(Forgery.Internal.RESTClassResolver).%New(..BaseURL)

  do $$$AssertStatusOK(resolver.Resolve(..WithBaseURL("/hello"), .info))
  do $$$AssertEquals(info.DispatchClass, ..DispatchClass)
}

Method TestGetErrorIfWebAppDoesntExist()
{
  set resolver = ##class(Forgery.Internal.RESTClassResolver).%New("/invalid/app")
  do $$$AssertEquals(..MatchStatus(resolver.Resolve("/doesnt/exist", .info), "#5001: Web application resolver error: No application matching the url '/invalid/app/doesnt/exist' has been found."), 1)
}

}
