import Foundation

class DateFormatter {
    static let sharedFormatter: Foundation.DateFormatter = {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
