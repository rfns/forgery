Class Forgery.CSP.Request Extends (%RegisteredObject, Forgery.CSP.AbstractRequestLike)
{

Method %OnNew(url As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, info As Forgery.Agent.ApplicationInfo, overrides As %DynamicObject = {{}}) As %Status [ Private ]
{
  set ..URL = url
  set ..Method = httpMethod
  set ..Content = ##class(%CSP.CharacterStream).%New()
  set ..Application = info.AppUrl
  do ..LoadDefaultCgiEnvs()
  do ..Prepare(data, overrides)
  return $$$OK
}

Method Prepare(data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject) [ Private ]
{
  #define MethodAcceptsPayload $lf($lb("PUT", "POST", "PATCH"), ..Method)
  
  do ..AppendToRequest("headers", overrides.headers)
  do ..AppendToRequest("cookies", overrides.cookies)

  if overrides.%IsDefined("headers") {
    if overrides.headers.%IsDefined("Authorization") {
      set ..Authorization = overrides.headers.Authorization
    }
  }

  if ..URL [ "?" {
    set queryParts = $replace(..URL, "?", "&")
    for i=2:1:$length(queryParts, "&") {
      set qp = $piece(queryParts, "&", i)
      set qn = $piece(qp, "=", 1)
      set qv = $piece(qp, "=", 2)
      do ..Insert(qn, qv)
    }
  }

  if $isobject(data) {
    if overrides.headers.%Get("Content-Type") [ "multipart/form-data" {
      do ..AppendToRequest("mimedata", data)
    } elseif data.%IsA("%Stream.Object") {
      if data.IsCharacter() set content = ##class(%CSP.CharacterStream).%New()
      else  set content = ##class(%CSP.BinaryStream).%New()
      do content.CopyFrom(data)
    } elseif data.%Extends("%DynamicAbstractObject") && $$$MethodAcceptsPayload {
      if overrides.headers.%Get("Content-Type") '[ "application/json" {
        do ..SetHeader("Content-Type", "application/json; charset=utf-8")
      }      
      set content = ##class(%CSP.CharacterStream).%New()
      do data.%ToJSON(.content)
      set ..Content = content
    } else {
      do ..AppendToRequest("queryparams", data)
    }
  }
}

Method PickFromJar(jar As Forgery.Agent.CookieJar)
{
  do jar.PutCookiesInRequest($this)
}

Method AppendToRequest(settingName, settingData, parentKey = "") [ Private ]
{
  if '$isobject(settingData) quit
  set iterator = settingData.%GetIterator()

  while iterator.%GetNext(.key, .val) {
    set appendToKeyName = key
    if $isobject(val) {
      if val.%IsA("%DynamicObject") {
        do ..AppendToRequest(settingName, val)
      } elseif val.%IsA("%DynamicArray") {
        do ..AppendToRequest(settingName, val, key)
      }
    } elseif parentKey '= "" {
      set appendToKeyName = parentKey
    }
    if settingName = "headers" { do ..SetHeader(appendToKeyName, val) }
    elseif settingName = "cookies" { do ..InsertCookie(appendToKeyName, val) }
    elseif settingName = "mimedata" { do ..InsertMimeData(appendToKeyName, val) }
    elseif settingName = "queryparams" { do ..Insert(appendToKeyName, val) }
  }
}

Method LoadDefaultCgiEnvs() [ Private ]
{
  do ##class(%Net.URLParser).Decompose(..URL, .components)

  set i%CgiEnvs("REQUEST_METHOD") = $$$ucase(..Method)
  set i%CgiEnvs("REQUEST_SCHEME") = "http"
  set i%CgiEnvs("REQUEST_URI") = components("path")
  set i%CgiEnvs("SERVER_NAME") = "localhost"
  set i%CgiEnvs("SERVER_PORT") = 80
  set i%CgiEnvs("SERVER_PROTOCOL") = "HTTP/1.1"
  set i%CgiEnvs("REMOTE_ADDR") = "localhost"
}

}
