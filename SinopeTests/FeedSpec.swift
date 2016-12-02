import Quick
import Nimble
import Sinope
import Freddy

class FeedSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"

            let validFixtureStringNoArticles = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": 0," +
                "\"articles\": []}"
            let validFixtureNoArticles: Data = validFixtureStringNoArticles.data(using: String.Encoding.utf8)!

            let validFixtureString = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": false," +
                "\"articles\": [" +
                "{\"title\": \"Example 1\", \"url\": \"https://example.com/1/\", \"summary\": \"test\", \"published\": \"2015-12-23T00:00:00.000Z\", \"updated\": null, \"content\": null, \"authors\": []}" +
                "]}"
            let validFixture: Data = validFixtureString.data(using: String.Encoding.utf8)!

            let validFixtureStringNoArticlesNoImageUrl = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": 1," +
                "\"image_url\": null, \"articles\": []}"
            let validFixtureNoArticlesNoImageUrl: Data = validFixtureStringNoArticlesNoImageUrl.data(using: String.Encoding.utf8)!

            let validFixtureStringNoArticlesNoSummary = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": null," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": true," +
                "\"image_url\": \"https://example.com/image.png\", \"articles\": []}"
            let validFixtureNoArticlesNoSummary: Data = validFixtureStringNoArticlesNoSummary.data(using: String.Encoding.utf8)!

            let invalidFixtureStringNoUrl = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": null," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": false," +
                "\"image_url\": null, \"articles\": []}"
            let invalidFixtureNoUrl: Data = invalidFixtureStringNoUrl.data(using: String.Encoding.utf8)!

            let invalidFixtureStringEmptyUrl = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": false," +
                "\"image_url\": null, \"articles\": []}"
            let invalidFixtureEmptyUrl: Data = invalidFixtureStringEmptyUrl.data(using: String.Encoding.utf8)!

            let invalidFixtureStringNoTitle = "{\"title\": null," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": false," +
                "\"image_url\": null, \"articles\": []}"
            let invalidFixtureNoTitle: Data = invalidFixtureStringNoTitle.data(using: String.Encoding.utf8)!

            let invalidFixtureStringEmptyTitle = "{\"title\": \"\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": false," +
                "\"image_url\": null, \"articles\": []}"
            let invalidFixtureEmptyTitle: Data = invalidFixtureStringEmptyTitle.data(using: String.Encoding.utf8)!

            let invalidFixtureStringEmptyLastUpdated = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"\"," +
                "\"read\": false," +
                "\"articles\": []}"
            let invalidFixtureEmptyLastUpdated: Data = invalidFixtureStringEmptyLastUpdated.data(using: String.Encoding.utf8)!

            let invalidFixtureStringNoLastUpdated = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"read\": false," +
                "\"articles\": []}"
            let invalidFixtureNoLastUpdated: Data = invalidFixtureStringNoLastUpdated.data(using: String.Encoding.utf8)!

            let invalidFixtureStringEmptyRead = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"read\": null," +
                "\"articles\": []}"
            let invalidFixtureEmptyRead: Data = invalidFixtureStringEmptyRead.data(using: .utf8)!

            let validFixtureStringNoRead = "{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"articles\": []}"
            let validFixtureNoRead: Data = validFixtureStringNoRead.data(using: .utf8)!

            it("can be init'd from json") {
                let json = try! JSON(data: validFixtureNoArticles)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == URL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl) == URL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.read) == false
                    expect(subject.articles).to(beEmpty())
                }
            }

            it("can be init'd from json with articles") {
                let json = try! JSON(data: validFixture)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == URL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl) == URL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.read) == false
                    expect(subject.articles).to(haveCount(1))
                    if let article = subject.articles.first {
                        expect(article.title) == "Example 1"
                        expect(article.url) == URL(string: "https://example.com/1/")
                        expect(article.summary) == "test"
                        expect(article.content) == ""
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"
                        let publishedDate = dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                        expect(article.published) == publishedDate
                        expect(article.updated).to(beNil())
                        expect(article.authors).to(beEmpty())
                    }
                }
            }

            it("doesn't throw if image_url is empty") {
                let json = try! JSON(data: validFixtureNoArticlesNoImageUrl)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == URL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl).to(beNil())
                    expect(subject.lastUpdated) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.read) == true
                    expect(subject.articles).to(beEmpty())
                }
            }

            it("doesn't throw if summary is empty") {
                let json = try! JSON(data: validFixtureNoArticlesNoSummary)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == URL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == ""
                    expect(subject.imageUrl) == URL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.read) == true
                    expect(subject.articles).to(beEmpty())
                }
            }

            it("throws if title is nil") {
                let json = try! JSON(data: invalidFixtureNoTitle)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if title is empty") {
                let json = try! JSON(data: invalidFixtureEmptyTitle)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if url is nil") {
                let json = try! JSON(data: invalidFixtureNoUrl)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if url is empty") {
                let json = try! JSON(data: invalidFixtureEmptyUrl)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if last_updated is nil") {
                let json = try! JSON(data: invalidFixtureNoLastUpdated)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if last_updated is empty") {
                let json = try! JSON(data: invalidFixtureEmptyLastUpdated)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("throws if read is empty") {
                let json = try! JSON(data: invalidFixtureEmptyRead)

                let subject = try? Feed(json: json)
                expect(subject).to(beNil())
            }

            it("doesn't throw if read doesn't exist as a key") {
                let json = try! JSON(data: validFixtureNoRead)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == URL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl) == URL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.date(from: "2015-12-23T00:00:00.000Z")
                    expect(subject.read) == false
                    expect(subject.articles).to(beEmpty())
                }
            }
        }
    }
}
