import Quick
import Nimble
import Sinope
import Freddy

class ArticleSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"

            let validString = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": [{\"name\": \"Moritz Walter\", \"email\": null}]}"
            let valid: Data = validString.data(using: String.Encoding.utf8)!

            let validStringNoAuthors = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let validNoAuthors: Data = validStringNoAuthors.data(using: String.Encoding.utf8)!

            let validStringNoUpdated = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": null," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let validNoUpdated: Data = validStringNoUpdated.data(using: String.Encoding.utf8)!

            let validStringNoContent = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": null," +
                "\"authors\": []}"
            let validNoContent: Data = validStringNoContent.data(using: String.Encoding.utf8)!

            let validStringNoSummary = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": null," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let validNoSummary: Data = validStringNoSummary.data(using: String.Encoding.utf8)!

            let invalidStringNoTitle = "{\"title\": null," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidNoTitle: Data = invalidStringNoTitle.data(using: String.Encoding.utf8)!

            let invalidStringEmptyTitle = "{\"title\": \"\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidEmptyTitle: Data = invalidStringEmptyTitle.data(using: String.Encoding.utf8)!

            let invalidStringNoPublished = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": null," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidNoPublished: Data = invalidStringNoPublished.data(using: String.Encoding.utf8)!

            let invalidStringEmptyPublished = "{\"title\": \"Example 1\"," +
                " \"url\": \"https://example.com/1/\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidEmptyPublished: Data = invalidStringEmptyPublished.data(using: String.Encoding.utf8)!

            let invalidStringNoUrl = "{\"title\": \"Example 1\"," +
                " \"url\": null," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidNoUrl: Data = invalidStringNoUrl.data(using: String.Encoding.utf8)!

            let invalidStringEmptyUrl = "{\"title\": \"Example 1\"," +
                " \"url\": \"\"," +
                "\"summary\": \"test summary\"," +
                "\"published\": \"2015-12-23T00:00:00.000Z\"," +
                "\"updated\": \"2015-12-25T00:00:00.000Z\"," +
                "\"content\": \"test content\"," +
                "\"authors\": []}"
            let invalidEmptyUrl: Data = invalidStringEmptyUrl.data(using: String.Encoding.utf8)!

            it("can be init'd from json") {
                let json = try! JSON(data: validNoAuthors)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == URL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.date(from: "2015-12-25T00:00:00.000Z")
                    expect(subject.content) == "test content"
                    expect(subject.authors).to(beEmpty())
                }
            }

            it("can be init'd from json with authors") {
                let json = try! JSON(data: valid)

                let subject = try? Article(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Example 1"
                    expect(subject.url) == URL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.date(from: "2015-12-25T00:00:00.000Z")
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
                    expect(subject.url) == URL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
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
                    expect(subject.url) == URL(string: "https://example.com/1/")
                    expect(subject.summary) == "test summary"
                    expect(subject.published) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.date(from: "2015-12-25T00:00:00.000Z")
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
                    expect(subject.url) == URL(string: "https://example.com/1/")
                    expect(subject.summary) == ""
                    expect(subject.published) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.updated) == dateFormatter.date(from: "2015-12-25T00:00:00.000Z")
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
