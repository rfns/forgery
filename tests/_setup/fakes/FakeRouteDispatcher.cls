Class Test.Forgery.FakeRouteDispatcher Extends (Forgery.IDispatchHandler, %RegisteredObject)
{

Property Message As %String;

Method %OnNew(message As %String) As %Status
{
  set ..Message = message

  return $$$OK
}

Method Dispatch() As %Status
{
  write ..Message
}

}
