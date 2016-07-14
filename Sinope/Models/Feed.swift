import Freddy

public struct Feed: JSONDecodable, Equatable {
    public let title: String
    public let url: NSURL
    public let summary: String
    public let imageUrl: NSURL?
    public private(set) var articles: [Article]

    init(title: String, url: NSURL, summary: String, imageUrl: NSURL?, articles: [Article]) {
        self.title = title
        self.url = url
        self.summary = summary
        self.imageUrl = imageUrl
        self.articles = articles
    }

    public init(json: JSON) throws {
        self.title = try json.string("title")
        if self.title.isEmpty {
            throw JSON.Error.KeyNotFound(key: "title")
        }
        let urlString = try json.string("url")
        if !urlString.isEmpty, let url = NSURL(string: urlString) {
            self.url = url
        } else {
            throw JSON.Error.KeyNotFound(key: "url")
        }
        self.summary = (try? json.string("summary")) ?? ""
        let imageUrlString = (try? json.string("image_url")) ?? ""
        if !imageUrlString.isEmpty, let imageUrl = NSURL(string: imageUrlString) {
            self.imageUrl = imageUrl
        } else {
            self.imageUrl = nil
        }
        self.articles = ((try? json.array("articles")) ?? []).flatMap { try? Article(json: $0) }
    }
}

public func == (lhs: Feed, rhs: Feed) -> Bool {
    return lhs.title == rhs.title && lhs.url == rhs.url &&
        lhs.summary == rhs.summary && lhs.imageUrl == rhs.imageUrl &&
        lhs.articles == rhs.articles
}