import Result
import CBGPromise
import Freddy

public protocol UserService {
    func createAccount(_ email: String, password: String) -> Future<Result<String, SinopeError>>
    func login(_ email: String, password: String) -> Future<Result<String, SinopeError>>
    func addDeviceToken(_ token: String, authToken: String) -> Future<Result<Void, SinopeError>>
    func deleteAccount(_ authToken: String) -> Future<Result<Void, SinopeError>>
}

public struct PasiphaeUserService: UserService {
    fileprivate let baseURL: URL
    fileprivate let networkClient: NetworkClient
    fileprivate let appToken: String

    public init(baseURL: URL, networkClient: NetworkClient, appToken: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.appToken = appToken
    }

    public func createAccount(_ email: String, password: String) -> Future<Result<String, SinopeError>> {
        return self.getApiToken(email, password: password, endpoint: "create", networkMethod: self.networkClient.put)
    }

    public func login(_ email: String, password: String) -> Future<Result<String, SinopeError>> {
        return self.getApiToken(email, password: password, endpoint: "login", networkMethod: self.networkClient.post)
    }

    public func addDeviceToken(_ token: String, authToken: String) -> Future<Result<Void, SinopeError>> {
        let url = self.baseURL.appendingPathComponent("api/v1/user/add_device_token")
        let body = try! JSONSerialization.data(withJSONObject: ["token": "device_token"], options: [])
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.put(url, headers: headers, body: body).map { res -> Result<Void, SinopeError> in
            switch (res) {
            case let .success(data):
                if String(data: data, encoding: String.Encoding.utf8) == "HTTP Token: Access denied.\n" {
                    return .failure(.notLoggedIn)
                }
                return .success()
            case .failure(_):
                return .failure(.network)
            }
        }
    }

    public func deleteAccount(_ authToken: String) -> Future<Result<Void, SinopeError>> {
        let url = self.baseURL.appendingPathComponent("api/v1/user/delete")
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Authorization": "Token token=\"\(authToken)\"",
            "Content-Type": "application/json"
        ]
        return self.networkClient.delete(url, headers: headers).map { res -> Result<Void, SinopeError> in
            switch (res) {
            case let .success(data):
                if String(data: data, encoding: String.Encoding.utf8) == "HTTP Token: Access denied.\n" {
                    return .failure(.notLoggedIn)
                }
                return .success()
            case .failure(_):
                return .failure(.network)
            }
        }
    }

    fileprivate func getApiToken(_ email: String, password: String, endpoint: String, networkMethod: (URL, [String: String], Data) -> Future<Result<Data, NSError>>) -> Future<Result<String, SinopeError>> {
        let url = self.baseURL.appendingPathComponent("api/v1/user/" + endpoint)
        let body = try! JSONSerialization.data(withJSONObject: ["email": email, "password": password], options: [])
        let headers = [
            "X-APP-TOKEN": self.appToken,
            "Content-Type": "application/json"
        ]
        return networkMethod(url, headers, body).map { res -> Result<String, SinopeError> in
            switch (res) {
            case let .success(data):
                if let json = try? JSON(data: data), let apiToken = try? json.string("api_token") {
                    return .success(apiToken)
                } else {
                    return .failure(.json)
                }
            case .failure(_):
                return .failure(.network)
            }
        }
    }
}
