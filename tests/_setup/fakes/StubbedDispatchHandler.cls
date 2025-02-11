Class Test.Forgery.Setup.StubbedDispatchHandler Extends (Forgery.IDispatchHandler, %RegisteredObject)
{

Property Message As %String;

Method %OnNew(message As %String = "") As %Status
{
  set ..Message = message

  return $$$OK
}

Method Handle(resource As %String, httpMethod As %String, restDispatchClass As %String) As %Status
{
  if ..Message '= "" {
    write ..Message
    return $$$OK
  }

  set reply = ""
  
  if httpMethod = "GET" {
    write { "message": (%request.Get("message")) }.%ToJSON()
  } elseif (httpMethod = "POST") || (httpMethod = "PATCH") || (httpMethod = "PUT") {
    do %request.Content.Rewind()
    do %request.Content.OutputToDevice()
  } elseif httpMethod = "HEAD" {
    write ""
  }

  return $$$OK
}

}
