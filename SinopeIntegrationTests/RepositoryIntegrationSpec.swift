import Quick
import Nimble
import Result
import Sinope
import CBGPromise

class RepositoryIntegrationSpec: QuickSpec {
    override func spec() {
        var subject: Repository!

        var authToken: String? = nil

        beforeEach {
            subject = DefaultRepository(
                URL(string: "http://localhost:3000")!,
                networkClient: URLSession.shared,
                appToken: "test")
        }

        describe("a standard interaction") {
            var createAccountResponse: Result<Void, SinopeError>?
            beforeEach {
                if let authToken = authToken {
                    subject.login(authToken)
                } else {
                    createAccountResponse = subject.createAccount("user@example.com", password: "testere").wait()
                    authToken = subject.authToken
                }
            }

            it("can create an account for the user to use") {
                expect(createAccountResponse?.error).to(beNil())
                expect(createAccountResponse?.value).toNot(beNil())
            }

            describe("subscribing to feeds") {
                var feedsResponse: Result<[URL], SinopeError>?
                let urls = [
                    URL(string: "http://younata.github.io/feed.xml")!
                ]

                beforeEach {
                    feedsResponse = subject.subscribe(urls).wait()
                }

                it("it can subscribe to feeds") {
                    expect(feedsResponse?.error).to(beNil())
                    expect(feedsResponse?.value) == urls
                }

                describe("fetching feeds") {
                    var fetchResponse: Result<[Feed], SinopeError>?

                    beforeEach {
                        let updated = [
                            URL(string: "http://younata.github.io/feed.xml")!: Date(timeIntervalSinceNow: -10)
                        ]
                        fetchResponse = subject.fetch(updated).wait()
                    }

                    it("returns a last fetched date after the above 'then' variables") {
                        expect(fetchResponse?.error).to(beNil())
                    }

                    it("returns Rachel's blog") {
                        expect(fetchResponse?.error).to(beNil())
                        expect(fetchResponse?.value).to(haveCount(1))

                        if let feed = fetchResponse?.value?.first {
                            expect(feed.url) == URL(string: "http://younata.github.io/feed.xml")
                        }
                    }
                }
            }
        }
    }
}
