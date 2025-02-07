Class Forgery.Internal.WebApplicationResolver Extends %RegisteredObject
{

Property URLMapCache As %DynamicObject [ Private ];

Method %OnNew() As %Status
{
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

  set $namespace = "%SYS"

  set result = {}
  set name = ""
  set urlWithInitialSlash = $select($extract(url) '= "/" : "/"_url, 1: url)

  // Reverts the ordering to match longer names first.
  set rows = ##class(%SQL.Statement).%ExecDirect(, "SELECT TOP 1 Name, DispatchClass, Path FROM SECURITY.APPLICATIONS WHERE ? %STARTSWITH Name ORDER BY LEN(Name) DESC", urlWithInitialSlash)
  if rows.%Next() {
    set info.Name = rows.%Get("Name")
    set info.DispatchClass = rows.%Get("DispatchClass")
    set info.Path = rows.%Get("Path")
    set info.AppUrl = name_$select($extract(name, *) '= "/" : "/", 1: "")
  }

  if info.%Size() = 0 {
    return $$$ERROR($$$GeneralError, $$$FormatText("Web application resolver error: No application matching the url '%1' has been found.", url))
  }

  return $$$OK
}

}
