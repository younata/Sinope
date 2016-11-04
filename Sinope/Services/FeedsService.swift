import Result
import CBGPromise
import Freddy

public protocol FeedsService {
    func check(url: URL) -> Future<Result<CheckResult, SinopeError>>
    func subscribe(feeds: [URL], authToken: String) -> Future<Result<[URL], SinopeError>>
    func unsubscribe(feeds: [URL], authToken: String) -> Future<Result<[URL], SinopeError>>

    func fetch(authToken: String, feeds: [URL: Date]) -> Future<Result<[Feed], SinopeError>>
}

public struct PasiphaeFeedsService: FeedsService {
    private let baseURL: URL
    private let networkClient: NetworkClient
    private let appToken: String

    public init(baseURL: URL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func check(url: URL) -> Future<Result<CheckResult, SinopeError>> {
        var urlComponents = URLComponents(url: self.baseURL.appendingPathComponent("api/v1/feeds/check"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "url", value: url.absoluteString)]
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Content-Type": "application/json"
        ]
        return self.networkClient.get(urlComponents.url!, headers: headers).map { res -> Result<CheckResult, SinopeError> in
            switch (res) {
            case let .success(data):
                do {
                    let json = try JSON(data: data)
                    let dictionary = try json.getDictionary()
                    if let jsonFeed = dictionary["feed"], let feed = try? jsonFeed.getString(), let feedURL = URL(string: feed) {
                        return .success(.feed(feedURL))
                    } else if let jsonOPML = dictionary["opml"], let opml = try? jsonOPML.decodedArray(type: String.self) {
                        let urls = opml.flatMap({ URL(string: $0) })
                        if !urls.isEmpty {
                            return .success(.opml(urls))
                        } else {
                            return .success(.none)
                        }
                    } else {
                        return .success(.none)
                    }
                } catch {
                    return .failure(.json)
                }
            case .failure(_):
                return .failure(.network)
            }
        }
    }

    public func subscribe(feeds: [URL], authToken: String) -> Future<Result<[URL], SinopeError>> {
        return self.subunsub(action: "subscribe", feeds: feeds, authToken: authToken)
    }

    public func unsubscribe(feeds: [URL], authToken: String) -> Future<Result<[URL], SinopeError>> {
        return self.subunsub(action: "unsubscribe", feeds: feeds, authToken: authToken)
    }

    public func fetch(authToken: String, feeds: [URL: Date]) -> Future<Result<[Feed], SinopeError>> {
        let urlComponents = URLComponents(url: self.baseURL.appendingPathComponent("api/v1/feeds/fetch"), resolvingAgainstBaseURL: false)!
        let dateFormatter = DateFormatter.sharedFormatter
        let queryDict = feeds.mapPairs { url, date in
            return (url.absoluteString, dateFormatter.string(from: date))
        }
        let body: Data
        if !queryDict.isEmpty {
            body = (try? JSONSerialization.data(withJSONObject: queryDict, options: [])) ?? Data()
        } else {
            body = Data()
        }
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.post(urlComponents.url!, headers: headers, body: body).map { res -> Result<[Feed], SinopeError> in
            switch (res) {
            case let .success(data):
                do {
                    if String(data: data, encoding: String.Encoding.utf8) == "HTTP Token: Access denied.\n" {
                        return .failure(.notLoggedIn)
                    }
                    let json = try JSON(data: data)
                    let feeds = try json.decodedArray(at: "feeds", type: Feed.self)
                    return .success(feeds)
                } catch {
                    return .failure(.json)
                }
            case .failure(_):
                return .failure(.network)
            }
        }
    }

    private func subunsub(action: String, feeds: [URL], authToken: String) -> Future<Result<[URL], SinopeError>> {
        let url = self.baseURL.appendingPathComponent("api/v1/feeds/" + action)
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        let feedStrings = feeds.map { $0.absoluteString }
        let body = try! JSONSerialization.data(withJSONObject: ["feeds": feedStrings], options: [])
        return self.networkClient.post(url, headers: headers, body: body).map { res -> Result<[URL], SinopeError> in
            switch (res) {
            case let .success(data):
                if String(data: data, encoding: String.Encoding.utf8) == "HTTP Token: Access denied.\n" {
                    return .failure(.notLoggedIn)
                }
                do {
                    let json = try JSON(data: data)
                    let array: [String] = try json.decodedArray()
                    let urls = array.flatMap { URL(string: $0) }
                    return .success(urls)
                } catch {
                    return .failure(.json)
                }
            case .failure(_):
                return .failure(.network)
            }
        }
    }
}
