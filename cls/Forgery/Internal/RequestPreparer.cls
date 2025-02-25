Class Forgery.Internal.RequestPreparer Extends %RegisteredObject
{

Method Prepare(request As Forgery.CSP.Request, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject)
{
 
  do ..AppendToRequest(request, "headers", overrides.headers)
  do ..AppendToRequest(request, "cookies", overrides.cookies)

  do ..ConsumeQueryParameters(request)
  do ..ConsumeAuthorizationHeader(request, overrides)

  $$$QuitOnError(..ConsumeData(request, data, overrides))

  return $$$OK
}

Method ConsumeAuthorizationHeader(request As Forgery.CSP.Request, overrides As %DynamicObject) [ Private ]
{
  if overrides.%IsDefined("headers") {
    if overrides.headers.%IsDefined("Authorization") {
      set request.Authorization = overrides.headers.Authorization
    }
  }
}

Method ConsumeQueryParameters(request As Forgery.CSP.Request) [ Private ]
{
  if request.URL '[ "?" return
  
  set queryParts = $replace(request.URL, "?", "&")
  for i=2:1:$length(queryParts, "&") {
    set qp = $piece(queryParts, "&", i)
    set qn = $piece(qp, "=", 1)
    set qv = $piece(qp, "=", 2)
    do request.Insert(qn, qv)
  }
}

Method ConsumeData(request As Forgery.CSP.Request, data As %Any, overrides As %DynamicObject) As %Status [ Private ]
{
  #define MethodAcceptsPayload $lf($lb("PUT", "POST", "PATCH"), request.Method)

  if '$isobject(data) {
    return $$$OK
  }

  if overrides.headers.%Get("Content-Type") [ "multipart/form-data" {
    do ..AppendToRequest(request, "mimedata", data)
  } elseif data.%IsA("%Stream.Object") {
    set fileExtension = $piece(data.Filename, ".", *)
    do ##class(%CSP.StreamServer).FileClassify(fileExtension, .type)
    
    do request.SetHeader("Content-Type", type)
    do request.SetHeader("Content-Length", ..CalculateContentLength(data, type))

    if data.IsCharacter() set content = ##class(%CSP.CharacterStream).%New()
    else  set content = ##class(%CSP.BinaryStream).%New()
    do content.CopyFrom(data)
    set request.Content = content
  } elseif data.%Extends("%DynamicAbstractObject") && $$$MethodAcceptsPayload {
    if overrides.headers.%Get("Content-Type") '[ "application/json" {
      do request.SetHeader("Content-Type", "application/json")
    } 
    set content = ##class(%CSP.CharacterStream).%New()
    do data.%ToJSON(.content)
    set request.Content = content
  } else {
    do ..AppendToRequest(request, "queryparams", data)
  }

  return $$$OK
}

Method CalculateContentLength(stream As %Stream.FileCharacter, type As %String) As %String [ Private ]
{
   
  if type = "application/octet-stream" {
    return "chunked"
  }
  
  if stream.IsCharacter() {
    set table = stream.TranslateTable
    
    return $select(
      table = "RAW" : stream.Size,
      table = "UnicodeBig" : stream.Size * 2,
      table = "UnicodeLittle" : stream.Size * 2,
      $extract(table, 1, 5) = "Latin" : stream.Size,
      $extract(table, 1, 2) = "CP" : stream.Size,
      1: ""        
    )
  }

  return ""
}

Method AppendToRequest(request As Forgery.CSP.Request, settingName As %String, settingData As %Any, parentKey = "") [ Private ]
{
  if '$isobject(settingData) quit
  set iterator = settingData.%GetIterator()

  while iterator.%GetNext(.key, .val) {
    set appendToKeyName = key
    if $isobject(val) {
      if val.%IsA("%DynamicObject") {
        do ..AppendToRequest(request, settingName, val)
      } elseif val.%IsA("%DynamicArray") {
        do ..AppendToRequest(request, settingName, val, key)
      }
    } elseif parentKey '= "" {
      set appendToKeyName = parentKey
    }
    if settingName = "headers" { do request.SetHeader(appendToKeyName, val) }
    elseif settingName = "cookies" { do request.InsertCookie(appendToKeyName, val) }
    elseif settingName = "mimedata" { do request.InsertMimeData(appendToKeyName, val) }
    elseif settingName = "queryparams" { do request.Insert(appendToKeyName, val) }
  }
}

}
