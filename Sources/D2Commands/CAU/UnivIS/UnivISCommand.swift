import Logging
import RegexBuilder
import D2MessageIO
import D2Permissions
import Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.UnivISCommand")

fileprivate let rawKeyPattern = #/(?:\w+)/#
fileprivate let rawValuePattern = #/(?:\w+|(?:"[\w ]+"))/#

// Matches the arguments of the command. The first group captures the
// search parameter, the second group the (raw) key-value parameters.
fileprivate let inputPattern = Regex {
    Capture {
        #/\w+/#
    }
    Capture {
        OneOrMore {
            #/\s+/#
            rawKeyPattern
            #/\s*=\s*/#
            rawValuePattern
        }
    }
}

// Matches a single key-value argument. The first group captures the
// key, the second (or third) group captures the value.
fileprivate let kvArgPattern = #/(?<key>\w+)\s*=\s*(?:(?:"(?<quotedValue>.+?)")|(?<value>\S+))/#

// TODO: Use the new Arg API for this

public class UnivISCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Queries the UnivIS",
        longDescription: "Queries the lecture database 'UnivIS' from the CAU",
        helpText: """
            Syntax: `[search key] [searchparameter=value]*`

            For example: `lectures name=qcomp`
            """,
        presented: true,
        requiredPermissionLevel: .basic
    )
    let maxResponseEntries: Int

    public init(maxResponseEntries: Int = 15) {
        self.maxResponseEntries = maxResponseEntries
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let parsedArgs = try? inputPattern.firstMatch(in: input) else {
                await output.append(errorText: "Syntax error: Your arguments need to match `[searchkey] [searchparameter=value]*`")
                return
            }
            guard let searchKey = UnivISSearchKey(rawValue: String(parsedArgs.1)) else {
                await output.append(errorText: "Unrecognized search key `\(parsedArgs.1)`. Try one of:\n```\n\(UnivISSearchKey.allCases.map { $0.rawValue })\n```")
                return
            }

            let queryParams = try queryParameterDict(of: input.matches(of: kvArgPattern).map { (key: $0.key, value: $0.quotedValue ?? $0.value ?? "") })

            do {
                let result = try await UnivISQuery(search: searchKey, params: queryParams).start()
                let responseGroups = Dictionary(grouping: result.childs, by: { $0.nodeType })
                let embed = Embed(
                    title: "UnivIS query result",
                    fields: Array(responseGroups
                        .map { Embed.Field(name: $0.key, value: $0.value.map { $0.shortDescription }.joined(separator: "\n")) }
                        .prefix(self.maxResponseEntries))
                )

                await output.append(embed)
            } catch {
                await output.append(error, errorText: "UnivIS query error.")
            }
        } catch UnivISCommandError.invalidSearchParameter(let paramName) {
            await output.append(errorText: "Invalid search parameter `\(paramName)`. Try one of:\n```\n\(UnivISSearchParameter.allCases.map { $0.rawValue })\n```")
        } catch {
            await output.append(error)
        }
    }

    private func queryParameterDict(of parsedKVArgs: [(key: Substring, value: Substring)]) throws -> [UnivISSearchParameter: String] {
        var dict = [UnivISSearchParameter: String]()

        for (key, value) in parsedKVArgs {
            if let searchParameter = UnivISSearchParameter(rawValue: String(key)) {
                dict[searchParameter] = String(value)
            } else {
                throw UnivISCommandError.invalidSearchParameter(String(key))
            }
        }

        return dict
    }
}
