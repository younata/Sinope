import Quick
import Nimble
import Sinope

class CheckResultSpec: QuickSpec {
    override func spec() {
        describe("equality") {
            it("returns true for two .feed CheckResults with the same URL") {
                expect(CheckResult.feed(URL(string: "https://example.com")!)) == CheckResult.feed(URL(string: "https://example.com")!)
            }

            it("returns false for two .feed CheckResults with different URLs") {
                expect(CheckResult.feed(URL(string: "https://example.com")!)) != CheckResult.feed(URL(string: "https://example.org")!)
            }

            it("returns true for two .opml CheckResults with the same URL array") {
                let a = CheckResult.opml([
                    URL(string: "https://example.com")!,
                    URL(string: "https://example.org")!,
                ])
                let b = CheckResult.opml([
                    URL(string: "https://example.com")!,
                    URL(string: "https://example.org")!,
                ])

                expect(a) == b
            }

            it("returns false for two .opml CheckResults with different URL arrays") {
                let a = CheckResult.opml([
                    URL(string: "https://example.com")!,
                    URL(string: "https://example.org")!,
                ])
                let b = CheckResult.opml([
                    URL(string: "https://example.net")!,
                    URL(string: "https://example.org")!,
                ])

                expect(a) != b
            }

            it("returns false for a .feed CheckResult and a .opml CheckResult") {
                let a = CheckResult.feed(URL(string: "https://example.com")!)
                let b = CheckResult.opml([
                    URL(string: "https://example.net")!,
                    URL(string: "https://example.org")!,
                ])

                expect(a) != b
                expect(b) != a
            }

            it("returns false for a .feed CheckResult and a .none CheckResult") {
                let a = CheckResult.feed(URL(string: "https://example.com")!)

                expect(a) != CheckResult.none
                expect(CheckResult.none) != a
            }

            it("returns false for a .opml CheckResult and a .none CheckResult") {
                let a = CheckResult.opml([
                    URL(string: "https://example.net")!,
                    URL(string: "https://example.org")!,
                ])

                expect(a) != CheckResult.none
                expect(CheckResult.none) != a
            }

            it("returns true for two .none CheckResults") {
                expect(CheckResult.none) == CheckResult.none
            }
        }
    }
}
