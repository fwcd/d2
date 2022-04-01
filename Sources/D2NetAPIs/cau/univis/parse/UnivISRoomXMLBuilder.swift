class UnivISRoomXMLBuilder: UnivISObjectNodeXMLBuilder {
    private var room: UnivISRoom! = nil

    private var parsingRef = false
    private var nameStack = [String]()

    // TODO: Parse orgunits

    func enter(selfWithName elementName: String, attributes: [String: String]) throws {
        guard let key = attributes["key"] else { throw NetApiError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
        room = UnivISRoom(key: key)
    }

    func enter(childWithName elementName: String, attributes: [String: String]) throws {
        let previousName = nameStack.last
        nameStack.append(elementName)

        if parsingRef {
            if elementName == "UnivISRef" {
                guard let key = attributes["key"] else { throw NetApiError.xmlError("Missing 'key' attribute in \(elementName) node", attributes) }
                switch previousName {
                    case "contact": room.contacts.append(UnivISRef(key: key))
                    default: break
                }
            }
        } else {
            switch elementName {
                case "contact": parsingRef = true
                default: break
            }
        }
    }

    func characters(_ characters: String) throws {
        let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)

        if let name = nameStack.last {
            switch name {
                case "address": room.address = str
                case "chtab": room.chtab = parse(univISBool: str)
                case "description": room.description = str
                case "id": room.id = UInt(str)
                case "inet": room.inet = parse(univISBool: str)
                case "beam": room.beam = parse(univISBool: str)
                case "dark": room.dark = parse(univISBool: str)
                case "lose": room.lose = parse(univISBool: str)
                case "ohead": room.ohead = parse(univISBool: str)
                case "wlan": room.wlan = parse(univISBool: str)
                case "tafel": room.tafel = parse(univISBool: str)
                case "laptopton": room.laptopton = parse(univISBool: str)
                case "fest": room.fest = parse(univISBool: str)
                case "tel": room.tel = str
                case "name": room.name = str
                case "orgname": room.orgname = str
                case "rolli": room.rolli = parse(univISBool: str)
                case "short": room.short = str
                case "size": room.size = Int(str)
                case "wb": room.wb = parse(univISBool: str)
                default: break
            }
        }
    }

    func exit(childWithName elementName: String) throws {
        if parsingRef {
            if elementName == "contact" {
                parsingRef = false
            }
        }

        _ = nameStack.removeLast()
    }

    func exit(selfWithName elementName: String) throws {}

    func build() -> any UnivISObjectNode {
        return room
    }
}
