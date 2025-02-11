Class Test.Forgery.RequestDispatchingTest Extends %UnitTest.TestCase
{

Property Configuration As Forgery.Configuration;

Property Dispatcher As Forgery.Internal.RequestDispatcher;

Method OnBeforeOneTest() As %Status
{
  set ..Configuration = ##class(Forgery.Configuration).%New()
  do ..Configuration.SetBaseURL(##class(Test.Forgery.Setup.Parameters).#TESTBASEURL)
  do ..Configuration.SetDispatchHandler(##class(Test.Forgery.Setup.StubbedDispatchHandler).%New())

  set ..Dispatcher = ##class(Forgery.Internal.RequestDispatcherFactory).CreateUsingConfiguration(..Configuration)
  return $$$OK
}

Method OnAfterAllTests() As %Status
{
  do ##class(%Device).ReDirectIO(1)
  return $$$OK
}

Method TestCanDispatchWithQueryParams()
{
  do $$$AssertStatusOK(..Dispatcher.Dispatch("/hello?message=testing message", "GET"))

  do $$$AssertEquals(..Dispatcher.GetLastReply().Read(), { "message": "testing message"}.%ToJSON())
  do $$$AssertEquals(..Dispatcher.GetLastContext().Request.Method, "GET")
}

Method TestCanDispatchWithPayload()
{
  set payload = { "message": "Hello from POST dispatch!" }
  do $$$AssertStatusOK(..Dispatcher.Dispatch("/hello", "POST", payload))

  do $$$AssertEquals(..Dispatcher.GetLastReply().Read(), payload.%ToJSON())
  do $$$AssertEquals(..Dispatcher.GetLastContext().Request.Method, "POST")
}

}
