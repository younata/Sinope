import Result
import CBGPromise
import Freddy

public protocol ArticleService {
    func markRead(articles: [URL: Bool], authToken: String) -> Future<Result<Void, SinopeError>>
}

public struct PasiphaeArticleService: ArticleService {
    private let baseURL: URL
    private let networkClient: NetworkClient
    private let appToken: String

    public init(baseURL: URL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func markRead(articles: [URL : Bool], authToken: String) -> Future<Result<Void, SinopeError>> {
        let url = self.baseURL.appendingPathComponent("api/v1/articles/update", isDirectory: false)
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        let jsonCompatibleArticles = articles.mapPairs { key, value in
            return (key.absoluteString, value)
        }
        let body = try! JSONSerialization.data(withJSONObject: ["articles": jsonCompatibleArticles], options: [])
        return self.networkClient.post(url, headers: headers, body: body).map { res -> Result<Void, SinopeError> in
            switch res {
            case .success(_):
                return .success()
            case .failure(_):
                return .failure(.network)
            }
        }
    }
}
