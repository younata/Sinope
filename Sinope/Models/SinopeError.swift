public enum SinopeError: Error, CustomStringConvertible {
    case network
    case json
    case notLoggedIn
    case unknown

    public var description: String {
        let bundle = Bundle(for: PasiphaeRepository.self)
        switch self {
        case .network:
            return NSLocalizedString("Error_Network", bundle: bundle, comment: "")
        case .json:
            return NSLocalizedString("Error_JSON", bundle: bundle, comment: "")
        case .notLoggedIn:
            return NSLocalizedString("Error_NotLoggedIn", bundle: bundle, comment: "")
        case .unknown:
            return NSLocalizedString("Error_Unknown", bundle: bundle, comment: "")
        }
    }
}
