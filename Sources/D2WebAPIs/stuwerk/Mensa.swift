import D2Utils

fileprivate let rawMensaPattern = "(?:[Mm]ensa\\s*)?"
fileprivate let kielMensaIPattern = try! Regex(from: "\(rawMensaPattern)?[1Ii]")
fileprivate let kielMensaIIPattern = try! Regex(from: "\(rawMensaPattern)?[1Ii]{2}")
fileprivate let kielMensaGaardenPattern = try! Regex(from: "\(rawMensaPattern)?[Gg]aarden")

public enum Mensa: Int, CustomStringConvertible {
    case kielMensaI = 411
    case kielMensaII = 422
    case kielMensaGaarden = 903
    
    public var description: String {
        switch self {
            case .kielMensaI: return "Mensa I"
            case .kielMensaII: return "Mensa II"
            case .kielMensaGaarden: return "Mensa Gaarden"
        }
    }
    
    public static func parse(from raw: String) -> Mensa? {
        if let _ = kielMensaIPattern.firstGroups(in: raw) {
            return .kielMensaI
        } else if let _ = kielMensaIIPattern.firstGroups(in: raw) {
            return .kielMensaII
        } else if let _ = kielMensaGaardenPattern.firstGroups(in: raw) {
            return .kielMensaGaarden
        } else {
            return nil
        }
    }
}
