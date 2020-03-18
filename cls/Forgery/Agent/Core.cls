Class Forgery.Agent.Core Extends %RegisteredObject
{

Property Cache As %String [ Private ];

Property Namespace As %String [ Private ];

Property CookiesJar As %String [ MultiDimensional ];

Property BaseURL As %String [ Private ];

Property DefaultHeaders As %DynamicObject [ Private ];

Property LastResponse As %CSP.Response [ Private ];

Method %OnNew(baseURL As %String = "", defaultHeaders As %DynamicObject = {{}}) As %Status
{
  set ..Namespace = $namespace
  set ..Cache = "^|"""_..Namespace_"""|Forgery.Agent"  
  set ..BaseURL = baseURL
  set ..DefaultHeaders = defaultHeaders
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
  
  if '$isobject(settings.headers) set settings.headers = {}
  if '$isobject(settings.cookies) set settings.cookies = {}
  
  set finalSettings = {
    "url": ($zconvert(..BaseURL _ settings.url, "I", "URL")), 
    "method": (settings.method),
    "headers": {},
    "cookies": (settings.cookies)
  }

  if settings.%IsDefined("data") {
    // Don't set {} as data if not defined. (Otherwise, would add content even on GET requests.)
    set finalSettings.data = settings.data
  }

  set iter = ..DefaultHeaders.%GetIterator()
  while iter.%GetNext(.key,.value) {
    set type = ..DefaultHeaders.%GetTypeOf(key)
    do finalSettings.headers.%Set(key,value,type)
  }

  set iter = settings.headers.%GetIterator()
  while iter.%GetNext(.key,.value) {
    set type = settings.headers.%GetTypeOf(key)
    if (type = "null") {
      do finalSettings.headers.%Remove(key)
    } else {
      do finalSettings.headers.%Set(key,value,type)
    }
  }
  
  $$$QuitOnError(..Forge(finalSettings, .response))
  
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
  set ..LastResponse = %response
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

Method ClearCookies() As %Status
{
  set i%CookiesJar = ""
  return $$$OK
}

}
