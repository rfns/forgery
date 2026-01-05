/// Core class that manages the communication between the agent and the REST web application.
/// 
/// It takes care of all the aspects required before and after reaching the dispatch class.
Class Forgery.Internal.RequestDispatcher Extends %RegisteredObject
{

/// The configuration object provided to the agent, which is actually consumed here.
Property Configuration As Forgery.Configuration [ Private ];

/// A property that indicates from which the request was originated. This is required because web applications can be run in different namespaces.
Property InitialNamespace As %String [ InitialExpression = {$namespace}, Private ];

/// A factory helper for creating CSP context objects.
Property ContextFactory As Forgery.CSP.ContextFactory [ Private ];

/// The last context stored for assertions. Can be read by agent callers.
Property LastContext As Forgery.CSP.Context [ Private ];

/// A helper for discovering the dispatch class.
Property RESTClassResolver As Forgery.Internal.RESTClassResolver [ Private ];

/// A helper for handling output redirection due to explicit content writes made by dispatch classes.
Property DeviceInterceptor As Forgery.IO.DeviceInterceptor [ Private ];

/// A helper for consolidating configuration received through the builder and by-request arguments.
Property ConfigurationMerger As Forgery.Internal.ConfigurationMerger [ Private ];

/// A helper used to transport cookies received from/to CSP objects request and response between multiple requests.
Property CookieJar As Forgery.Internal.CookieJar [ Private ];

Method %OnNew(configuration As Forgery.Configuration, resolver As Forgery.Internal.RESTClassResolver, interceptor As Forgery.IO.DeviceInterceptor, jar As Forgery.Internal.CookieJar, cspContextFactory As Forgery.CSP.ContextFactory, configurationMerger As Forgery.Internal.ConfigurationMerger) As %Status
{
  set ..Configuration = configuration
  set ..RESTClassResolver = resolver
  set ..DeviceInterceptor = interceptor
  set ..CookieJar = jar
  set ..ContextFactory = cspContextFactory
  set ..ConfigurationMerger = configurationMerger

  return $$$OK
}

/// Discovers the dispatch class and fires a request to it using the by-request config and data provided.
/// 
/// Returns an status object indicating if the request suceeded or not.
Method Dispatch(httpMethod As %String, resource As %String, data As %DynamicAbstractObject = {$$$NULLOREF}, overrides As %DynamicObject = {$$$NULLOREF}) As %Status
{
  #define SafeOverrides $select($isobject(overrides) : overrides, 1: {})
  
  $$$QuitOnError(..RESTClassResolver.Resolve(resource, .appInfo))

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
    $$$ThrowOnError(dispatchHandler.OnDispatch(..LastContext.Request.Resource, httpMethod, appInfo.DispatchClass, ..LastContext, ..DeviceInterceptor))
    do ..CookieJar.PutCookiesFromResponse(..LastContext.Response)
  } catch ex {
    set status = ex.AsStatus()
  }

  do ..DeviceInterceptor.EndInterception()
  $$$QuitOnError(dispatchHandler.OnDispose())

  // Ensure we are back to the original namespace after the dispatch.
  set $namespace = ..InitialNamespace
  return status
}

/// Exposes the last context generated for the last request made.
Method GetLastContext() As Forgery.CSP.Context
{
  return ..LastContext
}

/// Exposes the last reply received for the last request made.
Method GetLastReply() As %Stream.FileCharacter
{
  return ..DeviceInterceptor.GetInterceptedContent()
}

}
