import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.CodenamesBoard")

public struct CodenamesBoard: RichValueConvertible {
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
