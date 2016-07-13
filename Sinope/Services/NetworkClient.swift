import CBGPromise
import Result

public protocol NetworkClient {
    func get(url: NSURL, headers: [String: String]) -> Future<Result<NSData, NSError>>
    func put(url: NSURL, headers: [String: String], body: NSData) -> Future<Result<NSData, NSError>>
    func post(url: NSURL, headers: [String: String], body: NSData) -> Future<Result<NSData, NSError>>
    func delete(url: NSURL, headers: [String: String]) -> Future<Result<NSData, NSError>>
}