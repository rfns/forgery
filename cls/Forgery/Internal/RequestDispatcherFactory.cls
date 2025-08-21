/// Factory helper for aggregating service dependencies.
Class Forgery.Internal.RequestDispatcherFactory Extends %RegisteredObject
{

/// Creates a new request dispatcher by consuming an agent configuration.
ClassMethod CreateUsingConfiguration(configuration As Forgery.Configuration) As Forgery.Internal.RequestDispatcher
{
  set resolver = ##class(Forgery.Internal.RESTClassResolver).%New(configuration.GetWebApplication())
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New(configuration.GetDeviceCharset(), configuration.GetDeviceLineTerminator())
  set jar = ##class(Forgery.Internal.CookieJar).%New()
  set cspContextFactory = ##class(Forgery.CSP.ContextFactory).%New()
  set merger = ##class(Forgery.Internal.ConfigurationMerger).%New()
  
  return ##class(Forgery.Internal.RequestDispatcher).%New(
    configuration,
    resolver,
    interceptor,
    jar,
    cspContextFactory,
    merger
  )
}

}
