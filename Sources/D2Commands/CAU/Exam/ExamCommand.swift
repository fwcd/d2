import D2MessageIO
import D2NetAPIs
import Utils

public class ExamCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches details about CS exams at the CAU",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) async {
        do {
            let exams = try await CAUCSExamsQuery().perform()
            if !input.isEmpty {
                if let exam = bestMatch(for: input, in: exams) {
                    output.append(embed(of: exam))
                } else {
                    output.append(errorText: "Could not find a matching exam")
                }
            } else {
                output.append(embed(of: exams))
            }
        } catch {
            output.append(error, errorText: "Could not query CAU CS exams")
        }
    }

    private func bestMatch(for query: String, in exams: [Exam]) -> Exam? {
        exams.first { $0.module?.code == query }
            ?? exams.first { $0.module?.name == query }
            ?? exams.min(by: ascendingComparator {
                [$0.module?.name, $0.module?.code]
                    .compactMap { $0 }
                    .map { $0.lcsDistance(to: query, caseSensitive: false) }
                    .min()
                    ?? .max
            })
    }

    private func embed(of exam: Exam) -> Embed {
        Embed(
            title: title(of: exam),
            fields: [
                ("Docent", exam.docent),
                ("Date", exam.date),
                ("Location", exam.location),
            ].compactMap { (k, v) in v.map { Embed.Field(name: k, value: $0) } }
        )
    }

    private func embed(of exams: [Exam]) -> Embed {
        Embed(
            title: "\(exams.count) \("exam".pluralized(with: exams.count))",
            fields: exams.map { exam in
                Embed.Field(
                    name: title(of: exam),
                    value: [exam.date, exam.location].compactMap { $0 }.joined(separator: ", ")
                )
            }
        )
    }

    private func title(of exam: Exam) -> String {
        exam.module.map { [$0.code, $0.name].compactMap { $0 }.joined(separator: " - ") } ?? "Unknown exam"
    }
}
