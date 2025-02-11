Class Test.Forgery.Setup.FakeRouter Extends %CSP.REST
{

XData UrlMap
{
<Routes>
  <Route Url="/hello" Method="GET" Call="SayHello" />
</Routes>
}

ClassMethod SayHello(message As %String)
{
  write { "message": (message) }.%ToJSON()
}

}
