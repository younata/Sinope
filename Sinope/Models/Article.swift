import Foundation
import Freddy

public struct Article: JSONDecodable, Equatable {
    public let title: String
    public let url: URL
    public let summary: String
    public let content: String
    public let published: Date
    public let updated: Date?
    public private(set) var authors: [Author]

    public init(json: JSON) throws {
        self.title = try json.getString(at: "title")
        if self.title.isEmpty {
            throw JSON.Error.keyNotFound(key: "titl")
        }
        let urlString = try json.getString(at: "url")
        if !urlString.isEmpty, let url = URL(string: urlString) {
            self.url = url
        } else {
            throw JSON.Error.keyNotFound(key: "url")
        }
        self.summary = (try? json.getString(at: "summary")) ?? ""
        self.content = (try? json.getString(at: "content")) ?? ""

        let dateFormatter = DateFormatter.sharedFormatter
        let publishedString = (try? json.getString(at: "published")) ?? ""
        if let published = dateFormatter.date(from: publishedString) {
            self.published = published
        } else {
            throw JSON.Error.keyNotFound(key: "published")
        }

        self.updated = dateFormatter.date(from: (try? json.getString(at: "updated")) ?? "")
        self.authors = ((try? json.getArray(at: "authors")) ?? []).flatMap { try? Author(json: $0) }

    }
}

public func == (lhs: Article, rhs: Article) -> Bool {
    return lhs.title == rhs.title && lhs.url == rhs.url &&
        lhs.summary == rhs.summary && lhs.content == rhs.content &&
        lhs.published == rhs.published && lhs.updated == rhs.updated &&
        lhs.authors == rhs.authors
}
