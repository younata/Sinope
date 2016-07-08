import Quick
import Nimble
import Sinope
import Freddy

class AuthorSpec: QuickSpec {
    override func spec() {
        describe("init'ing from json") {
            let valid: NSData = ("{\"name\": \"Rachel Brindle\"," +
                "\"email\": \"mailto:rachel@example.com\"}").dataUsingEncoding(NSUTF8StringEncoding)!

            let validNoEmail: NSData = ("{\"name\": \"Rachel Brindle\"," +
                "\"email\": null}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidNoName: NSData = ("{\"name\": null," +
                "\"email\": \"rachel@example.com\"}").dataUsingEncoding(NSUTF8StringEncoding)!

            let invalidEmptyName: NSData = ("{\"name\": \"\"," +
                "\"email\": \"rachel@example.com\"}").dataUsingEncoding(NSUTF8StringEncoding)!

            it("can be init'd from json") {
                let json = try! JSON(data: valid)

                let subject = try? Author(json: json)
                expect(subject).toNot(beNil())

                if let subject = subject {
                    expect(subject.name) == "Rachel Brindle"
                    expect(subject.email) == NSURL(string: "mailto:rachel@example.com")
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