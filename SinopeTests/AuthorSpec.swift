import Quick
import Nimble
import Sinope
import Freddy

class AuthorSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let valid: Data = ("{\"name\": \"Rachel Brindle\"," +
                "\"email\": \"mailto:rachel@example.com\"}").data(using: String.Encoding.utf8)!

            let validNoEmail: Data = ("{\"name\": \"Rachel Brindle\"," +
                "\"email\": null}").data(using: String.Encoding.utf8)!

            let invalidNoName: Data = ("{\"name\": null," +
                "\"email\": \"rachel@example.com\"}").data(using: String.Encoding.utf8)!

            let invalidEmptyName: Data = ("{\"name\": \"\"," +
                "\"email\": \"rachel@example.com\"}").data(using: String.Encoding.utf8)!

            it("can be init'd from json") {
                let json = try! JSON(data: valid)

                let subject = try? Author(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.name) == "Rachel Brindle"
                    expect(subject.email) == URL(string: "mailto:rachel@example.com")
                }
            }

            it("doesn't throw if email is empty") {
                let json = try! JSON(data: validNoEmail)

                let subject = try? Author(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.name) == "Rachel Brindle"
                    expect(subject.email).to(beNil())
                }
            }

            it("throws if name is nil") {
                let json = try! JSON(data: invalidNoName)

                let subject = try? Author(json: json)
                expect(subject).to(beNil())
            }
            
            it("throws if name is empty") {
                let json = try! JSON(data: invalidEmptyName)
                
                let subject = try? Author(json: json)
                expect(subject).to(beNil())
            }
        }
    }
}
