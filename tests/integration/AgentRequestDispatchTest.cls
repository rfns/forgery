Class Test.Integration.Forgery.AgentRequestDispatchTest Extends %UnitTest.TestCase
{

Property Agent As Forgery.Agent;

Method OnBeforeOneTest() As %Status
{
 
  set builder = ##class(Forgery.AgentBuilder).%New()
  
  do builder.SetWebApplication("/api/atelier")
  do builder.UseDefaultDispatchHandler()
  
  $$$QuitOnError(builder.Build(.agent))

  set ..Agent = agent
  return $$$OK
}

Method WithPrefix(resource As %String) [ CodeMode = expression, Private ]
{
$$$FormatText("/v1/%1%2", $namespace, resource)
}

Method TestGETForgerySources()
{
  set sc = ..Agent.Get(..WithPrefix("/doc/Forgery.AgentBuilder.cls"))
  do $$$AssertEquals(..Agent.GetLastResponse().Status, "200 OK")
}

}
