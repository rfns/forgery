Class Forgery.CSP.Context Extends %RegisteredObject
{

Property Request As Forgery.CSP.Request;

Property Response As %CSP.Response;

Property Session As %CSP.Session;

Method %OnNew(session As %CSP.Session, request As Forgery.CSP.Request, response As %CSP.Response) As %Status
{
  set ..Session = session
  set ..Request = request
  set ..Response = response

  return $$$OK
}

}
