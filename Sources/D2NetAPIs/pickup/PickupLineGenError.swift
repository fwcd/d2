import SwiftSoup

public enum PickupLineGenError: Error {
    case missingContent(Document)
}
