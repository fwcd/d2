/**
 * Represents a one-dimensional (bijective) distortion
 * function that is to be applied in every direction.
 */
public protocol RadialDistortion {
    init()

    /**
    * Inversely applies this distortion, fetching
    * the normalized distance-from-center in the source image
    * given a normalized distance-from-center in the destination
    * image.
    */
    func sourceDist(from normalizedDestDist: Double, percent: Double) -> Double
}
