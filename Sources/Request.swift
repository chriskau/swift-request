// Copyright (c) 2016 Chris Kau
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public class XHRMutableURLRequest {
    var request: NSMutableURLRequest

    var theClosure: ((someString: String) -> ())?

    init(URL: NSURL) {
        self.request = NSMutableURLRequest(URL: URL)
    }

    public func header(name: String, _ value: String="") -> XHRMutableURLRequest {
        self.request.setValue(value, forHTTPHeaderField: name)
        return self
    }

    public func mimeType(type: String) -> XHRMutableURLRequest {
        self.header("Accept", type)
        self.header("Content-Type", type)
        return self
    }

    public func send(method: String, _ data: NSData?=nil, completion: (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) -> Void) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)

        self.request.HTTPMethod = method

        if (self.request.HTTPMethod == "POST") {
            self.request.HTTPBody = data
        }

        let task = session.dataTaskWithRequest(self.request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            let HTTPResponse = response as? NSHTTPURLResponse
            completion(error: error, response: HTTPResponse, data: data)
        }

        task.resume()
    }

    public func post(completion: (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) -> Void) {
        self.post(nil, completion: completion)
    }

    public func post(data: String, completion: (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) -> Void) {
        let encodedData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        self.post(encodedData, completion: completion)
    }

    public func post(data: NSData?=nil, completion: (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) -> Void) {
        self.send("POST", data, completion: completion)
    }

    public func get(completion: (error: NSError?, response: NSHTTPURLResponse?, data: NSData?) -> Void) {
        self.send("GET", completion: completion)
    }

    public func response(completion: (someString: String) -> ()) -> XHRMutableURLRequest {
        self.theClosure = completion
        return self
    }
}

public class JSONMutableURLRequest : XHRMutableURLRequest {
    public func get(completion: (error: NSError?, json: AnyObject?) -> Void) {
        self.send("GET") { (error, response, data) -> Void in
            if ((error) != nil) {
                completion(error: error, json: nil)
                return
            }

            do {
                let x = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                completion(error: error, json: x)
            } catch {
                print("ERROR: Couldn't parse JSON: \(self.request.URL!)")
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        }
    }

    override public func header(name: String, _ value: String="") -> JSONMutableURLRequest {
        return super.header(name, value) as! JSONMutableURLRequest
    }
}


public func request(url: NSURL) -> XHRMutableURLRequest? {
    let request = XHRMutableURLRequest(URL: url)
    return request
}

public func request(path: String) -> XHRMutableURLRequest? {
    if let url = NSURL(string: path) {
        return XHRMutableURLRequest(URL: url)
    }

    return nil
}


// MARK: JSON
public func json(url: NSURL) -> JSONMutableURLRequest {
    let request = JSONMutableURLRequest(URL: url)
    request.mimeType("application/json")
    return request
}

public func json(path: String) -> JSONMutableURLRequest? {
    let escapedPath = path.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    if let url = NSURL(string: escapedPath!) {
        return json(url)
    }

    return nil
}

public func json(path: String, completion: (error: NSError?, json: AnyObject?) -> Void) {
    let escapedPath = path.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    if let url = NSURL(string: escapedPath!) {
        json(url, completion: completion)
    }
}

public func json(url: NSURL, completion: (error: NSError?, json: AnyObject?) -> Void) {
    json(url).get { (error, json) -> Void in
        completion(error: error, json: json)
    }
}
