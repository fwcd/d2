public struct FoodMenu: Sequence {
    public let meals: [Meal]

    public var isEmpty: Bool { meals.isEmpty }

    public func makeIterator() -> Array<Meal>.Iterator {
        meals.makeIterator()
    }
}
