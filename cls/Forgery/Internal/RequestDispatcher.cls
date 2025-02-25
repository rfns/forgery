Class Forgery.Internal.RequestDispatcher Extends %RegisteredObject
{

Property Configuration As Forgery.Configuration [ Private ];

Property InitialNamespace As %String [ InitialExpression = {$namespace}, Private ];

Property ContextFactory As Forgery.CSP.ContextFactory [ Private ];

Property LastContext As Forgery.CSP.Context [ Private ];

Property WebApplicationResolver As Forgery.Internal.WebApplicationResolver [ Private ];

Property DeviceInterceptor As Forgery.IO.DeviceInterceptor [ Private ];

Property ConfigurationMerger As Forgery.Internal.ConfigurationMerger [ Private ];

Property CookieJar As Forgery.Internal.CookieJar [ Private ];

Method %OnNew(configuration As Forgery.Configuration, resolver As Forgery.Internal.WebApplicationResolver, interceptor As Forgery.IO.DeviceInterceptor, jar As Forgery.Internal.CookieJar, cspContextFactory As Forgery.CSP.ContextFactory, configurationMerger As Forgery.Internal.ConfigurationMerger) As %Status
{
  set ..Configuration = configuration
  set ..WebApplicationResolver = resolver
  set ..DeviceInterceptor = interceptor
  set ..CookieJar = jar
  set ..ContextFactory = cspContextFactory
  set ..ConfigurationMerger = configurationMerger

  return $$$OK
}

Method Dispatch(httpMethod As %String, resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  #define SafeOverrides $select($isobject(overrides) : overrides, 1: {})
  
  $$$QuitOnError(..WebApplicationResolver.Resolve(resource, .appInfo))

  set mergedOverrides = ..ConfigurationMerger.Merge(
    $$$SafeOverrides,
    { "headers": (..Configuration.GetRequestDefaultHeaders()) }, 
    { "cookies": (..Configuration.GetRequestDefaultCookies()) }
  )
  set ..LastContext = ..ContextFactory.Create(appInfo.AppUrl, resource, httpMethod, data, mergedOverrides)

  set status = $$$OK
  set dispatchHandler = ..Configuration.GetDispatchHandler()

  try {
    do ..LastContext.Request.PickFromJar(..CookieJar)
    do ..DeviceInterceptor.StartInterception()
    $$$ThrowOnError(dispatchHandler.OnDispatch(resource, httpMethod, appInfo.DispatchClass, ..LastContext))
    do ..CookieJar.PutCookiesFromResponse(..LastContext.Response)
  } catch ex {
    set status = ex.AsStatus()
  }

  $$$QuitOnError(dispatchHandler.OnDispose())
  
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
