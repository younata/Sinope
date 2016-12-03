import CBGPromise
import Result

public protocol Repository: class {
    var authToken: String? { get }
    // user modification methods
    func createAccount(_ email: String, password: String) -> Future<Result<Void, SinopeError>>
    func login(_ email: String, password: String) -> Future<Result<Void, SinopeError>>
    func login(_ authToken: String)
    func addDeviceToken(_ token: String) -> Future<Result<Void, SinopeError>>
    func deleteAccount() -> Future<Result<Void, SinopeError>>

    // actual data methods
    func subscribe(_ feeds: [URL]) -> Future<Result<[URL], SinopeError>>
    func unsubscribe(_ feeds: [URL]) -> Future<Result<[URL], SinopeError>>
    func subscribedFeeds() -> Future<Result<[URL], SinopeError>>

    func check(_ url: URL) -> Future<Result<CheckResult, SinopeError>>

    func fetch(_ feeds: [URL: Date]) -> Future<Result<[Feed], SinopeError>>

    func markRead(articles: [URL: Bool]) -> Future<Result<Void, SinopeError>>
}

public func DefaultRepository(_ baseURL: URL, networkClient: NetworkClient, appToken: String) -> Repository {
    let userService = PasiphaeUserService(baseURL: baseURL, networkClient: networkClient, appToken: appToken)
    let feedService = PasiphaeFeedService(baseURL: baseURL, networkClient: networkClient, appToken: appToken)
    let articleService = PasiphaeArticleService(baseURL: baseURL, networkClient: networkClient, appToken: appToken)
    return PasiphaeRepository(userService: userService, feedService: feedService, articleService: articleService)
}

public final class PasiphaeRepository: Repository {
    private let userService: UserService
    private let feedService: FeedService
    private let articleService: ArticleService
    public private(set) var authToken: String? = nil
    public init(userService: UserService, feedService: FeedService, articleService: ArticleService) {
        self.userService = userService
        self.feedService = feedService
        self.articleService = articleService
    }

    //MARK: user modification methods
    private var createAccountPromise: Future<Result<Void, SinopeError>>?
    public func createAccount(_ email: String, password: String) -> Future<Result<Void, SinopeError>> {
        if let createAccountPromise = self.createAccountPromise {
            return createAccountPromise
        }
        self.createAccountPromise = self.userService.createAccount(email, password: password).map { res in
            return res.map { authToken in
                self.authToken = authToken
                return
            }
        }
        return self.createAccountPromise!.then { _ in
            self.createAccountPromise = nil
        }
    }

    private var loginPromise: Future<Result<Void, SinopeError>>?
    public func login(_ email: String, password: String) -> Future<Result<Void, SinopeError>> {
        if let loginPromise = self.loginPromise {
            return loginPromise
        }
        self.loginPromise = self.userService.login(email, password: password).map { res in
            return res.map { authToken in
                self.authToken = authToken
                return
            }
        }
        return self.loginPromise!.then { _ in
            self.loginPromise = nil
        }
    }

    public func login(_ authToken: String) {
        self.authToken = authToken
    }

    private var addDeviceTokenPromise: Future<Result<Void, SinopeError>>?
    public func addDeviceToken(_ token: String) -> Future<Result<Void, SinopeError>> {
        if let logInFuture = self.errorIfLoggedOut(Void.self) {
            return logInFuture
        }
        if let addDeviceTokenPromise = self.addDeviceTokenPromise {
            return addDeviceTokenPromise
        }
        self.addDeviceTokenPromise = self.userService.addDeviceToken(token, authToken: self.authToken!)
        return self.addDeviceTokenPromise!.then { _ in
            self.addDeviceTokenPromise = nil
        }
    }

