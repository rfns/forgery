Class Forgery.Agent.Core Extends %RegisteredObject
{

Property Cache As %String [ Private ];

Property Namespace As %String [ Private ];

Property CookiesJar As %String [ MultiDimensional ];

Method %OnNew() As %Status
{
  set ..Namespace = $namespace
  set ..Cache = "^|"""_..Namespace_"""|Forgery.Agent"  
  return $$$OK
}

Method %OnClose() As %Status
{
  kill @i%Cache
  return $$$OK
}

Method Request(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0) As %Status
{
  set sc = $$$OK
  
  if '$isobject(settings.data) set settings.data = {}
  if '$isobject(settings.headers) set settings.headers = {}
  if '$isobject(settings.cookies) set settings.cookies = {}
  
  set settings = {
    "url": ($zconvert(settings.url, "I", "URL")), 
    "method": (settings.method), 
    "data": (settings.data),
    "headers": (settings.headers),
    "cookies": (settings.cookies)
  }
  
  $$$QuitOnError(..Forge(settings, .response))
  
  if outputToDevice = 1 do response.OutputToDevice()  
  return $$$OK
}

Method Forge(settings As %DynamicObject, response As %Stream.Object = "", outputToDevice As %Boolean = 0) As %Status [ Private ]
{
  kill %request, %session, %response
  new %request, %session, %response  
  
  // Makes sure that any attempts to change the namespace internally ends up in the original one.
  set fromNamespace = ..Namespace
  set str = ""
  
  merge cookiesJar = i%CookiesJar
  
  set %request = ##class(Forgery.Request).CreateFromSettings(settings, .cookiesJar)
  set %session = ##class(%CSP.Session).%New(-1, 0)
  set %response = ##class(%CSP.Response).%New()  
      
  try {
    set appInfo = ..GetApplicationInfoFromUrl(%request.URL)
    set %request.Application = appInfo.AppUrl
    if $extract(%request.URL) '= "/" set %request.URL = "/"_%request.URL
    $$$ThrowOnError(##class(Forgery.OutputCapturer).Capture(appInfo.DispatchClass, %request.URL, settings.method, .response))
    do PutReceivedCookiesIntoJar
  } catch ex {    
    set sc = ex.AsStatus()
  }
  kill %request, %session, %response
  
  set $namespace = fromNamespace
  return sc
  
PutReceivedCookiesIntoJar
  set index = ""
  for {
    set index = $order(%response.Cookies(index))
    quit:index=""
    
    set name = %response.Cookies(index, "n")
    set value = %response.Cookies(index, "v")
    
    set i%CookiesJar(name, index) = value   
  }
}

Method GetApplicationInfoFromUrl(url As %String) As %DynamicObject [ Private ]
{
   
  #define APPCACHE @i%Cache
  
  // Cache matches to prevent roundtrips to the %SYS namespace.
  if $data($$$APPCACHE) {
    set index = $lf($$$APPCACHE, url)
    if index > 0 return $$ListToJSON(index)
  }
        
  set $namespace = "%SYS"
    
  set result = {}  
  set name = ""
  set urlWithInitialSlash = $select($extract(url) '= "/" : "/"_url, 1: url)
  
  // Revert the ordering so that longer are considered first, note that the longer the path is higher is similarity with the url.
  set rows = ##class(%SQL.Statement).%ExecDirect(, "SELECT TOP 1 Name, DispatchClass, Path FROM SECURITY.APPLICATIONS WHERE ? %STARTSWITH Name ORDER BY LEN(Name) DESC", urlWithInitialSlash)
  if rows.%Next() {
    set $list($$$APPCACHE, *+1) = urlWithInitialSlash
    set index = $ll($$$APPCACHE)
    set name = rows.%Get("Name")
    set $list($$$APPCACHE, *+1) = name  
    set $list($$$APPCACHE, *+1) = rows.%Get("DispatchClass")
    set $list($$$APPCACHE, *+1) = rows.%Get("Path")
    set $list($$$APPCACHE, *+1) = name_$select($extract(name, *) '= "/" : "/", 1: "")
    set result = $$ListToJSON(index)
  }
  
  set $namespace = ..Namespace
  
  if name = "" $$$ThrowStatus($$$ERROR($$$GeneralError, "No application found for url: "_url))
  
  return result
  
ListToJSON(urlIndex)
  return {
    "Name": ($lg($$$APPCACHE, urlIndex + 1)),
    "DispatchClass": ($lg($$$APPCACHE, urlIndex + 2)),
    "Path": ($lg($$$APPCACHE, urlIndex + 3)),
    "AppUrl": ($lg($$$APPCACHE, urlIndex + 4))
  }
}

ClassMethod ClearCookies() As %Status
{
  set i%CookiesJar = ""
  return $$$OK
}

}

