import Foundation
import Sinope
import Result
import CBGPromise

// this file was generated by Xcode-Better-Refactor-Tools
// https://github.com/tjarratt/xcode-better-refactor-tools

class FakeFeedService : FeedService, Equatable {
    init() {
    }

    private(set) var checkCallCount : Int = 0
    var checkStub : ((URL) -> (Future<Result<CheckResult, SinopeError>>))?
    private var checkArgs : Array<(URL)> = []
    func checkReturns(_ stubbedValues: (Future<Result<CheckResult, SinopeError>>)) {
        self.checkStub = {(url: URL) -> (Future<Result<CheckResult, SinopeError>>) in
            return stubbedValues
        }
    }
    func checkArgsForCall(_ callIndex: Int) -> (URL) {
        return self.checkArgs[callIndex]
    }
    func check(url: URL) -> (Future<Result<CheckResult, SinopeError>>) {
        self.checkCallCount += 1
        self.checkArgs.append((url))
        return self.checkStub!(url)
    }

    private(set) var subscribeCallCount : Int = 0
    var subscribeStub : (([URL], String) -> (Future<Result<[URL], SinopeError>>))?
    private var subscribeArgs : Array<([URL], String)> = []
    func subscribeReturns(_ stubbedValues: (Future<Result<[URL], SinopeError>>)) {
        self.subscribeStub = {(feeds: [URL], authToken: String) -> (Future<Result<[URL], SinopeError>>) in
            return stubbedValues
        }
    }
    func subscribeArgsForCall(_ callIndex: Int) -> ([URL], String) {
        return self.subscribeArgs[callIndex]
    }
    func subscribe(feeds: [URL], authToken: String) -> (Future<Result<[URL], SinopeError>>) {
        self.subscribeCallCount += 1
        self.subscribeArgs.append((feeds, authToken))
        return self.subscribeStub!(feeds, authToken)
    }

    private(set) var unsubscribeCallCount : Int = 0
    var unsubscribeStub : (([URL], String) -> (Future<Result<[URL], SinopeError>>))?
    private var unsubscribeArgs : Array<([URL], String)> = []
    func unsubscribeReturns(_ stubbedValues: (Future<Result<[URL], SinopeError>>)) {
        self.unsubscribeStub = {(feeds: [URL], authToken: String) -> (Future<Result<[URL], SinopeError>>) in
            return stubbedValues
        }
    }
    func unsubscribeArgsForCall(_ callIndex: Int) -> ([URL], String) {
        return self.unsubscribeArgs[callIndex]
    }
    func unsubscribe(feeds: [URL], authToken: String) -> (Future<Result<[URL], SinopeError>>) {
        self.unsubscribeCallCount += 1
        self.unsubscribeArgs.append((feeds, authToken))
        return self.unsubscribeStub!(feeds, authToken)
    }

    private(set) var subscribedFeedsCallCount : Int = 0
    var subscribedFeedsStub : ((String) -> (Future<Result<[URL], SinopeError>>))?
    private var subscribedFeedsArgs : Array<(String)> = []
    func subscribedFeedsReturns(_ stubbedValues: (Future<Result<[URL], SinopeError>>)) {
        self.subscribedFeedsStub = {(authToken: String) -> (Future<Result<[URL], SinopeError>>) in
            return stubbedValues
        }
    }
    func subscribedFeedsArgsForCall(_ callIndex: Int) -> (String) {
        return self.subscribedFeedsArgs[callIndex]
    }
    func subscribedFeeds(authToken: String) -> (Future<Result<[URL], SinopeError>>) {
        self.subscribedFeedsCallCount += 1
        self.subscribedFeedsArgs.append((authToken))
        return self.subscribedFeedsStub!((authToken))
    }

    private(set) var fetchCallCount : Int = 0
    var fetchStub : ((String, [URL: Date]) -> (Future<Result<([Feed]), SinopeError>>))?
    private var fetchArgs : Array<(String, [URL: Date])> = []
    func fetchReturns(_ stubbedValues: (Future<Result<([Feed]), SinopeError>>)) {
        self.fetchStub = {(authToken: String, feeds: [URL: Date]) -> (Future<Result<([Feed]), SinopeError>>) in
            return stubbedValues
        }
    }
    func fetchArgsForCall(_ callIndex: Int) -> (String, [URL: Date]) {
        return self.fetchArgs[callIndex]
    }
    func fetch(authToken: String, feeds: [URL: Date]) -> (Future<Result<([Feed]), SinopeError>>) {
        self.fetchCallCount += 1
        self.fetchArgs.append((authToken, feeds))
        return self.fetchStub!(authToken, feeds)
    }

    static func reset() {
    }
}

func == (a: FakeFeedService, b: FakeFeedService) -> Bool {
    return a === b
}
