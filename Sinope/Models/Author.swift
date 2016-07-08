import Freddy

public struct Author: JSONDecodable {
    public let name: String
    public let email: NSURL?

    public init(json: JSON) throws {
        self.name = try json.string("name")
        if self.name.isEmpty {
            throw JSON.Error.KeyNotFound(key: "name")
        }
        let emailString = try? json.string("email")
        if let emailString = emailString, email = NSURL(string: emailString) {
            self.email = email
        } else {
            self.email = nil
        }
    }
}