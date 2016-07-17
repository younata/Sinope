import CBGPromise
import Result

extension NSURLSession: NetworkClient {
    public func get(url: NSURL, headers: [String: String]) -> Future<Result<NSData, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "GET", body: nil)
    }

    public func put(url: NSURL, headers: [String: String], body: NSData) -> Future<Result<NSData, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "PUT", body: body)
    }

    public func post(url: NSURL, headers: [String: String], body: NSData) -> Future<Result<NSData, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "POST", body: body)
    }

    public func delete(url: NSURL, headers: [String: String]) -> Future<Result<NSData, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "DELETE", body: nil)
    }

    private func performURLRequest(url: NSURL, headers: [String: String], method: String, body: NSData?) -> Future<Result<NSData, NSError>> {
        let request = NSMutableURLRequest(URL: url)
        request.allHTTPHeaderFields = headers
        request.HTTPMethod = method
        if let body = body {
            request.HTTPBody = body
        }
        let promise = Promise<Result<NSData, NSError>>()
        self.dataTaskWithRequest(request) { data, _, error in
            if let data = data {
                promise.resolve(.Success(data))
            } else {
                promise.resolve(.Failure(error!))
            }
        }.resume()
        return promise.future
    }
}