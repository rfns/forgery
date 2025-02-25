Class Forgery.Internal.RequestDispatcherFactory Extends %RegisteredObject
{

ClassMethod CreateUsingConfiguration(configuration As Forgery.Configuration) As Forgery.Internal.RequestDispatcher
{
  set resolver = ##class(Forgery.Internal.WebApplicationResolver).%New(configuration.GetBaseURL())
  set interceptor = ##class(Forgery.IO.DeviceInterceptor).%New(configuration.GetDeviceCharset(), configuration.GetDeviceLineTerminator())
  set handler = configuration.GetDispatchHandler()
  set jar = ##class(Forgery.Internal.CookieJar).%New()
  set cspContextFactory = ##class(Forgery.CSP.ContextFactory).%New()
  set merger = ##class(Forgery.Internal.ConfigurationMerger).%New()
  
  return ##class(Forgery.Internal.RequestDispatcher).%New(
    configuration,
    resolver,
    handler,
    interceptor,
    jar,
    cspContextFactory,
    merger
  )
}

}
