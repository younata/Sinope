import Quick
import Nimble
import Sinope
import Freddy

class ArticleSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"

            let valid: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": [{\"name\": \"Moritz Walter\", \"email\": null}]}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validNoAuthors: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validNoUpdated: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": null," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validNoContent: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": null," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validNoSummary: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": null," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidNoTitle: NSData = ("{\"title\": null," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidEmptyTitle: NSData = ("{\"title\": \"\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidNoPublished: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": null," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidEmptyPublished: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidNoUrl: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": null," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidEmptyUrl: NSData = ("{\"title\": \"Example 1\"," +
                " \"url\": \"\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            it("can be init'd from json") {
                let json = try! JSON(data: validNoAuthors)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == NSURL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.dateFromString("2015-12-25T00:00:00.000Z")
                    expect(subject.content) == "test content"
                    expect(subject.authors).to(beEmpty())
                }
            }

            xit("can be init'd from json with authors") {
                let json = try! JSON(data: valid)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == NSURL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.dateFromString("2015-12-25T00:00:00.000Z")
                    expect(subject.content) == "test content"
                    expect(subject.authors).to(haveCount(1))
                    if let author = subject.authors.first {
                        expect(author.name) == "Moritz Walter"
                        expect(author.email).to(beNil())
                    }
                }
            }

            it("doesn't throw if updated is empty") {
                let json = try! JSON(data: validNoUpdated)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == NSURL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.updated).to(beNil())
                    expect(subject.content) == "test content"
                    expect(subject.authors).to(beEmpty())
                }
            }

            it("doesn't throw if content is empty") {
                let json = try! JSON(data: validNoContent)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == NSURL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.dateFromString("2015-12-25T00:00:00.000Z")
                    expect(subject.content) == ""
                    expect(subject.authors).to(beEmpty())
                }
            }

            it("doesn't throw if summary is empty") {
                let json = try! JSON(data: validNoSummary)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == NSURL(string: "https://example.com/1/")
                    expect(subject.summary) == ""
                    expect(subject.published) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.dateFromString("2015-12-25T00:00:00.000Z")
                    expect(subject.content) == "test content"
                    expect(subject.authors).to(beEmpty())
                }
            }

            it("throws if title is null") {
                let json = try! JSON(data: invalidNoTitle)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }

            it("throws if title is empty") {
                let json = try! JSON(data: invalidEmptyTitle)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }

            it("throws if published is null") {
                let json = try! JSON(data: invalidNoPublished)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }

            it("throws if published is empty") {
                let json = try! JSON(data: invalidEmptyPublished)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }

            it("throws if url is null") {
                let json = try! JSON(data: invalidNoUrl)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }

            it("throws if url is empty") {
                let json = try! JSON(data: invalidEmptyUrl)

                let subject = try? Article(json: json)
                expect(subject).to(beNil())
            }
        }
    }
}
