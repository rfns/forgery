Class Forgery.Internal.RequestDispatcher Extends %RegisteredObject
{

Property Configuration As Forgery.Configuration [ Private ];

Property InitialNamespace As %String [ InitialExpression = {$namespace}, Private ];

Property DispatchHandler As Forgery.IDispatchHandler [ Private ];

Property ContextFactory As Forgery.CSP.ContextFactory [ Private ];

Property LastContext As Forgery.CSP.Context [ Private ];

Property WebApplicationResolver As Forgery.Internal.WebApplicationResolver [ Private ];

Property DeviceInterceptor As Forgery.IO.DeviceInterceptor [ Private ];

Property ConfigurationMerger As Forgery.Internal.ConfigurationMerger [ Private ];

Property CookieJar As Forgery.Internal.CookieJar [ Private ];

Method %OnNew(configuration As Forgery.Configuration, resolver As Forgery.Internal.WebApplicationResolver, handler As Forgery.IDispatchHandler, interceptor As Forgery.IO.DeviceInterceptor, jar As Forgery.Internal.CookieJar, cspContextFactory As Forgery.CSP.ContextFactory, configurationMerger As Forgery.Internal.ConfigurationMerger) As %Status
{
  set ..WebApplicationResolver = resolver
  set ..DispatchHandler = handler
  set ..DeviceInterceptor = interceptor
  set ..CookieJar = jar
  set ..ContextFactory = cspContextFactory
  set ..ConfigurationMerger = configurationMerger

  return $$$OK
}

Method Dispatch(httpMethod As %String, resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$QuitOnError(..WebApplicationResolver.Resolve(resource, .appInfo))

  set safeOverrides = $select($isobject(overrides) : overrides, 1: {})
  set mergedOverrides = ..ConfigurationMerger.Merge(
    safeOverrides,
    { "headers": (..Configuration.GetRequestDefaultHeaders()) }, 
    { "cookies": (..Configuration.GetRequestDefaultCookies()) }
  )
  set ..LastContext = ..ContextFactory.Create(appInfo.AppUrl, resource, httpMethod, data, mergedOverrides)

  set status = $$$OK

  try {
    do ..LastContext.Request.PickFromJar(..CookieJar)
    do ..DeviceInterceptor.StartInterception()
    $$$ThrowOnError(..DispatchHandler.OnDispatch(resource, httpMethod, appInfo.DispatchClass, ..LastContext))
    do ..CookieJar.PutCookiesFromResponse(..LastContext.Response)
  } catch ex {
    set status = ex.AsStatus()
  }

  $$$QuitOnError(..DispatchHandler.OnDispose())
  
  do ..DeviceInterceptor.EndInterception()

  // Ensure we are back to the original namespace after the dispatch.
  set $namespace = ..InitialNamespace
  return status
}

Method GetLastContext() As Forgery.CSP.Context
{
  return ..LastContext
}

Method GetLastReply() As %Stream.FileCharacter
{
  return ..DeviceInterceptor.GetInterceptedContent()
}

}
