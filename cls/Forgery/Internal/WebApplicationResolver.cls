Class Forgery.Internal.WebApplicationResolver Extends %RegisteredObject
{

Property BaseURL As %String [ Private ];

Property URLMapCache As %DynamicObject [ Private ];

Method %OnNew(baseUrl As %String) As %Status
{
  set ..BaseURL = baseUrl
  set ..URLMapCache = {}
  return $$$OK
}

Method Resolve(url As %String, Output info As %DynamicObject = "") As %Status
{
  if ..URLMapCache.%IsDefined(url) {
    set info = ..URLMapCache.%Get(url)
    return $$$OK
  }

  do ..URLMapCache.%Set(url, {})
  set info = ..URLMapCache.%Get(url)

  new $namespace
  set $namespace = "%SYS"

  set baseUrl = ..BaseURL

  if $extract(baseUrl, *) = "/" {
    set baseUrl = $extract(baseUrl, 1, *-1)
  }

  set result = {}
  set name = ""
  set prefixedResource = baseUrl_$select($extract(url) '= "/" : "/"_url, 1: url)

  // Reverts the ordering to match longer names first.
  set rows = ##class(%SQL.Statement).%ExecDirect(, "SELECT TOP 1 Name, DispatchClass, Path FROM SECURITY.APPLICATIONS WHERE ? %STARTSWITH Name AND DispatchClass IS NOT NULL ORDER BY LEN(Name) DESC", prefixedResource)
  if rows.%Next() {
    set info.Name = rows.%Get("Name")
    set info.DispatchClass = rows.%Get("DispatchClass")
    set info.Path = rows.%Get("Path")
    set info.AppUrl = name_$select($extract(name, *) '= "/" : "/", 1: "")
  }

  if info.%Size() = 0 {
    return $$$ERROR($$$GeneralError, $$$FormatText("Web application resolver error: No application matching the url '%1' has been found.", prefixedResource))
  }

  return $$$OK
}

}
