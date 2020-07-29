public protocol SearchTree {
    associatedtype Element: Comparable

    @discardableResult
    func insert(_ element: Element) -> Bool

    @discardableResult
    func remove(_ element: Element) -> Bool

    func contains(_ element: Element) -> Bool
}
