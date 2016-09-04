import CBGPromise
import Result

public protocol NetworkClient {
    func get(_ url: URL, headers: [String: String]) -> Future<Result<Data, NSError>>
    func put(_ url: URL, headers: [String: String], body: Data) -> Future<Result<Data, NSError>>
    func post(_ url: URL, headers: [String: String], body: Data) -> Future<Result<Data, NSError>>
    func delete(_ url: URL, headers: [String: String]) -> Future<Result<Data, NSError>>
}
