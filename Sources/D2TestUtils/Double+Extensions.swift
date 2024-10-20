public extension Double {
    func isApproximatelyEqual(to other: Self, accuracy: Double = 0.0001) -> Bool {
        abs(self - other) < accuracy
    }
}
