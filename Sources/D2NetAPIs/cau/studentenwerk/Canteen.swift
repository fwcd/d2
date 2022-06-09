import Utils

fileprivate let rawMensaPattern = "(?:[Mm]ensa\\s*)?"
fileprivate let kielMensaIPattern = try! Regex(from: "\(rawMensaPattern)?[1Ii]")
fileprivate let kielMensaIIPattern = try! Regex(from: "\(rawMensaPattern)?(?:2|[Ii]{2})")
fileprivate let kielMensaGaardenPattern = try! Regex(from: "\(rawMensaPattern)?[Gg]aarden")

public enum Canteen: Int, CustomStringConvertible {
    case kielMensaI = 1
    case kielMensaII = 2
    case kielMensaGaarden = 3

    public var name: String {
        switch self {
            case .kielMensaI: return "Mensa I"
            case .kielMensaII: return "Mensa II"
            case .kielMensaGaarden: return "Mensa Gaarden"
        }
    }
    public var description: String { name }

    public static func parse(from raw: String) -> Canteen? {
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
