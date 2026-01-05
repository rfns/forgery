/// Utility class for transporting cookie data from/to response and request objects respectively.
/// 
/// A stateful agent allows for two-phase operations to flow without manual intrusion from the caller.
/// Like sending a request for auth and a second request with the cookie set for consuming data..
Class Forgery.Internal.CookieJar Extends %RegisteredObject
{

/// The list that holds the cookies with the current operation context.
Property Cookies As %String [ MultiDimensional ];

/// Puts cookies from a response object into a request.
Method PutCookiesFromResponse(response As %CSP.Response) As %Status
{
  set index = ""
  for {
    set index = $order(response.Cookies(index))
    quit:index=""
    
    set name = response.Cookies(index, "n")
    set value = response.Cookies(index, "v")
    set path = response.Cookies(index, "p")
    
    // No path means it can be used everywhere.
    if path = "" set path = "*"
    
    set i%Cookies(path, name, index) = value   
  }
}

Method PutCookiesInRequest(request As Forgery.CSP.Request) As %Status
{
  set name = ""
  set index = ""
  
  do PutCookies(request.Application)
  do PutCookies("*")  

PutCookies(path)
  if path = "" quit
  
  for {
    set name = $order(i%Cookies(path, name))
    quit:name=""
    
    for {
      set index = $order(i%Cookies(path, name, index), 1, value)
      quit:index=""
      
      do request.InsertCookie(name, value)
    }
  }
}

Method Empty()
{
  kill i%Cookies
}

}
