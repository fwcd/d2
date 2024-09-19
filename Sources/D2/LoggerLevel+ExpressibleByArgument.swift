import ArgumentParser
import Logging

extension Logger.Level: ArgumentParser.ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}
