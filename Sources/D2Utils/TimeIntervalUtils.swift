import Foundation

extension TimeInterval {
    public var asMinutes: Double { self / 60 }
    public var asHours: Double { self / 3600 }
    public var asDays: Double { self / 86400 }

    public var displayString: String {
        if Int(asDays) > 0 {
            return String(format: "%.2f days", asDays)
        } else if Int(asHours) > 0 {
            return String(format: "%.2f hours", asHours)
        } else if Int(asMinutes) > 0 {
            return String(format: "%.2f minutes", asMinutes)
        } else {
            return String(format: "%.2f seconds", self)
        }
    }
}