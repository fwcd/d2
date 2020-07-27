// Type-level representation of integers that let
// you statically parameterize a type with a constant.
//
// Other languages, like C++ or Rust, have first-class
// support for this feature under the name 'const generics'
// offering support for parameterization of types over
// compile-time constants.
//
// If you are curious, there is an even more powerful variant
// of this feature called 'dependent types' that let
// you not just parameterize over constants but also
// over variables whose value may first be known at
// runtime.

public protocol ConstInt {
    static var value: Int { get }
}

public struct Zero: ConstInt { public static var value: Int { 0 } }
public struct One: ConstInt { public static var value: Int { 1 } }
public struct Two: ConstInt { public static var value: Int { 2 } }
public struct Three: ConstInt { public static var value: Int { 3 } }
public struct Four: ConstInt { public static var value: Int { 4 } }
public struct Five: ConstInt { public static var value: Int { 5 } }
public struct Ten: ConstInt { public static var value: Int { 10 } }
public struct Twenty: ConstInt { public static var value: Int { 20 } }
public struct Thirty: ConstInt { public static var value: Int { 30 } }
public struct Fourty: ConstInt { public static var value: Int { 40 } }
public struct Fifty: ConstInt { public static var value: Int { 50 } }
public struct Hundred: ConstInt { public static var value: Int { 100 } }
