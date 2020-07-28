Class Forgery.Agent.CookieJar Extends %RegisteredObject
{

Property Cookies As %String [ MultiDimensional ];

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

Method PutCookiesInRequest(request As Forgery.Request) As %Status
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

