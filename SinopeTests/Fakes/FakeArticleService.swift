import Foundation
import Sinope
import Result
import CBGPromise

class FakeArticleService: ArticleService, Equatable {
    private(set) var markReadCallCount: Int = 0
    var markReadStub: (([URL: Bool], String) -> (Future<Result<Void, SinopeError>>))?
    private var markReadArgs: Array<([URL: Bool], String)> = []
    func markReadReturns(_ stubbedValues: (Future<Result<Void, SinopeError>>)) {
        self.markReadStub = {_ in stubbedValues }
    }
    func markReadArgsForCall(_ callIndex: Int) -> ([URL: Bool], String) {
        return self.markReadArgs[callIndex]
    }
    func markRead(articles: [URL: Bool], authToken: String) -> (Future<Result<Void, SinopeError>>) {
        self.markReadCallCount += 1
        self.markReadArgs.append(articles, authToken)
        return self.markReadStub!(articles, authToken)
    }
}

func == (a: FakeArticleService, b: FakeArticleService) -> Bool {
    return a === b
}
