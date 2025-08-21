/// Utility class for REST dispatch class discovery.
Class Forgery.Internal.RESTClassResolver Extends %RegisteredObject
{

/// The provided web application name.
Property WebApplication As %String [ Private ];

Property WebApplicationInfoCache As %DynamicObject [ Private ];

Method %OnNew(webApplication As %String, cache As %DynamicObject = {{}}) As %Status
{
  set ..WebApplication = webApplication
  set ..WebApplicationInfoCache = cache

  return $$$OK
}

Method Resolve(url As %String, Output info As %DynamicObject = "") As %Status
{
  if ..WebApplicationInfoCache.%Size() '= 0 {
    return ..WebApplicationInfoCache
  }

  new $namespace
  set $namespace = "%SYS"

  set baseUrl = ..WebApplication

  if $extract(baseUrl, *) = "/" {
    set baseUrl = $extract(baseUrl, 1, *-1)
  }

  set prefixedResource = baseUrl_$select($extract(url) '= "/" : "/"_url, 1: url)

  // Reverts the ordering to match longer names first.
  set rows = ##class(%SQL.Statement).%ExecDirect(, "SELECT TOP 1 Name, DispatchClass, Path FROM SECURITY.APPLICATIONS WHERE ? %STARTSWITH Name AND DispatchClass IS NOT NULL ORDER BY LEN(Name) DESC", prefixedResource)
  if rows.%Next() {
    set name = rows.%Get("Name")
    set ..WebApplicationInfoCache.Name = rows.%Get("Name")
    set ..WebApplicationInfoCache.DispatchClass = rows.%Get("DispatchClass")
    set ..WebApplicationInfoCache.Path = rows.%Get("Path")
    set ..WebApplicationInfoCache.AppUrl = name_$select($extract(name, *) '= "/" : "/", 1: "")
  }

  if ..WebApplicationInfoCache.%Size() = 0 {
    return $$$ERROR($$$GeneralError, $$$FormatText("Web application resolver error: No application matching the url '%1' has been found.", prefixedResource))
  }

  set info = ..WebApplicationInfoCache
  return $$$OK
}

}
