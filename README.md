<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Forgery

*Forgery* is a server-side utility that allows executing simulated HTTP request by __forging__ calls to REST applications. This makes *Forgery* ideal for using together with test suites that need to call the API via HTTP but could face issues with license usage and its grace period.

> NOTE: This is not a tool used to bypass license limits, but instead it's simply an auxiliary tool for facilitating authoring request tests and debugging them without hitting the network layer. Because let's face it, debugging requests is actually a pain.

# How it works

You configure a new agent by specifying which web application should it point to and how the agent can reach the dispatch class. Then you use the agent's http verb-like methods to "fire" requests aiming the resources from that dispatch class, which I personally refer to them as _routers._

If you ever used [Axios](https://axios-http.com/docs/intro), that's how close I'd put this utility as, but we take out the real HTTP protocol of the equation and mimick it as much as we need to make our routers work. The result is an agent that can reach router methods without network, which results on improved testing speed and remove license bottlenecks.

## Agent

The Agent is responsible for mimicking a client that executes requests to the routers. It's represented by the class `Forgery.Agent` which is composed by six shortcut methods:

* Post
* Put
* Delete
* Patch
* Options
* Head

# Usage

Here's an example calling the Atelier API and retrieving the agent source code.

```objectscript
set builder = ##class(Forgery.AgentBuilder).%New()
// NOTE: The name must match the web application, this is not simply a prefix.
do builder.SetWebApplication("/api/atelier")
// Use the internal %CSP.REST dispatch handler.
do builder.UseDefaultDispatchHandler()
// Any fired requests will be populated with this header beforehand.
do builder.WithHeaders({ "Authorization": ("Basic "_$System.Encryption.Base64Encode("username:password")) })
// You can check for misconfigurations here.
$$$QuitOnError(builder.Build(.agent))
do agent.Get("/v2/USER/doc/Forgery.Agent.cls")
// Get the actual sever replied stream here.
set reply = agent.GetLastReply()
write reply.OutputToDevice()
```

## Available HTTP verb-like methods

* **Get**(_resource_ As %String, _queryParameters_ As %DynamicObject = "", _overrides_ As %DynamicObject = "")
* **Post**(_resource_ As %String, _data_ As %RegisteredObject = "", _overrides_ As %DynamicObject = "")
* **Put**(_resource_ As %String, _data_ As %RegisteredObject = "", _overrides_ As %DynamicObject = "")
* **Patch**(_resource_ As %String, _data_ As %RegisteredObject = "", _overrides_ As %DynamicObject = "")
* **Put**(_resource_ As %String, _data_ As %RegisteredObject = "", _overrides_ As %DynamicObject = "")
* **Delete**(_resource_ As %String, _overrides_ As %DynamicObject = "")
* **Head**(_resource_ As %String, _overrides_ As %DynamicObject = "")

Where:

* `resource` refers to the target resource path to fire the request to.
* `data` is anything related to either: a %DynamicAbstractObject, a %Stream.Object or a FormData.
* `overrides` is a dynamic object containg a `headers` and/or `cookies` that configure the request headers.

Meaning:

* A _FormData_ is an instance of `agent.NewFormata()`.
* The `cookies` is a dynamic array of dynamic objects where each object is composed by a single key-value non negotiable. e.g. `[{ "key": "value" }, { "key": "value2" }]`
* The `headers` is a dynamic object composed by properties the refer to actual request headers. e.g. `{ "Content-Type": "application/json", "Authorization": "Bearer blah" }`

## Using the FormData

When you need to provide data to `%request.MimeData` you must use a FormData instance. After your FormData is filled with the data you require, you provide it to the agent like so:

```objectscript
 set formData = agent.NewFormData()
 do formData.Append("key", "value") // You CAN repeat the key just like you would with a real form data object.
 do agent.Post("/some/resource", formData)
```

## Sending a stream

If for some reason you need to send a stream like a binary or a plain text file, you provide an instance of something that inherits from %Stream.Object:

```objectscript
set binaryFile = ##class(%Stream.FileBinary).%New()
do binary.LinkToFile("/some/binary/file.bin")
do agent.Post("/some/resource", binaryFile)
```

You'll find that stream allocated on `%request.Content`.

## Default settings

You can use default settings if you find yourself repeating request headers or cookies too often.
These settings can be configured with the builder:

* **WithHeaders**(_overrides_ As %DynamicObject): This sets the headers to be sent on every request.
* **WithCookies**(cookies As %DynamicArray): This sets the cookies to be sent on every request.

> :warning: NOTE: While in theory you could use WithHeaders to set cookies as well, you might be subjected to unexpected behaviors so stick with each method instead.

## Context: request, response, session and reply

Every request the agent executes will generate a context object. This is object is composed by instances of %CSP.Response, %CSP.Session and a request-like object.
The "request-like" is due to some restrictions imposed by the original %CSP.Request contract, such as private methods that are vital to Forgery's operation, so
we have something that looks like a %CSP.Request.

You can get all three objects like so:

```objectscript
set response = agent.GetLastResponse() // %CSP.Response
set request = agent.GetLastRequest() // %CSP.Request
set reply = agent.GetLastReply() // %Stream.Object
```

You can also retrieve the whole context object if you prefer, the methods above are just shorcuts:

```objectscript
set context = agent.GetLastContext()
```

## About the Jar

The cookie Jar is a in-memory storage managed by the agent that mimicks the browser cookie storage. It uses the jar to store any cookies from the CSP response object. This allows the agent to keep state between requests, such as executing an authentication request and then accessing a private resource. While for testing this is not ideal, for request debugging it's worth using.

## Dispatch handlers

Dispatch handlers are adapters that help Forgery negotiate the request with the actual web application's dispatch class (router). By default Forgery comes with a dispatch handler for handling %CSP.REST routers, but you can also create your own if you need to. In order to do so, make sure you have the following boilerplate class in place:

```objectscript
Class User.MyDispatchHandler Extends (%RegisteredObject, Forgery.IDispatchHandler)
{

Method OnDispatch(resource As %String, httpMethod As %String, restDispatchClass As %String, cspContext As Forgery.CSP.Context, interceptor As Forgery.IO.DeviceInterceptor) As %Status
{

}

Method OnDispose() As %Status
{

}

}
```

You can check the class `Forgery.CSP.DefaultDispatchHandler` for a concrete example.

After you create it, you can provide this adapter at the building phase:

```objectscript
do builder.UseDispatchHandler(##class(User.MyDispatchHandler).%New())
```

## CONTRIBUTING

If you want to contribute with this project. Please read the [CONTRIBUTING](https://github.com/rfns/forgery/blob/master/CONTRIBUTING.md) file.

## LICENSE

[MIT](https://github.com/rfns/forgery/blob/master/LICENSE.md).