    private var deleteAccountPromise: Future<Result<Void, SinopeError>>?
    public func deleteAccount() -> Future<Result<Void, SinopeError>> {
        if let logInFuture = self.errorIfLoggedOut(Void.self) {
            return logInFuture
        }
        if let deleteAccountPromise = self.deleteAccountPromise {
            return deleteAccountPromise
        }
        self.deleteAccountPromise = self.userService.deleteAccount(self.authToken!)
        return self.deleteAccountPromise!.then { _ in
            self.deleteAccountPromise = nil
        }
    }


    //MARK: actual data methods

    private var subscribePromise: Future<Result<[URL], SinopeError>>?
    public func subscribe(_ feeds: [URL]) -> Future<Result<[URL], SinopeError>> {
        if let logInFuture = self.errorIfLoggedOut([URL].self) {
            return logInFuture
        }
        if let subscribePromise = self.subscribePromise {
            return subscribePromise
        }
        self.subscribePromise = self.feedService.subscribe(feeds: feeds, authToken: self.authToken!)
        return self.subscribePromise!.then { _ in
            self.subscribePromise = nil
        }
    }

    private var unsubscribePromise: Future<Result<[URL], SinopeError>>?
    public func unsubscribe(_ feeds: [URL]) -> Future<Result<[URL], SinopeError>> {
        if let logInFuture = self.errorIfLoggedOut([URL].self) {
            return logInFuture
        }
        if let unsubscribePromise = self.unsubscribePromise {
            return unsubscribePromise
        }
        self.unsubscribePromise = self.feedService.unsubscribe(feeds: feeds, authToken: self.authToken!)
        return self.unsubscribePromise!.then { _ in
            self.unsubscribePromise = nil
        }
    }

    private var subscribedFeedsPromise: Future<Result<[URL], SinopeError>>?
    public func subscribedFeeds() -> Future<Result<[URL], SinopeError>> {
        if let logInFuture = self.errorIfLoggedOut([URL].self) {
            return logInFuture
        }
        if let subscribedFeedsPromise = self.subscribedFeedsPromise {
            return subscribedFeedsPromise
        }
        self.subscribedFeedsPromise = self.feedService.subscribedFeeds(authToken: self.authToken!)
        return self.subscribedFeedsPromise!.then { _ in
            self.subscribedFeedsPromise = nil
        }
    }

    private var checkPromises: [URL: Future<Result<CheckResult, SinopeError>>] = [:]
    public func check(_ url: URL) -> Future<Result<CheckResult, SinopeError>> {
        if let checkPromise = self.checkPromises[url] {
            return checkPromise
        }
        let promise = self.feedService.check(url: url)
        self.checkPromises[url] = promise
        return promise.then { _ in
            self.checkPromises.removeValue(forKey: url)
        }
    }

    private var fetchPromise: Future<Result<[Feed], SinopeError>>?
    public func fetch(_ feeds: [URL: Date]) -> Future<Result<[Feed], SinopeError>> {
        if let loginFuture = self.errorIfLoggedOut([Feed].self) {
            return loginFuture
        }
        if let fetchPromise = self.fetchPromise {
            return fetchPromise
        }
        self.fetchPromise = self.feedService.fetch(authToken: self.authToken!, feeds: feeds)
        return self.fetchPromise!.then { _ in
            self.fetchPromise = nil
        }
    }

    private var markReadPromise: Future<Result<Void, SinopeError>>?
    public func markRead(articles: [URL: Bool]) -> Future<Result<Void, SinopeError>> {
        if let loginFuture = self.errorIfLoggedOut(Void.self) {
            return loginFuture
        }
        if let markReadPromise = self.markReadPromise {
            return markReadPromise
        }
        self.markReadPromise = self.articleService.markRead(articles: articles, authToken: self.authToken!)
        return self.markReadPromise!.then { _ in
            self.markReadPromise = nil
        }
    }

    // MARK: Private

    private func errorIfLoggedOut<T>(_ successType: T.Type) -> Future<Result<T, SinopeError>>? {
        if self.authToken == nil {
            let promise = Promise<Result<T, SinopeError>>()
            promise.resolve(.failure(.notLoggedIn))
            return promise.future
        }
        return nil
    }
}

