<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Forgery

*Forgery* is a server-side utility that allows executing simulated HTTP request by __forging__ calls to REST applications. This makes *Forgery* ideal for using together with test suites that need to call the API via HTTP but could face issues with license usage and its grace period.

> NOTE: This is not a tool used to bypass license limits, but instead it's simply an auxiliary tool for facilitating authoring request tests and debugging them without hitting the network layer. Because let's face it, debugging requests is actually a pain.

# How it works

After retrieving the web application and dispatch class from the provided url. A device redirection is put in play to capture all the outputs coming from the dispatch class. The diagram below describes how the mimicked request is transferred to the actual dispatcher.

![Forgery request flow](https://github.com/rfns/forgery/blob/master/docs/assets/forgery-requestflow.jpg?raw=true)

## Agent

The Agent is responsible for mimicking a client that executes a request to the server. It's represented by the class `Forgery.Agent` which is composed by six shortcut methods:

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

if $$$ISERR(sc) write "Received a server error: "_$System.Status.GetErrorText(sc)
return $$$OK
```

# Troubleshooting

### _I provided a URL but it's not finding my dispatch class?_

Since you're not actually hitting your web server, you only need to provide the path that
ressembles your web application's name/path onwards. Do not provide the hostname, protocol or any path that is before what you defined for your web application.

### _My application uses custom cookies and I tried setting them using the Set-Cookies header but to no avail?_

There are two ways of doing this:

1. Since multiple cookies with the same name can be set, I decided to dedicate a setting for it: by using the `cookies` setting, which receives a key-value object or an array of values for each named key.

2. By reusing the agent for subsequent request, this way the previous request will have set the cookie, which is good to simulate working with _httpOnly_ cookies.

If you need to set cookies don't use the `Set-Cookies`, because the dispatch class won't know from where to read it.

### _What if my application uses a token-based approach?_

You can simulate authenticated request by providing an `Authorization` header inside the `headers` object.

### _I want to try sending a file, but I have no idea from where to begin!_

You can simulate FormData requests by using the `mimedata` setting. Just pass out a file stream to a key-valued object and you'll be done. e.g.:

```
{
  "mimedata": {
    "my_file_key": (myFileStream)
  }
}

```

If you need to repeat the name, you can provide a `%DynamicArray` of streams for that name instead.

# Known issues

The following situations are known issues. If you have any ideas on how to fix it, please let me know:

* Methods that call APIs to generate files (like handling uploads) will mostly like fail, this is due to the redirection required to capture the content being written, which in turn conflicts with the device change required to write files. The current workaround is to ignore the file generation and check if the request handler method completed without issues.

* Some dispatch classes like the one that exposes the Atelier API will result into an odd response: they'll mix the success and error objects. I'm still trying to figure what is causing that.

## CONTRIBUTING

If you want to contribute with this project. Please read the [CONTRIBUTING](https://github.com/rfns/forgery/blob/master/CONTRIBUTING.md) file.

## LICENSE

[MIT](https://github.com/rfns/forgery/blob/master/LICENSE.md).
