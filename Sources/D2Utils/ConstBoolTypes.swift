// Type-level representation of booleans that let
// you statically parameterize a type with a constant.
//
// See ConstIntTypes for more info.

public protocol ConstBool {
    static var value: Bool { get }
}

public struct True: ConstBool { public static var value: Bool { true } }
public struct False: ConstBool { public static var value: Bool { false } }
