class UnivISPersonXMLBuilder: UnivISObjectNodeXMLBuilder {
    private var person: UnivISPerson! = nil

    private var nameStack = [String]()

    // TODO: Parse orgunits and locations

    func enter(selfWithName elementName: String, attributes: [String: String]) throws {
        guard let key = attributes["key"] else { throw NetApiError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
        person = UnivISPerson(key: key)
    }

    func enter(childWithName elementName: String, attributes: [String: String]) throws {
        nameStack.append(elementName)
    }

    func characters(_ characters: String) throws {
        let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)

        if let name = nameStack.last {
            switch name {
                case "atitle": person.atitle = str
                case "firstname": person.firstname = str
                case "id": person.id = UInt(str)
                case "lastname": person.lastname = str
                case "lehr": person.lehr = parse(univISBool: str)
                case "orgname": person.orgname = str
                case "visible": person.visible = parse(univISBool: str)
                default: break
            }
        }
    }

    func exit(childWithName elementName: String) throws {
        _ = nameStack.removeLast()
    }

    func exit(selfWithName elementName: String) throws {}

    func build() -> UnivISObjectNode {
        return person
    }
}
