Class Test.Forgery.Setup.FakeRouter Extends %CSP.REST
{

XData UrlMap
{
<Routes>
  <Route Url="/hello" Method="GET" Call="SayHello" />
</Routes>
}

ClassMethod SayHello()
{
  write { "message": (%request.Get("message")) }.%ToJSON()
  return $$$OK
}

}
