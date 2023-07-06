import Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s+(\\S+)\\s+(.+)")

public class InterjectCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Creates a humorous remark based on the GNU/Linux interjection",
        helpText: "Syntax: [first, e.g. GNU] [second, e.g. Linux] [type, e.g. an operating system]",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let first = parsedArgs[1]
        let second = parsedArgs[2]
        let type = parsedArgs[3]

        output.append("""
            I'd just like to interject for a moment. What you're referring to as \(second), is in fact, \(first)/\(second), or as I've recently taken to calling it, \(first) + \(second). \(second) is not \(type), but rather another component of a fully functioning \(first) system made useful by \(first) components.

            Many users run a modified version of the \(first) system every day, without realizing it. Through a peculiar turn of events, the version of \(first) which is widely used today is often called "\(second)", and many of its users are not aware that it is basically the \(first) system, developed by the \(first) project.

            There really is a \(second), and these people are using it, but it is just a part of the system they use. It is an essential part of \(type), but useless by itself; it can only function in the context of \(type). \(second) is normally used in combination with \(first): the whole system is basically \(first) with \(second) added, or \(first)/\(second). All the so-called "\(second)" distributions are really distributions of \(first)/\(second).
            """)
    }
}
