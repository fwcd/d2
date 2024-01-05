import D2MessageIO
import D2NetAPIs

public class ExamCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches details about CS exams at the CAU",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        CAUCSExamsQuery().perform().listen {
            do {
                let exams = try $0.get()
                output.append(self.embed(of: exams))
            } catch {
                output.append(error, errorText: "Could not query CAU CS exams")
            }
        }
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
