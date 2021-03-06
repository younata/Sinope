import Quick
import Nimble
import Sinope
import Result
import CBGPromise

class RepositorySpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeRepository!
        var userService: FakeUserService!
        var feedService: FakeFeedService!
        var articleService: FakeArticleService!

        beforeEach {
            userService = FakeUserService()
            feedService = FakeFeedService()
            articleService = FakeArticleService()
            subject = PasiphaeRepository(userService: userService, feedService: feedService, articleService: articleService)
        }

        describe("creating an account") {
            var receivedFuture: Future<Result<Void, SinopeError>>!
            var promise: Promise<Result<String, SinopeError>>!

            beforeEach {
                promise = Promise<Result<String, SinopeError>>()

                userService.createAccountStub = { _ in promise.future }
                receivedFuture = subject.createAccount("foo", password: "bar")
            }

            it("returns an in-progress promise") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to the user service") {
                expect(userService.createAccountCallCount) == 1
                let args = userService.createAccountArgsForCall(0)
                expect(args.0) == "foo"
                expect(args.1) == "bar"
            }

            it("it returns the exact same future when asked for to login while we're logging in/creating an account") {
                expect(subject.createAccount("foo", password: "bar")).to(beIdenticalTo(receivedFuture))
            }
            describe("when the user service succeeds") {
                beforeEach {
                    promise.resolve(.success("test"))
                }

                it("resolves the received future") {
                    expect(receivedFuture.value).toNot(beNil())
                    expect(receivedFuture.value?.value).toNot(beNil())
                }
            }

            describe("when the user service fails") {
                beforeEach {
                    promise.resolve(.failure(.network))
                }

                it("returns with the same error") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.network))
                }
            }
        }

        describe("logging in to an account") {
            var receivedFuture: Future<Result<Void, SinopeError>>!
            var promise: Promise<Result<String, SinopeError>>!

            beforeEach {
                promise = Promise<Result<String, SinopeError>>()

                userService.loginStub = { _ in promise.future }
                receivedFuture = subject.login("foo", password: "bar")
            }

            it("returns an in-progress promise") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to the user service") {
                expect(userService.loginCallCount) == 1
                let args = userService.loginArgsForCall(0)
                expect(args.0) == "foo"
                expect(args.1) == "bar"
            }

            it("it returns the exact same future when asked for to login while we're logging in/creating an account") {
                expect(subject.login("foo", password: "bar")).to(beIdenticalTo(receivedFuture))
            }

            describe("when the user service succeeds") {
                beforeEach {
                    promise.resolve(.success("test"))
                }

                it("resolves the received future") {
                    expect(receivedFuture.value).toNot(beNil())
                    expect(receivedFuture.value?.value).toNot(beNil())
                }
            }

            describe("when the user service fails") {
                beforeEach {
                    promise.resolve(.failure(.network))
                }

                it("returns with the same error") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.network))
                }
            }
        }

        describe("adding a device token") {
            var receivedFuture: Future<Result<Void, SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.addDeviceToken("myToken")
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var addDevicePromise: Promise<Result<Void, SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    addDevicePromise = Promise<Result<Void, SinopeError>>()
                    userService.addDeviceTokenReturns(addDevicePromise.future)

                    receivedFuture = subject.addDeviceToken("deviceToken")
                }

                it("makes a request to the user service to add the device token") {
                    expect(userService.addDeviceTokenCallCount) == 1
                    let args = userService.addDeviceTokenArgsForCall(0)

                    expect(args.0) == "deviceToken"
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to store tha same device token") {
                    expect(subject.addDeviceToken("deviceToken")).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        addDevicePromise.resolve(.success())
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        addDevicePromise.resolve(.failure(.unknown))
                    }

                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("deleting an account") {
            var receivedFuture: Future<Result<Void, SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.deleteAccount()
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var deletePromise: Promise<Result<Void, SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    deletePromise = Promise<Result<Void, SinopeError>>()
                    userService.deleteAccountReturns(deletePromise.future)

                    receivedFuture = subject.deleteAccount()
                }

                it("makes a request to the user service to add the device token") {
                    expect(userService.deleteAccountCallCount) == 1
                    let args = userService.deleteAccountArgsForCall(0)

                    expect(args) == loginToken
                }

                it("returns the exact same future when we try to delete the account while still waiting for a result") {
                    expect(subject.deleteAccount()).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        deletePromise.resolve(.success())
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        deletePromise.resolve(.failure(.unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("subscribing to a set of feeds") {
            var receivedFuture: Future<Result<[URL], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.subscribe([URL(string: "https://example.com")!])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var subscribePromise: Promise<Result<[URL], SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    subscribePromise = Promise<Result<[URL], SinopeError>>()
                    feedService.subscribeReturns(subscribePromise.future)

                    receivedFuture = subject.subscribe([URL(string: "https://example.com")!])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedService.subscribeCallCount) == 1
                    let args = feedService.subscribeArgsForCall(0)

                    expect(args.0) == [URL(string: "https://example.com")!]
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to subscribe to the same feeds while still waiting for a result") {
                    expect(subject.subscribe([URL(string: "https://example.com")!])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        subscribePromise.resolve(.success([URL(string: "https://example.com")!]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [URL(string: "https://example.com")!]
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        subscribePromise.resolve(.failure(.unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("unsubscribing from a set of feeds") {
            var receivedFuture: Future<Result<[URL], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.unsubscribe([URL(string: "https://example.com")!])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var unsubscribePromise: Promise<Result<[URL], SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    unsubscribePromise = Promise<Result<[URL], SinopeError>>()
                    feedService.unsubscribeReturns(unsubscribePromise.future)

                    receivedFuture = subject.unsubscribe([URL(string: "https://example.com")!])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedService.unsubscribeCallCount) == 1
                    let args = feedService.unsubscribeArgsForCall(0)

                    expect(args.0) == [URL(string: "https://example.com")!]
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to unsubscribe from the same feeds while still waiting for a result") {
                    expect(subject.unsubscribe([URL(string: "https://example.com")!])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        unsubscribePromise.resolve(.success([URL(string: "https://example.com")!]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [URL(string: "https://example.com")!]
                    }
                }

                describe("when the call fails") {
                    beforeEach {
                        unsubscribePromise.resolve(.failure(.unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("fetching the list of subscribed feeds") {
            var receivedFuture: Future<Result<[URL], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.subscribedFeeds()
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var promise: Promise<Result<[URL], SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    promise = Promise<Result<[URL], SinopeError>>()
                    feedService.subscribedFeedsReturns(promise.future)

                    receivedFuture = subject.subscribedFeeds()
                }

                it("makes a request to the feed service for all subscribed feeds") {
                    expect(feedService.subscribedFeedsCallCount) == 1

                    guard feedService.subscribedFeedsCallCount == 1 else { return }
                    let args = feedService.subscribedFeedsArgsForCall(0)

                    expect(args) == loginToken
                }

                it("returns the exact same future when we try to fetch the list of subscribed feeds while still waiting for a result") {
                    expect(subject.subscribedFeeds()).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        promise.resolve(.success([URL(string: "https://example.com")!]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [URL(string: "https://example.com")!]
                    }
                }

                describe("when the call fails") {
                    beforeEach {
                        promise.resolve(.failure(.unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("checking if a url is a feed") {
            var receivedFuture: Future<Result<CheckResult, SinopeError>>!
            var checkPromise: Promise<Result<CheckResult, SinopeError>>!

            let url = URL(string: "https://example.org")!

            sharedExamples("checking if a url is a feed") {
                beforeEach {
                    // make the request
                    checkPromise = Promise<Result<CheckResult, SinopeError>>()
                    feedService.checkReturns(checkPromise.future)

                    receivedFuture = subject.check(url)
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedService.checkCallCount) == 1

                    guard feedService.checkCallCount == 1 else { return }

                    let args = feedService.checkArgsForCall(0)

                    expect(args) == url
                }

                it("returns the exact same future when we try to fetch again") {
                    feedService.checkReturns(Promise<Result<CheckResult, SinopeError>>().future)

                    expect(subject.check(url)).to(beIdenticalTo(receivedFuture))
                    expect(feedService.checkCallCount) == 1

                    expect(subject.check(URL(string: "https://example.com")!)).toNot(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        checkPromise.resolve(.success(.feed(url)))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == .feed(url)
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        checkPromise.resolve(.failure(.unknown))
                    }

                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }

            describe("when not logged in") {
                itBehavesLike("checking if a url is a feed")
            }

            describe("when logged in") {
                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success("blah"))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")
                }

                itBehavesLike("checking if a url is a feed")
            }
        }

        describe("fetching data") {
            var receivedFuture: Future<Result<[Feed], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.fetch([:])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var fetchPromise: Promise<Result<[Feed], SinopeError>>!
                let url = URL(string: "https://example.com")!
                let date = Date()

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    fetchPromise = Promise<Result<[Feed], SinopeError>>()
                    feedService.fetchReturns(fetchPromise.future)

                    receivedFuture = subject.fetch([url: date])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedService.fetchCallCount) == 1
                    let args = feedService.fetchArgsForCall(0)

                    expect(args.0) == loginToken
                    expect(args.1) == [url: date]
                }

                it("returns the exact same future when we try to fetch again") {
                    expect(subject.fetch([url: date])).to(beIdenticalTo(receivedFuture))

                    expect(subject.fetch([:])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        fetchPromise.resolve(.success([]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == []
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        fetchPromise.resolve(.failure(.unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }

        describe("marking articles as read") {
            var receivedFuture: Future<Result<Void, SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.markRead(articles: [:])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.notLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var markReadPromise: Promise<Result<Void, SinopeError>>!
                let url1 = URL(string: "https://example.com/1")!
                let url2 = URL(string: "https://example.com/2")!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    _ = subject.login("foo", password: "bar")

                    markReadPromise = Promise<Result<Void, SinopeError>>()
                    articleService.markReadReturns(markReadPromise.future)

                    receivedFuture = subject.markRead(articles: [url1: true, url2: false])
                }

                it("makes a request to the article service to mark those articles as (un)read") {
                    expect(articleService.markReadCallCount) == 1
                    guard articleService.markReadCallCount == 1 else { return }

                    let args = articleService.markReadArgsForCall(0)

                    expect(args.0) == [url1: true, url2: false]
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to mark those same articles as read again") {
                    expect(subject.markRead(articles: [url1: true, url2: false])).to(beIdenticalTo(receivedFuture))
                    expect(subject.markRead(articles: [url2: false, url1: true])).to(beIdenticalTo(receivedFuture))

                    expect(subject.markRead(articles: [url1: false, url2: true])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        markReadPromise.resolve(.success())
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        markReadPromise.resolve(.failure(.unknown))
                    }

                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.unknown
                    }
                }
            }
        }
    }
}
