Class Forgery.Agent.Core Extends %RegisteredObject
{

Property BaseURL As %String [ Private ];

Property DefaultHeaders As %DynamicObject [ Private ];

Property Cache As %String [ Private ];

Property Namespace As %String [ Private ];

Property Jar As Forgery.Agent.CookieJar [ Private ];

Property Response As %CSP.Response [ Private ];

Property Reply As %Stream.Object [ Private ];

Method %OnNew(defaultSettings As %DynamicObject = {{}}, defaultHeaders As %DynamicObject = {{}}) As %Status
{

  if $data(defaultSettings) {
    if $isobject(defaultSettings) && 'defaultSettings.%IsA("%DynamicObject") {
      set defaultSettings = {}
    } elseif '$isobject(defaultSettings) {
      set defaultSettings = { "baseURL": (defaultSettings) }
    }
  }

  if $isobject(defaultHeaders) && defaultHeaders.%IsA("%DynamicObject") && 'defaultSettings.%IsDefined("defaultHeaders") {
    set defaultSettings.defaultHeaders = defaultHeaders
  }


  set ..Namespace = $namespace
  set ..BaseURL = defaultSettings.baseURL
  set ..DefaultHeaders = defaultSettings.defaultHeaders

  set ..Cache = "^|"""_..Namespace_"""|Forgery.Agent"
  set ..Jar = ##class(Forgery.Agent.CookieJar).%New()
  return $$$OK
}

Method %OnClose() As %Status
{
  kill @i%Cache
  return $$$OK
}

Method NormalizeSettings(settings As %String) As %DynamicObject [ Private ]
{

  set finalSettings = {
    "url": ($zconvert(..BaseURL_settings.url, "I", "URL")),
    "method": (settings.method),
    "cookies": (settings.cookies),
    "headers": (settings.headers)
  }

  if '$isobject(finalSettings.headers) || 'finalSettings.headers.%IsA("%DynamicObject") {
    set finalSettings.headers = {}
  }

  if '$isobject(finalSettings.cookies) || 'finalSettings.cookies.%IsA("%DynamicObject") {
    set finalSettings.cookies = {}
  }

  if $lf($lb("POST", "PATCH", "PUT"), settings.method) && settings.%IsDefined("data") {
    set finalSettings.data = settings.data
  }

  do ..MergeWithDefaultHeaders(finalSettings.headers)
  return finalSettings
}

Method MergeWithDefaultHeaders(requestActionHeaders As %DynamicObject = {{}}) [ Private ]
{
  if '$isobject(..DefaultHeaders) return

  set iterator = ..DefaultHeaders.%GetIterator()

  while iterator.%GetNext(.key, .value) {
    if requestActionHeaders.%IsDefined(key) continue

    set type = ..DefaultHeaders.%GetTypeOf(key)
    do requestActionHeaders.%Set(key, value, type)
  }
}

Method Request(settings As %DynamicObject, response As %Stream.Object = "", outputToDevice As %Boolean = 0) As %Status
{
  set sc = $$$OK

  set normalizedSettings = ..NormalizeSettings(settings)
  $$$QuitOnError(..Forge(normalizedSettings, .response))

  if outputToDevice = 1 do response.OutputToDevice()
  return $$$OK
}

Method Forge(settings As %DynamicObject, response As %Stream.Object = "", outputToDevice As %Boolean = 0) As %Status [ Private ]
{
  kill %request, %session, %response
  new %request, %session, %response

  set str = ""
  $$$QuitOnError(..GetApplicationInfoFromUrl(settings.url, .appInfo))

  set %request = ##class(Forgery.Request).CreateFromSettings(settings, appInfo)
  set %session = ##class(%CSP.Session).%New(-1, 0)
  set %response = ##class(%CSP.Response).%New()

  do %request.PickFromJar(..Jar)

  try {
    $$$ThrowOnError(##class(Forgery.OutputCapturer).Capture(appInfo.DispatchClass, %request.URL, settings.method, .reply))
    do ..Jar.PutCookiesFromResponse(%response)
  } catch ex {
    set sc = ex.AsStatus()
  }

  set ..Reply = response
  set ..Response = %response
  kill %request, %session, %response

  // Makes sure that any attempts to change the namespace internally ends up in the original one.
  set $namespace = ..Namespace
  return sc
}

Method GetApplicationInfoFromUrl(url As %String, Output info As Forgery.Agent.ApplicationInfo) As %DynamicObject [ Private ]
{

  #define APPCACHE @i%Cache

  set info = ##class(Forgery.Agent.ApplicationInfo).%New()

  // Cache matches to prevent roundtrips to the %SYS namespace.
  if $data($$$APPCACHE) {
    set index = $lf($$$APPCACHE, url)
    if index > 0 return $$ListToObject(index)
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
    set info = $$ListToObject(index)
  }

  set $namespace = ..Namespace

  if name = "" {
    set info = ""
    return $$$ERROR($$$GeneralError, "No application found for url: "_url)
  }

  return $$$OK

ListToObject(urlIndex)
  set info.Name = $lg($$$APPCACHE, urlIndex + 1)
  set info.DispatchClass = $lg($$$APPCACHE, urlIndex + 2)
  set info.Path = $lg($$$APPCACHE, urlIndex + 3)
  set info.AppUrl = $lg($$$APPCACHE, urlIndex + 4)

  return info
}

Method EmptyCookieJar() As %Status
{
  do ..Jar.Empty()
  return $$$OK
}

Method GetLastResponse() As %CSP.Response
{
  return ..Response
}

Method GetLastReply() As %Stream.Object
{
  return ..Reply
}

}

