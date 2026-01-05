Class Test.Forgery.Setup.WebAppCreator Extends %Projection.AbstractProjection
{

Parameter TESTBASEURL = "/test/forgery/api";

Parameter TESTDISPATCHCLASS = "Test.Forgery.Setup.FakeRouter";

Projection WebAppProjection As Test.Forgery.Setup.WebAppCreator;

ClassMethod CreateProjection() As %Status
{
  
  new $namespace
  set $namespace = "%SYS"

  if ##class(Security.Applications).%ExistsId(..#TESTBASEURL) {
    return $$$OK
  }

  set webApp = ##class(Security.Applications).%New(..#TESTBASEURL)
  set webApp.Name = ..#TESTBASEURL
  set webApp.DispatchClass = ..#TESTDISPATCHCLASS
  set webApp.CookiePath = ..#TESTBASEURL
  set webApp.NameSpace = "DEV"
  set webApp.UseCookies = 2
  set webApp.Recurse = 1
  set webApp.Type = 2
  set webApp.InbndWebServicesEnabled = 1
  set webApp.AutoCompile = 1

  return webApp.%Save()
}

ClassMethod RemoveProjection() As %Status
{
 
  new $namespace
  set $namespace = "%SYS"

  do ##class(Security.Applications).%DeleteId(..#TESTBASEURL)
  return $$$OK
}

}
