Class Forgery.Agent Extends Forgery.Agent.Core
{

Method Post(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0) As %Status
{
  set settings.method = "POST"
  return ..Request(settings, .response, outputToDevice)
}

Method Get(settings As %DynamicObject = "", response As %Stream.Object, outputToDevice As %Boolean = 0) As %Status
{
  if '$isobject(settings) {
    set url = settings
    set settings = { "url": (url) }
  }
  set settings.method = "GET"
  return ..Request(settings, .response, outputToDevice)
}

Method Put(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0)
{
  set settings.method = "PUT"
  return ..Request(settings, .response, outputToDevice)
}

Method Delete(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0)
{
  set settings.method = "DELETE"
  return ..Request(settings, .response, outputToDevice)
}

Method Head(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0)
{
  set settings.method = "HEAD"
  set settings.data = {}
  return ..Request(settings, .response, outputToDevice)
}

Method Patch(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0)
{
  set settings.method = "PATCH"
  return ..Request(settings, .response, outputToDevice)
}

Method Options(settings As %DynamicObject, response As %Stream.Object, outputToDevice As %Boolean = 0)
{
  set settings.method = "OPTIONS"
  return ..Request(settings, .response, outputToDevice)
}

}
