Class Test.Forgery.Setup.WebAppCreator Extends %Projection.AbstractProjection [ CompileAfter = Test.Forgery.Setup.Parameters ]
{

Projection CreatorProjection As Test.Forgery.Setup.WebAppCreator;

ClassMethod CreateProjection() As %Status
{
  set baseUrl = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL
  set dispatchClass = ##class(Test.Forgery.Setup.Parameters).#TESTDISPATCHCLASS
  
  new $namespace
  set $namespace = "%SYS"

  if ##class(Security.Applications).%ExistsId(baseUrl) {
    return $$$OK
  }

  set webApp = ##class(Security.Applications).%New(baseUrl)
  set webApp.Name = baseUrl
  set webApp.DispatchClass = dispatchClass
  set webApp.CookiePath = baseUrl
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
  set baseUrl = ##class(Test.Forgery.Setup.Parameters).#TESTBASEURL
  
  new $namespace
  set $namespace = "%SYS"

  do ##class(Security.Applications).%DeleteId(baseUrl)
  return $$$OK
}

}
