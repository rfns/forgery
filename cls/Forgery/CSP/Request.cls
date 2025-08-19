Class Forgery.CSP.Request Extends (%RegisteredObject, Forgery.CSP.AbstractRequestLike)
{

Method %OnNew(webApplication As %String, resource As %String, httpMethod As %String) As %Status [ Private ]
{
  set ..URL = resource
  set ..Method = httpMethod
  set ..Application = webApplication
  do ..LoadDefaultCgiEnvs()
  return $$$OK
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
