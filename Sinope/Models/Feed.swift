import Foundation
import Freddy

public struct Feed: JSONDecodable, Equatable {
    public let title: String
    public let url: URL
    public let summary: String
    public let imageUrl: URL?
    public let lastUpdated: Date
    public let read: Bool
    public fileprivate(set) var articles: [Article]

    init(title: String, url: URL, summary: String, imageUrl: URL?, lastUpdated: Date, read: Bool, articles: [Article]) {
        self.title = title
        self.url = url
        self.summary = summary
        self.imageUrl = imageUrl
        self.lastUpdated = lastUpdated
        self.read = read
        self.articles = articles
    }

    public init(json: JSON) throws {
        self.title = try json.getString(at: "title")
        if self.title.isEmpty {
            throw JSON.Error.keyNotFound(key: "title")
        }
        let urlString = try json.getString(at: "url")
        if !urlString.isEmpty, let url = URL(string: urlString) {
            self.url = url
        } else {
            throw JSON.Error.keyNotFound(key: "url")
        }
        self.summary = (try? json.getString(at: "summary")) ?? ""
        let imageUrlString = (try? json.getString(at: "image_url")) ?? ""
        if !imageUrlString.isEmpty, let imageUrl = URL(string: imageUrlString) {
            self.imageUrl = imageUrl
        } else {
            self.imageUrl = nil
        }
        let lastUpdatedString = (try? json.getString(at: "last_updated")) ?? ""
        if !lastUpdatedString.isEmpty, let lastUpdated = DateFormatter.sharedFormatter.date(from: lastUpdatedString) {
            self.lastUpdated = lastUpdated
        } else {
            throw JSON.Error.keyNotFound(key: "last_updated")
        }

        if let readBool = try? json.getBool(at: "read") {
            self.read = readBool
        } else if let readInt = try? json.getInt(at: "read") {
            self.read = readInt != 0
        } else if json["read"] == nil {
            self.read = false
        } else {
            throw JSON.Error.keyNotFound(key: "read")
        }
        
        self.articles = ((try? json.getArray(at: "articles")) ?? []).flatMap { try? Article(json: $0) }
    }
}

public func == (lhs: Feed, rhs: Feed) -> Bool {
    return lhs.title == rhs.title && lhs.url == rhs.url &&
        lhs.summary == rhs.summary && lhs.imageUrl == rhs.imageUrl &&
        lhs.lastUpdated == rhs.lastUpdated && lhs.articles == rhs.articles
}
