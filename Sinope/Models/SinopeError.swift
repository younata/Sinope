public enum SinopeError: Error {
    case network
    case json
    case notLoggedIn
    case unknown

    var localizedDescription: String {
        switch self {
        case .network:
            return NSLocalizedString("Error_Network", comment: "")
        case .json:
            return NSLocalizedString("Error_JSON", comment: "")
        case .notLoggedIn:
            return NSLocalizedString("Error_NotLoggedIn", comment: "")
        case .unknown:
            return NSLocalizedString("Error_Unknown", comment: "")
        }
    }
}
