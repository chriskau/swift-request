# swift-request

This module provides a convenient alternative to NSMutableURLRequest, replicating [d3-request](https://github.com/d3/d3-request). It is experimental and not recommended to be used in production environments.


To load a HTML file:

```swift
request("https://www.google.com")?
    .mimeType("text/html")
    .send("GET") {
        (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) in
        print(response)
}
```

To load and parse a JSON file:

```swift
json("https://api.github.com/users/apple/repos") {
    (error: NSError?, json: AnyObject?) in
    print(json)
}
```

To post some query parameters:

```swift

request("/path/to/resource")?
    .header("Content-Type", "application/x-www-form-urlencoded")
    .post("a=2&b=3", completion: { (error, response, data) -> Void in
        print(response)
    })
```

It currently has built-in support for parsing [JSON](#json) only. 



## API Reference

<a name="request" href="#request">#</a><b>request</b>(<i>url</i>[, <i>callback</i>])

Returns a new asynchronous request for specified *url*. If no *callback* is specified, the request is not yet [sent](#request_send) and can be further configured. If a *callback* is specified, it is equivalent to calling [*request*.get](#request_get) immediately after construction:

```swift
request(url)
    .get(callback);
```

Note: if you wish to specify a request header or a mime type, you must *not* specify a callback to the constructor. Use [*request*.header](#request_header) or [*request*.mimeType](#request_mimeType) followed by [*request*.get](#request_get) instead.

<a name="request_header" href="#request_header">#</a> <i>request</i>.<b>header</b>(<i>name</i>[, <i>value</i>])

If *value* is specified, sets the request header with the specified *name* to the specified value and returns this request instance. If *value* is null, removes the request header with the specified *name* instead. If *value* is not specified, returns the current value of the request header with the specified *name*. Header names are case-insensitive.

Request headers can only be modified before the request is [sent](#request_send). Therefore, you cannot pass a callback to the [request constructor](#request) if you wish to specify a header; use [*request*.get](#request_get) or similar instead. For example:

```swift
request(url)
    .header("Accept-Language", "en-US")
    .get(callback);
```

<a name="request_mimeType" href="#request_mimeType">#</a> <i>request</i>.<b>mimeType</b>([<i>type</i>])

If *type* is specified, sets the request mime type to the specified value and returns this request instance. If *type* is null, clears the current mime type (if any) instead. If *type* is not specified, returns the current mime type, which defaults to null. The mime type is used to both set the ["Accept" request header](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) and for [overrideMimeType](http://www.w3.org/TR/XMLHttpRequest/#the-overridemimetype%28%29-method), where supported.

The request mime type can only be modified before the request is [sent](#request_send). Therefore, you cannot pass a callback to the [request constructor](#request) if you wish to override the mime type; use [*request*.get](#request_get) or similar instead. For example:

```swift
request(url)
    .mimeType("text/csv")
    .get(callback);
```

<a name="request_get" href="#request_get">#</a> <i>request</i>.<b>get</b>([<i>callback</i>])

Equivalent to [*request*.send](#request_send) with the GET method:

```swift
request.send("GET", callback);
```

<a name="request_post" href="#request_post">#</a> <i>request</i>.<b>post</b>([<i>data</i>][, <i>callback</i>])

Equivalent to [*request*.send](#request_send) with the POST method:

```swift
request.send("POST", data, callback);
```

<a name="request_send" href="#request_send">#</a> <i>request</i>.<b>send</b>(<i>method</i>[, <i>data</i>][, <i>callback</i>])

Issues this request using the specified *method* (such as `"GET"` or `"POST"`), optionally posting the specified *data* in the request body, and returns this request instance. If a *callback* is specified, the callback will be invoked asynchronously when the request succeeds or fails. The callback is invoked with two arguments: the error, if any, and the [response value](#request_response).
<a name="json" href="#json">#</a> d3.<b>json</b>(<i>url</i>[, <i>callback</i>])

Creates a request for the [JSON](http://json.org) file at the specified *url* with the default mime type `"application/json"`.
