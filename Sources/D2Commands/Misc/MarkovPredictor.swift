/// A Markov chain from which sequences can
/// be stochastically generated.
public protocol MarkovPredictor {
    associatedtype Element

    var markovOrder: Int { get }

    func predict(_ state: [Element]) -> Element?
}
