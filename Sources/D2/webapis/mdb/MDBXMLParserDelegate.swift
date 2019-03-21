import Foundation

class MDBXMLParserDelegate: XMLParserDelegate {
	let then: (Result<[MDBModule]>) -> Void
	
	var modules = [MDBModule]()
	
	var parsingName = false
	var parsingStudyPrograms = false
	var parsingCategories = false
	
	var currentKey: String? = nil
	var currentModule: MDBModule? = nil
	var currentCharacters = ""
	
	init(then: @escaping (Result<[MDBModule]>) -> Void) {
		self.then = then
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		switch elementName {
			case "modul": currentModule = MDBModule()
			case "modulname": parsingName = true
			case "studiengaenge": parsingStudyPrograms = true
			case "kategorien": parsingCategories = true
			case "kategorie": currentKey = attributeDict["key"]
			case "studiengang": currentKey = attributeDict["key"]
			default: break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentCharacters += string
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		let str = characters.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if let module = currentModule {
			if parsingName {
				switch elementName {
					case "modulname": parsingName = false
					case "deutsch": module.nameGerman = str
					case "englisch": module.nameEnglish = str
					default: break
				}
			} else if parsingStudyPrograms {
				switch elementName {
					case "studiengaenge": parsingStudyPrograms = false
					case "studiengang": module.studyPrograms.append(MDBStudyProgram(key: currentKey, name: str))
					default: break
				}
			} else if parsingCategories {
				switch elementName {
					case "kategorien": parsingCategories = false
					case "kategorie": module.categories.append(MDBCategory(key: currentKey, name: str))
					default: break
				}
			} else {
				switch elementName {
					case "code": module.code = str
					case "modulcode": module.code = str
					case "url": module.url = str
					case "verantwortlich": module.person = str
					case "ectspunkte": module.ects = UInt(str)
					case "workload": module.workload = str
					case "lehrsprache": module.teachingLanguage = str
					case "kurzfassung": module.summary = str
					case "lernziele": module.objectives = str
					case "lehrinhalte": module.contents = str
					case "voraussetzungen": module.prerequisites = str
					case "pruefungsleistung": module.exam = str
					case "lehrmethoden": module.methods = str
					case "literatur": module.literature = str
					case "verweise": module.references = str
					case "kommentar": module.comment = str
					case "praesenz": module.presence = str
					case "dauer": module.duration = UInt(str)
					case "turnus": module.cycle = str
					default: break
				}
			}
		} else {
			switch elementName {
				case "modul":
					modules.append(currentModule)
					currentModule = nil
				default: break
			}
		}
		currentCharacters = ""
	}
}
