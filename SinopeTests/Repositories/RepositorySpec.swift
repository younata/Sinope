import Quick
import Nimble
import Sinope
import Result
import CBGPromise

class RepositorySpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeRepository!
        var userService: FakeUserService!
        var feedsService: FakeFeedsService!

        beforeEach {
            userService = FakeUserService()
            feedsService = FakeFeedsService()
            subject = PasiphaeRepository(userService: userService, feedsService: feedsService)
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
                    promise.resolve(.Success("test"))
                }

                it("resolves the received future") {
                    expect(receivedFuture.value).toNot(beNil())
                    expect(receivedFuture.value?.value).toNot(beNil())
                }
            }

            describe("when the user service fails") {
                beforeEach {
                    promise.resolve(.Failure(.Network))
                }

                it("returns with the same error") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.Network))
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
                    promise.resolve(.Success("test"))
                }

                it("resolves the received future") {
                    expect(receivedFuture.value).toNot(beNil())
                    expect(receivedFuture.value?.value).toNot(beNil())
                }
            }

            describe("when the user service fails") {
                beforeEach {
                    promise.resolve(.Failure(.Network))
                }

                it("returns with the same error") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.Network))
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
                    expect(receivedFuture.value?.error).to(equal(SinopeError.NotLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var addDevicePromise: Promise<Result<Void, SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")

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
                        addDevicePromise.resolve(.Success())
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        addDevicePromise.resolve(.Failure(.Unknown))
                    }

                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
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
                    expect(receivedFuture.value?.error).to(equal(SinopeError.NotLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var deletePromise: Promise<Result<Void, SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")

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
                        deletePromise.resolve(.Success())
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value).toNot(beNil())
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        deletePromise.resolve(.Failure(.Unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
                    }
                }
            }
        }

        describe("subscribing to a set of feeds") {
            var receivedFuture: Future<Result<[NSURL], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.subscribe([NSURL(string: "https://example.com")!])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.NotLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var subscribePromise: Promise<Result<[NSURL], SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")

                    subscribePromise = Promise<Result<[NSURL], SinopeError>>()
                    feedsService.subscribeReturns(subscribePromise.future)

                    receivedFuture = subject.subscribe([NSURL(string: "https://example.com")!])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedsService.subscribeCallCount) == 1
                    let args = feedsService.subscribeArgsForCall(0)

                    expect(args.0) == [NSURL(string: "https://example.com")!]
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to subscribe to the same feeds while still waiting for a result") {
                    expect(subject.subscribe([NSURL(string: "https://example.com")!])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        subscribePromise.resolve(.Success([NSURL(string: "https://example.com")!]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [NSURL(string: "https://example.com")!]
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        subscribePromise.resolve(.Failure(.Unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
                    }
                }
            }
        }

        describe("unsubscribing from a set of feeds") {
            var receivedFuture: Future<Result<[NSURL], SinopeError>>!

            describe("when not logged in") {
                beforeEach {
                    receivedFuture = subject.unsubscribe([NSURL(string: "https://example.com")!])
                }

                it("returns a resolved promise with error .NotLoggedIn") {
                    expect(receivedFuture.value?.error).to(equal(SinopeError.NotLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var unsubscribePromise: Promise<Result<[NSURL], SinopeError>>!

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")

                    unsubscribePromise = Promise<Result<[NSURL], SinopeError>>()
                    feedsService.unsubscribeReturns(unsubscribePromise.future)

                    receivedFuture = subject.unsubscribe([NSURL(string: "https://example.com")!])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedsService.unsubscribeCallCount) == 1
                    let args = feedsService.unsubscribeArgsForCall(0)

                    expect(args.0) == [NSURL(string: "https://example.com")!]
                    expect(args.1) == loginToken
                }

                it("returns the exact same future when we try to unsubscribe from the same feeds while still waiting for a result") {
                    expect(subject.unsubscribe([NSURL(string: "https://example.com")!])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        unsubscribePromise.resolve(.Success([NSURL(string: "https://example.com")!]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [NSURL(string: "https://example.com")!]
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        unsubscribePromise.resolve(.Failure(.Unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
                    }
                }
            }
        }

        describe("checking if a url is a feed") {
            var receivedFuture: Future<Result<[NSURL: Bool], SinopeError>>!
            var checkPromise: Promise<Result<[NSURL: Bool], SinopeError>>!

            let url = NSURL(string: "https://example.org")!

            sharedExamples("checking if a url is a feed") {
                beforeEach {
                    // make the request
                    checkPromise = Promise<Result<[NSURL: Bool], SinopeError>>()
                    feedsService.checkReturns(checkPromise.future)

                    receivedFuture = subject.check(url)
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedsService.checkCallCount) == 1

                    guard feedsService.checkCallCount == 1 else { return }

                    let args = feedsService.checkArgsForCall(0)

                    expect(args) == url
                }

                it("returns the exact same future when we try to fetch again") {
                    feedsService.checkReturns(Promise<Result<[NSURL: Bool], SinopeError>>().future)

                    expect(subject.check(url)).to(beIdenticalTo(receivedFuture))
                    expect(feedsService.checkCallCount) == 1

                    expect(subject.check(NSURL(string: "https://example.com")!)).toNot(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        checkPromise.resolve(.Success([url: true]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == [url: true]
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        checkPromise.resolve(.Failure(.Unknown))
                    }

                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
                    }
                }
            }

            describe("when not logged in") {
                itBehavesLike("checking if a url is a feed")
            }

            describe("when logged in") {
                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success("blah"))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")
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
                    expect(receivedFuture.value?.error).to(equal(SinopeError.NotLoggedIn))
                }
            }

            describe("when logged in") {
                let loginToken = "login_token"
                var fetchPromise: Promise<Result<[Feed], SinopeError>>!
                let url = NSURL(string: "https://example.com")!
                let date = NSDate()

                beforeEach {
                    let loginPromise = Promise<Result<String, SinopeError>>()
                    loginPromise.resolve(.Success(loginToken))
                    userService.loginReturns(loginPromise.future)

                    subject.login("foo", password: "bar")

                    fetchPromise = Promise<Result<[Feed], SinopeError>>()
                    feedsService.fetchReturns(fetchPromise.future)

                    receivedFuture = subject.fetch([url: date])
                }

                it("makes a request to the user service to add the device token") {
                    expect(feedsService.fetchCallCount) == 1
                    let args = feedsService.fetchArgsForCall(0)

                    expect(args.0) == loginToken
                    expect(args.1) == [url: date]
                }

                it("returns the exact same future when we try to fetch again") {
                    expect(subject.fetch([url: date])).to(beIdenticalTo(receivedFuture))

                    expect(subject.fetch([:])).to(beIdenticalTo(receivedFuture))
                }

                describe("when the call succeeds") {
                    beforeEach {
                        fetchPromise.resolve(.Success([]))
                    }

                    it("resolves the promise") {
                        expect(receivedFuture.value).toNot(beNil())
                        expect(receivedFuture.value?.value) == []
                    }
                }

                describe("when tha call fails") {
                    beforeEach {
                        fetchPromise.resolve(.Failure(.Unknown))
                    }
                    
                    it("forwards the error") {
                        expect(receivedFuture.value?.error) == SinopeError.Unknown
                    }
                }
            }
        }
    }
}
