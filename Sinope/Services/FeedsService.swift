import Result
import CBGPromise

public protocol FeedsService {
    func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>
    func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>>

    func fetch(authToken: String, date: NSDate?) -> Future<Result<[Feed], SinopeError>>
}

public final class PasiphaeFeedsService: FeedsService {
    public func subscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        return Promise<Result<[NSURL], SinopeError>>().future
    }

    public func unsubscribe(feeds: [NSURL], authToken: String) -> Future<Result<[NSURL], SinopeError>> {
        return Promise<Result<[NSURL], SinopeError>>().future
    }

    public func fetch(authToken: String, date: NSDate?) -> Future<Result<[Feed], SinopeError>> {
        return Promise<Result<[Feed], SinopeError>>().future
    }
}
