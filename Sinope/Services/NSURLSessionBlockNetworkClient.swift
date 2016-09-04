import CBGPromise
import Result

extension URLSession: NetworkClient {
    public func get(_ url: URL, headers: [String: String]) -> Future<Result<Data, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "GET", body: nil)
    }

    public func put(_ url: URL, headers: [String: String], body: Data) -> Future<Result<Data, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "PUT", body: body)
    }

    public func post(_ url: URL, headers: [String: String], body: Data) -> Future<Result<Data, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "POST", body: body)
    }

    public func delete(_ url: URL, headers: [String: String]) -> Future<Result<Data, NSError>> {
        return self.performURLRequest(url, headers: headers, method: "DELETE", body: nil)
    }

    private func performURLRequest(_ url: URL, headers: [String: String], method: String, body: Data?) -> Future<Result<Data, NSError>> {
        let request = NSMutableURLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method
        if let body = body {
            request.httpBody = body
        }
        let promise = Promise<Result<Data, NSError>>()
        self.dataTask(with: request as URLRequest) { data, _, error in
            if let data = data {
                promise.resolve(.success(data))
            } else {
                promise.resolve(.failure(error! as NSError))
            }
        }.resume()
        return promise.future
    }
}
