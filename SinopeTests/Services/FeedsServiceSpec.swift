import Quick
import Nimble
@testable import Sinope
import Result
import CBGPromise
import Freddy

class FeedsServiceSpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeFeedsService!
        let baseURL = NSURL(string: "https://example.com/")!
        var networkClient: FakeNetworkClient!

        beforeEach {
            networkClient = FakeNetworkClient()
            subject = PasiphaeFeedsService(baseURL: baseURL, networkClient: networkClient, appToken: "app_token")
        }

        describe("check") {
            var receivedFuture: Future<Result<[NSURL: Bool], SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.getStub = { _ in promise.future}

                receivedFuture = subject.check(NSURL(string: "https://example.org/feed")!)
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to fetch") {
                expect(networkClient.getCallCount) == 1

                guard networkClient.getCallCount == 1 else { return }

                let args = networkClient.getArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/feeds/check?url=https://example.org/feed")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Content-Type": "application/json"]
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = ("{\"https://example.org/feed\": true}").dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with whether or not that url is a feed") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [NSURL(string: "https://example.org/feed")!: true]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.Success(NSData()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .JSON
                    }
                }
            }

            describe("when the network call fails") {
                beforeEach {
                    promise.resolve(.Failure(NSError(domain: "", code: 0, userInfo: nil)))
                }

                it("resolves the future with a network error") {
                    expect(receivedFuture.value?.error) == .Network
                }
            }
        }

        describe("subscribe") {
            var receivedFuture: Future<Result<[NSURL], SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.subscribe([NSURL(string: "https://example.org/feed2")!], authToken: "auth_token")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to subscribe") {
                expect(networkClient.postCallCount) == 1

                let args = networkClient.postArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/feeds/subscribe")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: NSUTF8StringEncoding)
                expect(body) == "{\"feeds\":[\"https:\\/\\/example.org\\/feed2\"]}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "[\"https://example.org/feed1\", \"https://example.org/feed2\"]".dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with the list of subscribed feeds") {
                        expect(receivedFuture.value?.value) == [
                            NSURL(string: "https://example.org/feed1")!,
                            NSURL(string: "https://example.org/feed2")!
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.Success(NSData()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .JSON
                    }
                }
            }

            describe("when the network call fails") {
                beforeEach {
                    promise.resolve(.Failure(NSError(domain: "", code: 0, userInfo: nil)))
                }

                it("resolves the future with a network error") {
                    expect(receivedFuture.value?.error) == .Network
                }
            }
        }

        describe("unsubscribe") {
            var receivedFuture: Future<Result<[NSURL], SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.unsubscribe([NSURL(string: "https://example.org/feed2")!], authToken: "auth_token")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to unsubscribe") {
                expect(networkClient.postCallCount) == 1

                let args = networkClient.postArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/feeds/unsubscribe")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: NSUTF8StringEncoding)
                expect(body) == "{\"feeds\":[\"https:\\/\\/example.org\\/feed2\"]}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "[\"https://example.org/feed1\", \"https://example.org/feed2\"]".dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with the list of subscribed feeds") {
                        expect(receivedFuture.value?.value) == [
                            NSURL(string: "https://example.org/feed1")!,
                            NSURL(string: "https://example.org/feed2")!
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.Success(NSData()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .JSON
                    }
                }
            }

            describe("when the network call fails") {
                beforeEach {
                    promise.resolve(.Failure(NSError(domain: "", code: 0, userInfo: nil)))
                }

                it("resolves the future with a network error") {
                    expect(receivedFuture.value?.error) == .Network
                }
            }
        }

        describe("fetch") {
            var receivedFuture: Future<Result<[Feed], SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.getStub = { _ in promise.future}

                receivedFuture = subject.fetch("auth_token", feeds: [NSURL(string: "https://example.com/")!: NSDate(timeIntervalSince1970: 0)])
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to fetch") {
                expect(networkClient.getCallCount) == 1

                guard networkClient.getCallCount == 1 else { return }

                let args = networkClient.getArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/feeds/fetch?feeds=%7B%22https:%5C/%5C/example.com%5C/%22:%221970-01-01T00:00:00.000Z%22%7D")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"auth_token\"",
                                   "Content-Type": "application/json"]
            }

            describe("fetching without a date") {
                beforeEach {
                    promise = Promise<Result<NSData, NSError>>()
                    networkClient.getStub = { _ in promise.future}

                    receivedFuture = subject.fetch("auth_token", feeds: [:])
                }

                it("returns an in-progress future") {
                    expect(receivedFuture.value).to(beNil())
                }

                it("makes a request to fetch") {
                    expect(networkClient.getCallCount) == 2

                    guard networkClient.getCallCount == 2 else { return }

                    let args = networkClient.getArgsForCall(1)
                    expect(args.0) == NSURL(string: "https://example.com/api/v1/feeds/fetch")
                    expect(args.1) == ["X-APP-TOKEN": "app_token",
                                       "Authorization": "Token token=\"auth_token\"",
                                       "Content-Type": "application/json"]
                }
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = ("{\"last_updated\": \"2016-07-13T22:21:00.000Z\", \"feeds\": [{\"title\": \"Rachel Brindle\"," +
                            "\"url\": \"https://younata.github.io/feed.xml\"," +
                            "\"summary\": null," +
                            "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                            "\"image_url\": \"https://example.com/image.png\", \"articles\": []}]}").dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with the feeds received") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.error).to(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"
                        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
                        expect(receivedFuture.value?.value) == [
                            Feed(title: "Rachel Brindle", url: NSURL(string: "https://younata.github.io/feed.xml")!,
                                summary: "", imageUrl: NSURL(string: "https://example.com/image.png"),
                                lastUpdated: dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")!, articles: [])
                        ]
                    }
                }

                describe("with an invalid json object") {
                    beforeEach {
                        promise.resolve(.Success(NSData()))
                    }

                    it("resolves the future with a json error") {
                        expect(receivedFuture.value?.error) == .JSON
                    }
                }
            }

            describe("when the network call fails") {
                beforeEach {
                    promise.resolve(.Failure(NSError(domain: "", code: 0, userInfo: nil)))
                }

                it("resolves the future with a network error") {
                    expect(receivedFuture.value?.error) == .Network
                }
            }
        }
    }
}
