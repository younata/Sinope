import Result
import CBGPromise
import Freddy

public protocol FeedsService {
    func check(url: NSURL) -> Future<Result<[NSURL: Bool], SinopeError>>
    func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>
    func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>

    func fetch(authToken: String, feeds: [NSURL: NSDate]) -> Future<Result<[Feed], SinopeError>>
}

public struct PasiphaeFeedsService: FeedsService {
    private let baseURL: NSURL
    private let networkClient: NetworkClient
    private let appToken: String

    public init(baseURL: NSURL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func check(url: NSURL) -> Future<Result<[NSURL: Bool], SinopeError>> {
        let urlComponents = NSURLComponents(URL: self.baseURL.URLByAppendingPathComponent("api/v1/feeds/check"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [NSURLQueryItem(name: "url", value: url.absoluteString)]
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Content-Type": "application/json"
        ]
        return self.networkClient.get(urlComponents.URL!, headers: headers).map { res -> Result<[NSURL: Bool], SinopeError> in
            switch (res) {
            case let .Success(data):
                do {
                    let json = try JSON(data: data)
                    let dictionary = try json.dictionary()
                    let retValue: [NSURL: Bool] = try dictionary.flatMapPairs { urlString, jsonBool in
                        if let url = NSURL(string: urlString) {
                            return (url, try jsonBool.bool())
                        }
                        return nil
                    }
                    return .Success(retValue)
                } catch {
                    return .Failure(.JSON)
                }
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }

    public func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        return self.subunsub("subscribe", feeds: feeds, authToken: authToken)
    }

    public func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        return self.subunsub("unsubscribe", feeds: feeds, authToken: authToken)
    }

    public func fetch(authToken: String, feeds: [NSURL: NSDate]) -> Future<Result<[Feed], SinopeError>> {
        let urlComponents = NSURLComponents(URL: self.baseURL.URLByAppendingPathComponent("api/v1/feeds/fetch"), resolvingAgainstBaseURL: false)!
        let dateFormatter = DateFormatter.sharedFormatter
        let queryDict = feeds.mapPairs { url, date in
            return (url.absoluteString, dateFormatter.stringFromDate(date))
        }
        if !queryDict.isEmpty {
            let json = (try? NSJSONSerialization.dataWithJSONObject(queryDict, options: [])) ?? NSData()
            let jsonString = String(data: json, encoding: NSUTF8StringEncoding) ?? ""
            urlComponents.queryItems = [NSURLQueryItem(name: "feeds", value: jsonString)]
        }
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.get(urlComponents.URL!, headers: headers).map { res -> Result<[Feed], SinopeError> in
            switch (res) {
            case let .Success(data):
                do {
                    if String(data: data, encoding: NSUTF8StringEncoding) == "HTTP Token: Access denied.\n" {
                        return .Failure(.NotLoggedIn)
                    }
                    let json = try JSON(data: data)
                    let feeds = try json.arrayOf("feeds", type: Feed.self)
                    return .Success(feeds)
                } catch {
                    return .Failure(.JSON)
                }
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }

    private func subunsub(action: String, feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/feeds/" + action)
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        let feedStrings = feeds.map { $0.absoluteString }
        let body = try! NSJSONSerialization.dataWithJSONObject(["feeds": feedStrings], options: [])
        return self.networkClient.post(url, headers: headers, body: body).map { res -> Result<[NSURL], SinopeError> in
            switch (res) {
            case let .Success(data):
                if String(data: data, encoding: NSUTF8StringEncoding) == "HTTP Token: Access denied.\n" {
                    return .Failure(.NotLoggedIn)
                }
                do {
                    let json = try JSON(data: data)
                    let array: [String] = try json.arrayOf()
                    let urls = array.flatMap { NSURL(string: $0) }
                    return .Success(urls)
                } catch {
                    return .Failure(.JSON)
                }
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }
}
