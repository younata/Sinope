import Freddy

public struct Author: JSONDecodable, Equatable {
    public let name: String
    public let email: URL?

    public init(json: JSON) throws {
        self.name = try json.getString(at: "name")
        if self.name.isEmpty {
            throw JSON.Error.keyNotFound(key: "name")
        }
        let emailString = try? json.getString(at: "email")
        if let emailString = emailString, let email = URL(string: emailString) {
            self.email = email
        } else {
            self.email = nil
        }
    }
}

public func == (lhs: Author, rhs: Author) -> Bool {
    return lhs.name == rhs.name && lhs.email == rhs.email
}
