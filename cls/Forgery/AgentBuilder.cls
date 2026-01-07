Class Forgery.AgentBuilder Extends %RegisteredObject
{

Property Configuration As Forgery.Configuration [ Private ];

Method %OnNew() As %Status
{
  set ..Configuration = ##class(Forgery.Configuration).%New()
  return $$$OK
}

Method SetWebApplication(webApplication As %String) As Forgery.AgentBuilder
{
  do ..Configuration.SetWebApplication(webApplication)
  return $this
}

Method UseDispatchHandler(handler As Forgery.IDispatchHandler) As Forgery.AgentBuilder
{
  do ..Configuration.SetDispatchHandler(handler)
  return $this
}

Method UseDefaultDispatchHandler(handler As Forgery.IDispatchHandler) As Forgery.AgentBuilder
{
  do ..Configuration.SetDispatchHandler(##class(Forgery.CSP.DefaultDispatchHandler).%New())
  return $this
}

Method WithHeaders(headers As %DynamicObject = {{}}) As Forgery.AgentBuilder
{
  do ..Configuration.SetRequestDefaultHeaders(headers)
  return $this
}

Method WithCookies(cookies As %DynamicArray) As Forgery.AgentBuilder
{
  do ..Configuration.SetRequestDefaultCookies(cookies)
  return $this
}

Method Build(Output agent As Forgery.Agent = "") As %Status
{
  $$$QuitOnError(..Configuration.Validate())
  
  set requestDispatcherFactory = ##class(Forgery.Internal.RequestDispatcherFactory).%New()
  set agent = ##class(Forgery.Agent).%New(..Configuration, requestDispatcherFactory)
  return $$$OK
}

}
