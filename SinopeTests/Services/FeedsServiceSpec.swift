import Quick
import Nimble
@testable import Sinope
import Result
import CBGPromise
import Freddy

class FeedsServiceSpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeFeedsService!
        let baseURL = URL(string: "https://example.com/")!
        var networkClient: FakeNetworkClient!

        beforeEach {
            networkClient = FakeNetworkClient()
            subject = PasiphaeFeedsService(baseURL: baseURL, networkClient: networkClient, appToken: "app_token")
        }

        describe("check") {
            var receivedFuture: Future<Result<CheckResult, SinopeError>>!
            var promise: Promise<Result<Data, NSError>>!

            beforeEach {
                promise = Promise<Result<Data, NSError>>()
                networkClient.getStub = { _ in promise.future}

                receivedFuture = subject.check(url: URL(string: "https://example.org/feed")!)
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to fetch") {
                expect(networkClient.getCallCount) == 1

                guard networkClient.getCallCount == 1 else { return }

                let args = networkClient.getArgsForCall(0)
                expect(args.0) == URL(string: "https://example.com/api/v1/feeds/check?url=https://example.org/feed")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Content-Type": "application/json"]
            }

            describe("when the network call succeeds") {
                describe("with a valid json object (has a feed)") {
                    beforeEach {
                        let fixture = ("{\"feed\": \"https://example.org/feed\", \"opml\": null}").data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with whether or not that url is a feed") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == CheckResult.feed(URL(string: "https://example.org/feed")!)
                    }
                }

                describe("with a valid json object (has an opml)") {
                    beforeEach {
                        let fixture = ("{\"feed\": null, \"opml\": [\"https://example.org/feed1\", \"https://example.org/feed2\"]}").data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with whether or not that url is a feed") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == CheckResult.opml([
                            URL(string: "https://example.org/feed1")!,
                            URL(string: "https://example.org/feed2")!
                        ])
                    }
                }

                describe("with a valid json object (found nothing)") {
                    beforeEach {
                        let fixture = ("{\"feed\": null, \"opml\": null}").data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with whether or not that url is a feed") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == CheckResult.none
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.success(Data()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .json
                    }
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

        describe("subscribe") {
            var receivedFuture: Future<Result<[URL], SinopeError>>!
            var promise: Promise<Result<Data, NSError>>!

            beforeEach {
                promise = Promise<Result<Data, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.subscribe(feeds: [URL(string: "https://example.org/feed2")!], authToken: "auth_token")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to subscribe") {
                expect(networkClient.postCallCount) == 1

                let args = networkClient.postArgsForCall(0)
                expect(args.0) == URL(string: "https://example.com/api/v1/feeds/subscribe")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: String.Encoding.utf8)
                expect(body) == "{\"feeds\":[\"https:\\/\\/example.org\\/feed2\"]}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "[\"https://example.org/feed1\", \"https://example.org/feed2\"]".data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with the list of subscribed feeds") {
                        expect(receivedFuture.value?.value) == [
                            URL(string: "https://example.org/feed1")!,
                            URL(string: "https://example.org/feed2")!
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.success(Data()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .json
                    }
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

        describe("unsubscribe") {
            var receivedFuture: Future<Result<[URL], SinopeError>>!
            var promise: Promise<Result<Data, NSError>>!

            beforeEach {
                promise = Promise<Result<Data, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.unsubscribe(feeds: [URL(string: "https://example.org/feed2")!], authToken: "auth_token")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to unsubscribe") {
                expect(networkClient.postCallCount) == 1

                let args = networkClient.postArgsForCall(0)
                expect(args.0) == URL(string: "https://example.com/api/v1/feeds/unsubscribe")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: String.Encoding.utf8)
                expect(body) == "{\"feeds\":[\"https:\\/\\/example.org\\/feed2\"]}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "[\"https://example.org/feed1\", \"https://example.org/feed2\"]".data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with the list of subscribed feeds") {
                        expect(receivedFuture.value?.value) == [
                            URL(string: "https://example.org/feed1")!,
                            URL(string: "https://example.org/feed2")!
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.success(Data()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .json
                    }
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

        describe("fetch") {
            var receivedFuture: Future<Result<[Feed], SinopeError>>!
            var promise: Promise<Result<Data, NSError>>!

            beforeEach {
                promise = Promise<Result<Data, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.fetch(authToken: "auth_token", feeds: [URL(string: "https://example.com/")!: Date(timeIntervalSince1970: 0)])
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to fetch") {
                expect(networkClient.postCallCount) == 1

                guard networkClient.postCallCount == 1 else { return }

                let args = networkClient.postArgsForCall(0)
                expect(args.0) == URL(string: "https://example.com/api/v1/feeds/fetch")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: String.Encoding.utf8)
                expect(body) == "{\"https:\\/\\/example.com\\/\":\"1970-01-01T00:00:00.000Z\"}"
            }

            describe("fetching without a date") {
                beforeEach {
                    promise = Promise<Result<Data, NSError>>()
                    networkClient.postStub = { _ in promise.future}

                    receivedFuture = subject.fetch(authToken: "auth_token", feeds: [:])
                }

                it("returns an in-progress future") {
                    expect(receivedFuture.value).to(beNil())
                }

                it("makes a request to fetch") {
                    expect(networkClient.postCallCount) == 2

                    guard networkClient.postCallCount == 2 else { return }

                    let args = networkClient.postArgsForCall(1)
                    expect(args.0) == URL(string: "https://example.com/api/v1/feeds/fetch")
                    expect(args.1) == ["X-APP-TOKEN": "app_token",
                                       "Authorization": "Token token=\"auth_token\"",
                                       "Content-Type": "application/json"]
                    let body = String(data: args.2, encoding: String.Encoding.utf8)
                    expect(body) == ""
                }
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixtureString = "{\"last_updated\": \"2016-07-13T22:21:00.000Z\", \"feeds\": [{\"title\": \"Rachel Brindle\"," +
                            "\"url\": \"https://younata.github.io/feed.xml\"," +
                            "\"summary\": null," +
                            "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                            "\"image_url\": \"https://example.com/image.png\", \"articles\": []}]}"
                        let fixture: Data = fixtureString.data(using: String.Encoding.utf8)!
                        promise.resolve(.success(fixture))
                    }

                    it("resolves the future with the feeds received") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        let dateFormatter = Foundation.DateFormatter()
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"
                        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                        expect(receivedFuture.value?.value) == [
                            Feed(title: "Rachel Brindle", url: URL(string: "https://younata.github.io/feed.xml")!,
                                summary: "", imageUrl: URL(string: "https://example.com/image.png"),
                                lastUpdated: dateFormatter.date(from: "2015-12-23T00:00:00.000Z")!, articles: [])
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.success(Data()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .json
                    }
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
