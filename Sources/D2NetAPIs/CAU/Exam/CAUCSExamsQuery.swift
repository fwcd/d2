import Foundation
import Utils

public struct CAUCSExamsQuery {
    private let url: URL

    // TODO: Use URL macro here (and elsewhere) after Swift 5.9 migration
    public init(url: URL = .init(string: "https://www.informatik.uni-kiel.de/~ab/termine.html")!) {
        self.url = url
    }

    public func perform() async throws -> [Exam] {
        let document = try await HTTPRequest(url: url).fetchHTML()

        guard let table = try document.getElementsByTag("table")[safely: 1] else {
            throw NetApiError.documentError("Could not find table")
        }

        let rows = try table.getElementsByTag("tr").map { try $0.getElementsByTag("td").map { try $0.text() } }

        guard let headerRow = rows.first else {
            throw NetApiError.documentError("Could not find headers")
        }
        guard headerRow.count == Set(headerRow).count else {
            throw NetApiError.documentError("Document contains duplicate headers")
        }

        let valueRows = rows.dropFirst()
        return valueRows.map { row in
            let values = Dictionary(uniqueKeysWithValues: zip(headerRow, row))
            return Exam(
                module: .init(
                    code: values["Modul"],
                    name: values["Bezeichnung"]
                ),
                docent: values["Dozent"],
                date: values["Termin"],
                location: values["Ort"]
            )
        }
    }
}
