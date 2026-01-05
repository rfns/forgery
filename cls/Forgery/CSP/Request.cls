Class Forgery.CSP.Request Extends (%RegisteredObject, Forgery.CSP.AbstractRequestLike)
{

Property Resource As %String [ ReadOnly ];

Method %OnNew(webApplication As %String, unformattedResource As %String, httpMethod As %String) As %Status [ Private ]
{
  set ..Method = httpMethod
  set ..Application = webApplication
  do ..ConsumeQueryParameters(unformattedResource)
  do ..NormalizeResource(unformattedResource)
  do ..LoadDefaultCgiEnvs()
  return $$$OK
}

Method ConsumeQueryParameters(unformattedResource As %String) [ Private ]
{
  if unformattedResource '[ "?" return
  
  set queryParts = $replace(unformattedResource, "?", "&")
  for i=2:1:$length(queryParts, "&") {
    set qp = $piece(queryParts, "&", i)
    set qn = $piece(qp, "=", 1)
    set qv = $piece(qp, "=", 2)
    do ..Insert(qn, qv)
  }
}

Method NormalizeResource(unformattedResource As %String) [ Private ]
{
  set ..URL = ..Application

  set pathOnlyResource = $piece(unformattedResource, "?", 1)

  if $extract(pathOnlyResource, 1) = "/" {
    set pathOnlyResource = $extract(pathOnlyResource, 2, *)
  }

  set ..URL = ..Application_pathOnlyResource
  set i%Resource = "/"_pathOnlyResource
}

Method PickFromJar(jar As Forgery.Internal.CookieJar)
{
  do jar.PutCookiesInRequest($this)
}

Method LoadDefaultCgiEnvs() [ Private ]
{
  set i%CgiEnvs("REQUEST_METHOD") = $$$ucase(..Method)
  set i%CgiEnvs("REQUEST_SCHEME") = "http"
  set i%CgiEnvs("REQUEST_URI") = ..URL
  set i%CgiEnvs("SERVER_NAME") = "localhost"
  set i%CgiEnvs("SERVER_PORT") = 80
  set i%CgiEnvs("SERVER_PROTOCOL") = "HTTP/1.1"
  set i%CgiEnvs("REMOTE_ADDR") = "localhost"
}

}
