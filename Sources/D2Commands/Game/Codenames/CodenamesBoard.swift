import Utils
import Logging

private let log = Logger(label: "D2Commands.CodenamesBoard")

public struct CodenamesBoard: RichValueConvertible, Sendable {
    public var model = CodenamesBoardModel()
    public var asRichValue: RichValue {
        do {
            return try .image(CodenamesBoardView(model: model).image)
        } catch {
            log.warning("Could not create CodenamesBoardView: \(error)")
            return .none
        }
    }
}
