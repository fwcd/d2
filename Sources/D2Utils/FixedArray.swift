/// A workaround that provides a stack-allocated,
/// fixed size array up to length 10 and falls back
/// to dynamically allocation for longer arrays.
public enum FixedArray<T> {
    case len0
    case len1(T)
    case len2(T, T)
    case len3(T, T, T)
    case len4(T, T, T, T)
    case len5(T, T, T, T, T)
    case len6(T, T, T, T, T, T)
    case len7(T, T, T, T, T, T, T)
    case len8(T, T, T, T, T, T, T, T)
    case len9(T, T, T, T, T, T, T, T, T)
    case len10(T, T, T, T, T, T, T, T, T, T)
    case lenDyn([T])
    
    public var isEmpty: Bool { return count == 0 }
    
    public var count: Int {
        switch self {
            case .len0: return 0
            case .len1(_): return 1
            case .len2(_, _): return 2
            case .len3(_, _, _): return 3
            case .len4(_, _, _, _): return 4
            case .len5(_, _, _, _, _): return 5
            case .len6(_, _, _, _, _, _): return 6
            case .len7(_, _, _, _, _, _, _): return 7
            case .len8(_, _, _, _, _, _, _, _): return 8
            case .len9(_, _, _, _, _, _, _, _, _): return 9
            case .len10(_, _, _, _, _, _, _, _, _, _): return 10
            case .lenDyn(let a): return a.count
        }
    }
    
    public func withAppended(_ value: T) -> FixedArray<T> {
        switch self {
            case .len0: return .len1(value)
            case let .len1(a): return .len2(a, value)
            case let .len2(a, b): return .len3(a, b, value)
            case let .len3(a, b, c): return .len4(a, b, c, value)
            case let .len4(a, b, c, d): return .len5(a, b, c, d, value)
            case let .len5(a, b, c, d, e): return .len6(a, b, c, d, e, value)
            case let .len6(a, b, c, d, e, f): return .len7(a, b, c, d, e, f, value)
            case let .len7(a, b, c, d, e, f, g): return .len8(a, b, c, d, e, f, g, value)
            case let .len8(a, b, c, d, e, f, g, h): return .len9(a, b, c, d, e, f, g, h, value)
            case let .len9(a, b, c, d, e, f, g, h, i): return .len10(a, b, c, d, e, f, g, h, i, value)
            case let .len10(a, b, c, d, e, f, g, h, i, j): return .lenDyn([a, b, c, d, e, f, g, h, i, j, value])
            case let .lenDyn(a): return .lenDyn(a + [value])
        }
    }
    
    public subscript(_ n: Int) -> T {
        switch self {
            case .len0: fatalError("Cannot subscript an empty array")
            case let .len1(a): switch n {
                case 0: return a
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len2(a, b): switch n {
                case 0: return a
                case 1: return b
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len3(a, b, c): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len4(a, b, c, d): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len5(a, b, c, d, e): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len6(a, b, c, d, e, f): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                case 5: return f
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len7(a, b, c, d, e, f, g): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                case 5: return f
                case 6: return g
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len8(a, b, c, d, e, f, g, h): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                case 5: return f
                case 6: return g
                case 7: return h
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len9(a, b, c, d, e, f, g, h, i): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                case 5: return f
                case 6: return g
                case 7: return h
                case 8: return i
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .len10(a, b, c, d, e, f, g, h, i, j): switch n {
                case 0: return a
                case 1: return b
                case 2: return c
                case 3: return d
                case 4: return e
                case 5: return f
                case 6: return g
                case 7: return h
                case 8: return i
                case 9: return j
                default: fatalError("Index \(n) is out of bounds")
            }
            case let .lenDyn(a): return a[n]
        }
    }
}
