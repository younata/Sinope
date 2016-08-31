import Quick
import Nimble
import Sinope
import Freddy

class FeedSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"

            let validFixtureNoArticles: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validFixture: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": \"https://example.com/image.png\"," +
                "\"last_updated\": \"2015-12-23T00:00:00.000Z\"," +
                "\"articles\": [" +
                "{\"title\": \"Example 1\", \"url\": \"https://example.com/1/\", \"summary\": \"test\", \"published\": \"2015-12-23T00:00:00.000Z\", \"updated\": null, \"content\": null, \"authors\": []}" +
                "]}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validFixtureNoArticlesNoImageUrlNoLastUpdated: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": null, \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validFixtureNoArticlesNoSummaryNoLastUpdated: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": null," +
                "\"image_url\": \"https://example.com/image.png\", \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidFixtureNoUrl: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": null," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": null, \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidFixtureEmptyUrl: NSData = ("{\"title\": \"Rachel Brindle\"," +
                "\"url\": \"\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": null, \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidFixtureNoTitle: NSData = ("{\"title\": null," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": null, \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidFixtureEmptyTitle: NSData = ("{\"title\": \"\"," +
                "\"url\": \"https://younata.github.io/feed.xml\"," +
                "\"summary\": \"OSX, iOS and Robotics developer\"," +
                "\"image_url\": null, \"articles\": []}").dataUsingEncoding(NSUTF8StringEncoding)!

            it("can be init'd from json") {
                let json = try! JSON(data: validFixtureNoArticles)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == NSURL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl) == NSURL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.articles).to(beEmpty())
                }
            }

            it("can be init'd from json with articles") {
                let json = try! JSON(data: validFixture)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == NSURL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl) == NSURL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated) == dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                    expect(subject.articles).to(haveCount(1))
                    if let article = subject.articles.first {
                        expect(article.title) == "Example 1"
                        expect(article.url) == NSURL(string: "https://example.com/1/")
                        expect(article.summary) == "test"
                        expect(article.content) == ""
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSzzz"
                        let publishedDate = dateFormatter.dateFromString("2015-12-23T00:00:00.000Z")
                        expect(article.published) == publishedDate
                        expect(article.updated).to(beNil())
                        expect(article.authors).to(beEmpty())
                    }
                }
            }

            it("doesn't throw if image_url is empty") {
                let json = try! JSON(data: validFixtureNoArticlesNoImageUrlNoLastUpdated)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == NSURL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == "OSX, iOS and Robotics developer"
                    expect(subject.imageUrl).to(beNil())
                    expect(subject.lastUpdated).to(beNil())
                    expect(subject.articles).to(beEmpty())
                }
            }

            it("doesn't throw if summary is empty") {
                let json = try! JSON(data: validFixtureNoArticlesNoSummaryNoLastUpdated)

                let subject = try? Feed(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.title) == "Rachel Brindle"
                    expect(subject.url) == NSURL(string: "https://younata.github.io/feed.xml")!
                    expect(subject.summary) == ""
                    expect(subject.imageUrl) == NSURL(string: "https://example.com/image.png")!
                    expect(subject.lastUpdated).to(beNil())
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
        }
    }
}
