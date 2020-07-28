Class Forgery.Request Extends %RegisteredObject
{

Property URL As %String;

Property Method As %String;

Property Application As %String;

Property Content As %CSP.Stream;

Property Cookies As %String [ MultiDimensional ];

Property MimeData As %String [ MultiDimensional ];

Property ContentType As %String;

Property ContentLength As %String;

Property Authorization As %String;

Property Protocol As %String [ InitialExpression = "HTTP/1.1" ];

Property CgiEnvs As %String [ MultiDimensional ];

Property Data As %String [ MultiDimensional ];

Method %OnNew(url As %String, info As Forgery.Agent.ApplicationInfo, method As %String = "GET") As %Status [ Private ]
{
  set ..URL = url
  set ..Method = method
  set ..Content = ##class(%CSP.CharacterStream).%New()
  set ..Application = info.AppUrl
  do ..LoadDefaultCgiEnvs()
  return $$$OK
}

ClassMethod NormalizeURL(url As %String) As %String [ Private ]
{
  set url = $select($extract(url, 1) '= "/" : "/"_url, 1: url)
  set url = $piece(url, "?")
  return url
}

ClassMethod CreateFromSettings(settings As %DynamicObject, appInfo As Forgery.Agent.ApplicationInfo) As Forgery.Request [ Internal ]
{
  set url = ..NormalizeURL(settings.url)
  set request = ..%New(url, appInfo, settings.method)  

  do request.AppendToRequest("headers", settings.headers)
  do request.AppendToRequest("cookies", settings.cookies)

  if settings.%IsDefined("headers") {
    if settings.headers.%IsDefined("Authorization") {
      set request.Authorization = settings.headers.Authorization
    }
  }

  if settings.url [ "?" {
    set queryParts = $replace(settings.url, "?", "&")
    for i=2:1:$length(queryParts, "&") {
      set qp = $piece(queryParts, "&", i)
      set qn = $piece(qp, "=", 1)
      set qv = $piece(qp, "=", 2)
      do request.Insert(qn, qv)
    }
  }

  if settings.%IsDefined("data") && $isobject(settings.data) {
    if settings.headers.%Get("Content-Type") [ "multipart/form-data" {
      do request.AppendToRequest("mimedata", settings.data)
    } elseif settings.data.%IsA("%Stream.Object") {
      if settings.data.IsCharacter() set content = ##class(%CSP.CharacterStream).%New()
      else  set content = ##class(%CSP.BinaryStream).%New()
      do content.CopyFrom(settings.data)
    } elseif settings.data.%Extends("%DynamicAbstractObject") {
      set content = ##class(%CSP.CharacterStream).%New()
      do settings.data.%ToJSON(.content)
      set request.Content = content
      if settings.headers.%Get("Content-Type") '[ "application/json" {
        do request.SetHeader("Content-Type", "application/json")
      }
    } else {
      do request.AppendToRequest("queryparams", settings.data)
    }
  }

  return request
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

Method AuthorizationSet(value As %String) As %Status [ Final ]
{
  set i%CgiEnvs("HTTP_AUTHORIZATION") = value
  set i%Authorization = value
  return $$$OK
}

Method ContentTypeSet(value As %String) As %Status [ Private ]
{
  set i%CgiEnvs("HTTP_CONTENT_TYPE") = value
  set i%ContentType = value
  return $$$OK
}

Method ContentLengthSet(value As %String) As %Status [ Private ]
{
  set i%CgiEvs("CONTENT_LENGTH") = value
  set i%ContentLength = value
  return $$$OK
}

Method LoadDefaultCgiEnvs() [ Private ]
{
  do ##class(%Net.URLParser).Parse(..URL, .components)
  do ParseQueryString(components("query"), .data)

  merge i%Data = data

  set i%CgiEnvs("REQUEST_METHOD") = $$$ucase(..Method)
  set i%CgiEnvs("REQUEST_SCHEME") = "http"
  set i%CgiEnvs("REQUEST_URI") = components("path")
  set i%CgiEnvs("SERVER_NAME") = "localhost"
  set i%CgiEnvs("SERVER_PORT") = 57772
  set i%CgiEnvs("SERVER_PROTOCOL") = "HTTP/1.1"
  set i%CgiEnvs("REMOTE_ADDR") = "localhost"

ParseQueryString(qs, data)
  if qs = "" quit

  set qp = $lfs(qs, "&")

  for i=1:1:$ll(qp) {
    set key = $piece($lg(qp, i), "=", 1)
    set value = $piece($lg(qp, i), "=", 2)
    if key '= "" && (value '= "") set data(key, 1) = value
  }
  quit
}

// Most of the methods below are a copy from %CSP.Request, since we need to keep

// these methods working as they can be called by the application.

/// Retrieves the named cookie
Method GetCookie(name As %String, default As %String = "", index As %Integer = 1) As %String [ CodeMode = expression, Final ]
{
$get(i%Cookies(name,index),default)
}

/// Inserts a cookie name/value pair.
Method InsertCookie(name As %String, value As %String) [ Final, Internal ]
{
  If name="" Quit $$$OK
  do ..SetCgiEnv("HTTP_"_$$$ucase($replace(name, "-", "_")), value)
  Set i%Cookies(name,$order(i%Cookies(name,""),-1)+1)=value
  Quit
}

/// Returns true if the named cookie exists in the cookie collection, false otherwise.
Method IsDefinedCookie(name As %String, index As %Integer = 1) As %Boolean [ CodeMode = expression, Final ]
{
$data(i%Cookies(name,index))
}

/// Retrieves the named multipart MIME stream.
Method GetMimeData(name As %String, default As %Stream.Object = "", index As %Integer = 1) As %Stream.Object [ CodeMode = expression, Final ]
{
$get(i%MimeData(name,index),default)
}

/// Inserts a multipart MIME stream by name into the collection.
Method InsertMimeData(name As %String, value As %Stream.Object) [ Final, Internal ]
{
  If value="" Quit
  Set i%MimeData(name,$order(i%MimeData(name,""),-1)+1)=value
  Quit
}

/// Returns true if the named multipart MIME stream exists in the collection, false otherwise.
Method IsDefinedMimeData(name As %String, index As %Integer = 1) As %Boolean [ CodeMode = expression, Final ]
{
$data(i%MimeData(name,index))
}

/// Returns the count of multipart MIME streams with this name.
Method CountMimeData(name As %String) As %Integer [ Final ]
{
  #Dim count,i

  Quit:'$data(i%MimeData(name)) 0
  Set count=0 Set i="" For  Set i=$order(i%MimeData(name,i)) Quit:i=""  Set count=count+1
  Quit count
}

/// Retrieves name of the next multipart MIME stream stored in the request object.
Method NextMimeData(name As %String) As %String [ CodeMode = expression, Final ]
{
$order(i%MimeData(name))
}

/// Return the index number of the next multipart MIME stream stored in the request object.
Method NextMimeDataIndex(name As %String, index As %Integer = "") As %String [ CodeMode = expression, Final ]
{
$order(i%MimeData(name,index))
}

/// Removes this multipart MIME stream from the collection. Returns the number
/// of nodes it has removed. If <var>name</var> is not defined then it will
/// remove the entire set of MimeData, if <var>name</var> is defined but <var>index</var>
/// is not then it will remove all items stored under <var>name</var>.
Method DeleteMimeData(name As %String = "", index As %Integer = "") As %Integer [ Final, Internal ]
{
  #Dim defined
  If name="" {
    Set defined=0
    Set name=$order(i%MimeData(""))
    While name'="" {
      Set index=$order(i%MimeData(name,""))
      While index'="" { Set defined=defined+1,index=$order(i%MimeData(name,index)) }
      Set name=$Order(i%MimeData(name))
    }
    Kill i%MimeData
    Quit defined
  } ElseIf index="" {
    Set defined=0
    Set index=$order(i%MimeData(name,""))
    While index'="" { Set defined=defined+1,index=$order(i%MimeData(name,index)) }
    Kill i%MimeData(name)
    Quit defined
  } ElseIf $Data(i%MimeData(name,index)) {
    Kill i%MimeData(name,index)
    Quit 1
  }
  Quit 0
}

Method SetCgiEnv(key As %String, value As %String) As %Status
{
  if '$data(i%CgiEnvs(key)) set i%CgiEnvs(key) = value
  return $$$OK
}

/// Inserts a CGI environment variable by name into the collection.
Method InsertCgiEnv(name As %String, value As %String) [ Final, Internal ]
{
  do ..SetCgiEnv(name, value)
}

/// Retrieves the named CGI environment variable.
Method GetCgiEnv(name As %String, default As %String = "") As %String [ CodeMode = expression, Final ]
{
$get(i%CgiEnvs(name),default)
}

/// Returns true if the named CGI environment variable exists in the collection, false otherwise.
Method IsDefinedCgiEnv(name As %String) As %Boolean [ CodeMode = expression, Final ]
{
$data(i%CgiEnvs(name))
}

/// Retrieves the next CGI environment variable name in the sequence
Method NextCgiEnv(name As %String) As %String [ CodeMode = expression, Final ]
{
$order(i%CgiEnvs(name))
}

/// Removes this CGI environment variable from the collection, returns true if the item
/// was defined and false if it was never defined.
Method DeleteCgiEnv(name As %String) As %Boolean [ Final, Internal ]
{
  If $data(i%CgiEnvs(name)) Kill i%CgiEnvs(name) Quit 1
  Quit 0
}

Method SetHeader(key As %String, value As %String) As %Status
{
  if $$$lcase(key) = "content-type" set ..ContentType = value
  if $$$lcase(key) = "content-length" set ..ContentLength = value

  do ..SetCgiEnv("HTTP_"_$$$ucase($replace(key, "-", "_")), value)
  return $$$OK
}

Method Get(name As %String, default As %String = "", index As %Integer = 1) As %String [ CodeMode = expression, Final ]
{
$get(i%Data(name,index),default)
}

Method Set(name As %String, value As %String, index As %Integer = 1) [ Final, Internal ]
{
  If $length(name)>254 Quit
  Set i%Data(name,index)=value
  QUIT
}

Method Insert(name As %String, value As %String) [ Final ]
{
  If $length(name)>254 Quit
  Set i%Data(name,$order(i%Data(name,""),-1)+1)=value
  Quit
}

Method IsDefined(name As %String, index As %Integer = 1) As %Boolean [ CodeMode = expression, Final ]
{
$data(i%Data(name,index))
}

Method Count(name As %String) As %Integer [ Final ]
{
  #Dim count,i
  Quit:'$data(i%Data(name)) 0
  Set count=0 Set i="" For  Set i=$order(i%Data(name,i)) Quit:i=""  Set count=count+1
  Quit count
}

Method Find(name As %String, value As %String) As %Integer [ Final ]
{
  #Dim i
  Set i=$order(i%Data(name,""))
  While (i'="")&&(i%Data(name,i)'=value) { Set i=$order(i%Data(name,i)) }
  Quit i
}

Method NextIndex(name As %String, ByRef index As %Integer = "") As %String [ Final ]
{
  Set index=$order(i%Data(name,index))
  Quit:index="" ""
  Quit i%Data(name,index)
}

}

