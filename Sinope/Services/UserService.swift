import Result
import CBGPromise
import Freddy

public protocol UserService {
    func createAccount(email: String, password: String) -> Future<Result<String, SinopeError>>
    func login(email: String, password: String) -> Future<Result<String, SinopeError>>
    func addDeviceToken(token: String, authToken: String) -> Future<Result<Void, SinopeError>>
    func deleteAccount(authToken: String) -> Future<Result<Void, SinopeError>>
}

public struct PasiphaeUserService: UserService {
    private let baseURL: NSURL
    private let networkClient: NetworkClient
    private let appToken: String

    public init(baseURL: NSURL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func createAccount(email: String, password: String) -> Future<Result<String, SinopeError>> {
        return self.getApiToken(email, password: password, endpoint: "create", networkMethod: self.networkClient.put)
    }

    public func login(email: String, password: String) -> Future<Result<String, SinopeError>> {
        return self.getApiToken(email, password: password, endpoint: "login", networkMethod: self.networkClient.post)
    }

    public func addDeviceToken(token: String, authToken: String) -> Future<Result<Void, SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/user/add_device_token")
        let body = try! NSJSONSerialization.dataWithJSONObject(["token": "device_token"], options: [])
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.put(url, headers: headers, body: body).map { res -> Result<Void, SinopeError> in
            switch (res) {
            case let .Success(data):
                if String(data: data, encoding: NSUTF8StringEncoding) == "HTTP Token: Access denied.\n" {
                    return .Failure(.NotLoggedIn)
                }
                return .Success()
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }

    public func deleteAccount(authToken: String) -> Future<Result<Void, SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/user/delete")
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.delete(url, headers: headers).map { res -> Result<Void, SinopeError> in
            switch (res) {
            case let .Success(data):
                if String(data: data, encoding: NSUTF8StringEncoding) == "HTTP Token: Access denied.\n" {
                    return .Failure(.NotLoggedIn)
                }
                return .Success()
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }

    private func getApiToken(email: String, password: String, endpoint: String, networkMethod: (NSURL, [String: String], NSData) -> Future<Result<NSData, NSError>>) -> Future<Result<String, SinopeError>> {
        let url = self.baseURL.URLByAppendingPathComponent("api/v1/user/" + endpoint)
        let body = try! NSJSONSerialization.dataWithJSONObject(["email": email, "password": password], options: [])
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Content-Type": "application/json"
        ]
        return networkMethod(url, headers, body).map { res -> Result<String, SinopeError> in
            switch (res) {
            case let .Success(data):
                if let json = try? JSON(data: data), apiToken = try? json.string("api_token") {
                    return .Success(apiToken)
                } else {
                    return .Failure(.JSON)
                }
            case .Failure(_):
                return .Failure(.Network)
            }
        }
    }
}
