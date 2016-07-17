import Quick
import Nimble
import Sinope
import Result
import CBGPromise

class UserServiceSpec: QuickSpec {
    override func spec() {
        var subject: PasiphaeUserService!
        let baseURL = NSURL(string: "https://example.com/")!
        var networkClient: FakeNetworkClient!

        beforeEach {
            networkClient = FakeNetworkClient()
            subject = PasiphaeUserService(baseURL: baseURL, networkClient: networkClient, appToken: "app_token")
        }

        describe("createAccount") {
            var receivedFuture: Future<Result<String, SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.putStub = { _ in promise.future}

                receivedFuture = subject.createAccount("user@example.com", password: "password")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to login") {
                expect(networkClient.putCallCount) == 1
                let args = networkClient.putArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/user/create")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: NSUTF8StringEncoding)
                expect(body) == "{\"email\":\"user@example.com\",\"password\":\"password\"}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "{\"api_token\": \"foobar\"}".dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with the api token") {
                        expect(receivedFuture.value?.value) == "foobar"
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

        describe("login") {
            var receivedFuture: Future<Result<String, SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.postStub = { _ in promise.future}

                receivedFuture = subject.login("user@example.com", password: "password")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to login") {
                expect(networkClient.postCallCount) == 1
                let args = networkClient.postArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/user/login")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: NSUTF8StringEncoding)
                expect(body) == "{\"email\":\"user@example.com\",\"password\":\"password\"}"
            }

            describe("when the network call succeeds") {
                describe("with a valid json object") {
                    beforeEach {
                        let fixture = "{\"api_token\": \"foobar\"}".dataUsingEncoding(NSUTF8StringEncoding)!
                        promise.resolve(.Success(fixture))
                    }

                    it("resolves the future with the api token") {
                        expect(receivedFuture.value?.value) == "foobar"
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

        describe("addDeviceToken") {
            var receivedFuture: Future<Result<Void, SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.putStub = { _ in promise.future}

                receivedFuture = subject.addDeviceToken("device_token", authToken: "authToken")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to login") {
                expect(networkClient.putCallCount) == 1
                let args = networkClient.putArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/user/add_device_token")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"authToken\"",
                                   "Content-Type": "application/json"]
                let body = String(data: args.2, encoding: NSUTF8StringEncoding)
                expect(body) == "{\"token\":\"device_token\"}"
            }

            describe("when the network call succeeds") {
                beforeEach {
                    promise.resolve(.Success(NSData()))
                }

                it("resolves the future with a success") {
                    expect(receivedFuture.value?.value).toNot(beNil())
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

        describe("deleteAccount") {
            var receivedFuture: Future<Result<Void, SinopeError>>!
            var promise: Promise<Result<NSData, NSError>>!

            beforeEach {
                promise = Promise<Result<NSData, NSError>>()
                networkClient.deleteStub = { _ in promise.future}

                receivedFuture = subject.deleteAccount("authToken")
            }

            it("returns an in-progress future") {
                expect(receivedFuture.value).to(beNil())
            }

            it("makes a request to login") {
                expect(networkClient.deleteCallCount) == 1
                let args = networkClient.deleteArgsForCall(0)
                expect(args.0) == NSURL(string: "https://example.com/api/v1/user/delete")
                expect(args.1) == ["X-APP-TOKEN": "app_token",
                                   "Authorization": "Token token=\"authToken\"",
                                   "Content-Type": "application/json"]
            }

            describe("when the network call succeeds") {
                beforeEach {
                    promise.resolve(.Success(NSData()))
                }

                it("resolves the future with a success") {
                    expect(receivedFuture.value?.value).toNot(beNil())
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
