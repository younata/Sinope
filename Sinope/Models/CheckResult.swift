import Foundation

public enum CheckResult {
    case feed(URL)
    case opml([URL])
    case none
}

extension CheckResult: Equatable {}

public func ==(lhs: CheckResult, rhs: CheckResult) -> Bool {
    switch (lhs, rhs) {
    case (let .feed(lhsURL), let .feed(rhsURL)):
        return lhsURL == rhsURL
    case (let .opml(lhsURLs), let .opml(rhsURLs)):
        return lhsURLs == rhsURLs
    case (.none, .none):
        return true
    default:
        return false
    }
}
