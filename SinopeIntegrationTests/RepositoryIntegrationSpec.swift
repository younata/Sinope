import Quick
import Nimble
import Result
import Sinope

class RepositoryIntegrationSpec: QuickSpec {
    override func spec() {
        var subject: Repository!

        var authToken: String? = nil

        beforeEach {
            subject = DefaultRepository(
                NSURL(string: "http://localhost:3000")!,
                networkClient: NSURLSession.sharedSession(),
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
                var feedsResponse: Result<[NSURL], SinopeError>?
                let urls = [
                    NSURL(string: "http://younata.github.io/feed.xml")!
                ]

                beforeEach {
                    feedsResponse = subject.subscribe(urls).wait()
                }

                it("it can subscribe to feeds") {
                    expect(feedsResponse?.error).to(beNil())
                    expect(feedsResponse?.value) == urls
                }

                describe("fetching feeds") {
                    var fetchResponse: Result<(NSDate, [Feed]), SinopeError>?

                    beforeEach {
                        fetchResponse = subject.fetch(nil).wait()
                    }

                    it("returns a last fetched date after the above 'then' variables") {
                        expect(fetchResponse?.error).to(beNil())
                    }

                    it("returns Rachel's blog") {
                        expect(fetchResponse?.error).to(beNil())
                        expect(fetchResponse?.value?.1).to(haveCount(1))

                        if let feed = fetchResponse?.value?.1.first {
                            expect(feed.url) == NSURL(string: "http://younata.github.io/feed.xml")
                        }
                    }
                }
            }
        }
    }
}
