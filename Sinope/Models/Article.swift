import Freddy

public struct Article: JSONDecodable {
    public let title: String
    public let url: NSURL
    public let summary: String
    public let content: String
    public let published: NSDate
    public let updated: NSDate?
    public private(set) var authors: [Author]

    public init(json: JSON) throws {
        self.title = try json.string("title")
        if self.title.isEmpty {
            throw JSON.Error.KeyNotFound(key: "titl")
        }
        let urlString = try json.string("url")
        if !urlString.isEmpty, let url = NSURL(string: urlString) {
            self.url = url
        } else {
            throw JSON.Error.KeyNotFound(key: "url")
        }
        self.summary = (try? json.string("summary")) ?? ""
        self.content = (try? json.string("content")) ?? ""

        let dateFormatter = DateFormatter.sharedFormatter
        let publishedString = (try? json.string("published")) ?? ""
        if let published = dateFormatter.dateFromString(publishedString) {
            self.published = published
        } else {
            throw JSON.Error.KeyNotFound(key: "published")
        }

        self.updated = dateFormatter.dateFromString((try? json.string("updated")) ?? "")
        self.authors = ((try? json.array("authors")) ?? []).flatMap { try? Author(json: $0) }

    }
}