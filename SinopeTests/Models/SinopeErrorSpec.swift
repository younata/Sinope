import Quick
import Nimble
import Sinope

class SinopeErrorSpec: QuickSpec {
    override func spec() {
        describe("description") {
            it("network error") {
                expect(SinopeError.network.description) == "Unable to load backend"
            }

            it("json error") {
                expect(SinopeError.json.description) == "Bad Server Response"
            }

            it("not logged in error") {
                expect(SinopeError.notLoggedIn.description) == "Unknown User - Are you logged in?"
            }

            it("unknown error") {
                expect(SinopeError.unknown.description) == "Unknown Error, please try again later"
            }
        }
    }
}
