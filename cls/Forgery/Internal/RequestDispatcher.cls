Class Forgery.Internal.RequestDispatcher Extends %RegisteredObject
{

Property InitialNamespace As %String [ InitialExpression = {$namespace}, Private ];

Property DispatchHandler As Forgery.IDispatchHandler [ Private ];

Property ContextFactory As Forgery.CSP.ContextFactory [ Private ];

Property LastContext As Forgery.CSP.Context [ Private ];

Property WebApplicationResolver As Forgery.Internal.WebApplicationResolver [ Private ];

Property DeviceInterceptor As Forgery.IO.DeviceInterceptor [ Private ];

Property ConfigurationMerger As Forgery.Internal.ConfigurationMerger [ Private ];

Property CookieJar As Forgery.Internal.CookieJar [ Private ];

Property RequestDefaultHeaders As %DynamicObject [ InitialExpression = {{}}, Private ];

Property RequestDefaultCookies As %DynamicArray [ InitialExpression = {[]}, Private ];

Method %OnNew(resolver As Forgery.Internal.WebApplicationResolver, handler As Forgery.IDispatchHandler, interceptor As Forgery.IO.DeviceInterceptor, jar As Forgery.Internal.CookieJar, cspContextFactory As Forgery.CSP.ContextFactory, configurationMerger As Forgery.Internal.ConfigurationMerger, requestDefaultHeaders As %DynamicObject = {{}}, requestDefaultCookies As %DynamicArray = {[]}) As %Status
{
  set ..WebApplicationResolver = resolver
  set ..DispatchHandler = handler
  set ..DeviceInterceptor = interceptor
  set ..CookieJar = jar
  set ..ContextFactory = cspContextFactory
  set ..RequestDefaultHeaders = $select($isobject(requestDefaultHeaders) : requestDefaultHeaders, 1: {})
  set ..RequestDefaultCookies = $select($isobject(requestDefaultCookies) : requestDefaultCookies, 1: [])
  set ..ConfigurationMerger = configurationMerger

  return $$$OK
}

Method Dispatch(resource As %String, httpMethod As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  $$$QuitOnError(..WebApplicationResolver.Resolve(resource, .appInfo))

  set safeOverrides = $select($isobject(overrides) : overrides, 1: {})
  set mergedOverrides = ..ConfigurationMerger.Merge(
    ..RequestDefaultHeaders, 
    ..RequestDefaultCookies, 
    safeOverrides, 
    { "headers": {} },
    { "cookies": [] }
  )
  set ..LastContext = ..ContextFactory.Create(resource, httpMethod, data, appInfo, mergedOverrides)

  // Must publish these variables because of how %CSP.Page works.
  set %request = ..LastContext.Request
  set %response = ..LastContext.Response
  set %session = ..LastContext.Session

  set status = $$$OK

  try {
    do ..LastContext.Request.PickFromJar(..CookieJar)
    $$$ThrowOnError(..DeviceInterceptor.Intercept(..DispatchHandler, resource, httpMethod, appInfo.DispatchClass))
    do ..CookieJar.PutCookiesFromResponse(..LastContext.Response)
  } catch ex {
    set status = ex.AsStatus()
  }

  kill %request, %response, %session

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
