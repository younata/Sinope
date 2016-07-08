import Freddy

public struct Feed: JSONDecodable {
    public let title: String
    public let url: NSURL
    public let summary: String
    public let imageUrl: NSURL?

    public private(set) var articles: [Article]

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