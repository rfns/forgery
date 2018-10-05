<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Forgery

*Forgery* is a server-side utility that allows executing simulated HTTP request by __forging__ calls to Frontier applications. This makes *Forgery* ideal for using together with test suites that need to call the API via HTTP but could face issues with license usage and its grace period.

> NOTE: This is not a tool used to bypass license limits, but instead it's simply an auxiliary tool for facilitating authoring request tests and debugging them without hitting the network layer. Because let's face it, debugging request is actually a pain.

# How it works

After retrieving the web application and dispatch class from the provided url. A device redirection is put in play to capture all the outputs coming from the dispatch class. The diagram below describes how the mimicked request is transfer to the actual dispatcher.

![Forgery request flow](https://github.com/rfns/forgery/raw/master/doc/assets/forgery-requestflow.png)

## Agent

The Agent is responsible for mimicking a client that executes a request to the server. It's represented by the class `Forgery.Agent`, that's composed by six shortcut methods:

* Post
* Put
* Delete
* Patch
* Options
* Head

Each method accepts a configuration object that's a subset of settings from the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).

# Usage

Calling a resource that replies to POST requests.

```
set agent = ##class(Forgery.Agent).%New()
set sc = agent.Post({
  "url": "api/forgery/samples/echo",
  "headers": {
    "Content-Type": "application/json; charset=utf-8"
  },
  "data": {
    "message": "Send me back"
  }
},
.response,
1, // Automatically outputs the response to the current device.
)

if $$$ISERR(sc) write "Received a server error: "_$System.OBJ.GetErrorText(sc)
return $$$OK
```

# Known issues

The following situations are known issues and can be caused due to the device redirection. If you have any ideas on how to fix it, please let me know:

* Method handling requests that attempts to serialize using `do obj.%ToJSON` will fail to render the serialized object.

* Methods that call APIs to generate files (like handling uploads) will mostly like fail. The current workaround is to ignore the file generation and check if the request handler method completed without issues.

## CONTRIBUTING

If you want to contribute with this project. Please read the [CONTRIBUTING](https://github.com/rfns/forgery/blob/master/CONTRIBUTING.md) file.

## LICENSE

[MIT](https://github.com/rfns/forgery/blob/master/LICENSE.md).



