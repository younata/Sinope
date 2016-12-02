import Quick
import Nimble
@testable import Sinope
import Result
import CBGPromise
import Freddy

class ArticleServiceSpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeArticleService!
        let baseURL = URL(string: "https://example.com/")!
        var networkClient: FakeNetworkClient!

        beforeEach {
            networkClient = FakeNetworkClient()
            subject = PasiphaeArticleService(baseURL: baseURL, networkClient: networkClient, appToken: "app_token")
        }

        describe("markRead(articles:authToken)") {
            var receivedFuture: Future<Result<Void, SinopeError>>!
            var promise: Promise<Result<Data, NSError>>!

            let articles = [
                URL(string: "https://example.com/1")!: true,
                URL(string: "https://example.com/2")!: false,
            ]

            beforeEach {
                promise = Promise<Result<Data, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.markRead(articles: articles, authToken: "auth_token")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to mark the articles sentences") {
                expect(networkClient.postCallCount) == 1

                guard networkClient.postCallCount == 1 else { return }

                let args = networkClient.postArgsForCall(0)

                expect(args.0) == URL(string: "https://example.com/api/v1/articles/update")
                expect(args.1) == [
                    "X-APP-TOKEN": "app_token",
                     "Authorization": "Token token=\"auth_token\"",
                    "Content-Type": "application/json"
                ]

                let bodyObject = try! JSONSerialization.jsonObject(with: args.2, options: []) as! [String: AnyObject]

                expect(bodyObject["articles"] as? [String: NSNumber]) == [
                    "https://example.com/1": true,
                    "https://example.com/2": false,
                ]
                expect(Array(bodyObject.keys)) == ["articles"]
            }

            describe("when the network call succeeds") {
                beforeEach {
                    promise.resolve(.success(Data()))
                }

                it("resolves the future with success") {
                    expect(receivedFuture.value).toNot(beNil())
                    expect(receivedFuture.value?.value).toNot(beNil())
                }
            }

            describe("when the network call fails") {
                beforeEach {
                    promise.resolve(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                }

                it("resolves the future with a network error") {
                    expect(receivedFuture.value?.error) == .network
                }
            }
        }
    }
}
