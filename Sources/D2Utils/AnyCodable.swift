import Foundation

// Source: https://gist.github.com/harrytwright/6cadb8e19c12525a7bf2b844baaeaa8a
//         https://medium.com/@harrywright_57770/the-pain-of-codable-de736e69e9ff

fileprivate protocol AnyCodableBox {
    var base: AnyHashable { get }
}

fileprivate struct ConcreteCodableBox<Base: Codable & Hashable>: AnyCodableBox {
    var baseCodable: Base
    var base: AnyHashable { AnyHashable(baseCodable) }

    init(_ base: Base) {
        self.baseCodable = base
    }
}

public struct AnyCodable: Codable, Hashable, CustomStringConvertible {
    private var box: AnyCodableBox
    public var description: String { "\(box.base)" }

    public init<Base: Codable & Hashable>(_ base: Base) {
        box = ConcreteCodableBox<Base>(base)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            box = ConcreteCodableBox<Int>(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            box = ConcreteCodableBox<Double>(doubleValue)
        } else if let floatValue = try? container.decode(Float.self) {
            box = ConcreteCodableBox<Float>(floatValue)
        } else if let stringValue = try? container.decode(String.self) {
            box = ConcreteCodableBox<String>(stringValue)
        } else if let dictionaryValue = try? container.decode([String:AnyCodable].self) {
            box = ConcreteCodableBox<[String: AnyCodable]>(dictionaryValue)
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            box = ConcreteCodableBox<[AnyCodable]>(arrayValue)
        } else {
            throw DecodingError.typeMismatch(
                type(of: self),
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        // Safe to use `as!` becasue the `base` is just `baseCodable`
        try (box.base.base as! Codable).encode(to: encoder)
    }

    public func hash(into hasher: inout Hasher) {
        box.base.hash(into: &hasher)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.box.base == rhs.box.base
    }

    public func base<T>(as: T.Type) -> T {
        box.base.base as! T
    }
}
