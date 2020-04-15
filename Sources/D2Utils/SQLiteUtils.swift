import SQLite

extension UInt64: Number, Value {
    public static let declaredDatatype = "INTEGER"
    
    public static func fromDatatypeValue(_ datatypeValue: UInt64) -> UInt64 { datatypeValue }
    
    public var datatypeValue: UInt64 { self }
}
