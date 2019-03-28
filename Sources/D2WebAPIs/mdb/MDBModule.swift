public struct MDBModule {
	public var code: String? = nil
	public var url: String? = nil
	public var person: String? = nil
	public var nameGerman: String? = nil
	public var nameEnglish: String? = nil
	public var ects: UInt? = nil
	public var workload: String? = nil
	public var teachingLanguage: String? = nil
	public var summary: String? = nil
	public var objectives: String? = nil
	public var contents: String? = nil
	public var prerequisites: String? = nil
	public var exam: String? = nil
	public var methods: String? = nil
	public var literature: String? = nil
	public var references: String? = nil
	public var comment: String? = nil
	public var studyPrograms = [MDBStudyProgram]()
	public var categories = [MDBCategory]()
	public var presence: String? = nil
	public var cycle: String? = nil
	public var duration: UInt? = nil
}
