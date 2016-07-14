import Result
import CBGPromise
import Freddy

public protocol FeedsService {
    func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>
    func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>

    func fetch(authToken: String, date: NSDate?) -> Future<Result<(NSDate, [Feed]), SinopeError>>
}

public final class PasiphaeFeedsService: FeedsService {
    private let baseURL: NSURL
    private let networkClient: NetworkClient
    private let appToken: String

    public init(baseURL: NSURL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/feeds/subscribe")
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authentication": "Token token=\"\(authToken)\""
        ]
        let feedStrings = feeds.map { $0.absoluteString }
        let body = try! NSJSONSerialization.dataWithJSONObject(["feeds": feedStrings], options: [])
        return self.networkClient.post(url, headers: headers, body: body).map { res -> Result<[NSURL], SinopeError> in
            switch (res) {
            case let .Success(data):
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

    public func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/feeds/unsubscribe")
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authentication": "Token token=\"\(authToken)\""
        ]
        let feedStrings = feeds.map { $0.absoluteString }
        let body = try! NSJSONSerialization.dataWithJSONObject(["feeds": feedStrings], options: [])
        return self.networkClient.post(url, headers: headers, body: body).map { res -> Result<[NSURL], SinopeError> in
            switch (res) {
            case let .Success(data):
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

    public func fetch(authToken: String, date: NSDate?) -> Future<Result<(NSDate, [Feed]), SinopeError>> {
        let urlComponents = NSURLComponents(URL: self.baseURL.URLByAppendingPathComponent("api/v1/feeds/fetch"), resolvingAgainstBaseURL: false)!
        if let date = date {
            let dateFormatter = DateFormatter.sharedFormatter
            urlComponents.queryItems = [NSURLQueryItem(name: "date", value: dateFormatter.stringFromDate(date))]
        }
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authentication": "Token token=\"\(authToken)\""
        ]
        return self.networkClient.get(urlComponents.URL!, headers: headers).map { res -> Result<(NSDate, [Feed]), SinopeError> in
            switch (res) {
            case let .Success(data):
                do {
                    let json = try JSON(data: data)
                    let dateString = try json.string("last_updated")
                    let dateFormatter = DateFormatter.sharedFormatter
                    if let date = dateFormatter.dateFromString(dateString) {
                        let feeds = try json.arrayOf("feeds", type: Feed.self)
                        return .Success(date, feeds)
                    } else {
                        return .Failure(.JSON)
                    }
                } catch {
                    return .Failure(.JSON)
                }
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }
}
