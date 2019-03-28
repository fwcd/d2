struct MDBModule {
	var code: String? = nil
	var url: String? = nil
	var person: String? = nil
	var nameGerman: String? = nil
	var nameEnglish: String? = nil
	var ects: UInt? = nil
	var workload: String? = nil
	var teachingLanguage: String? = nil
	var summary: String? = nil
	var objectives: String? = nil
	var contents: String? = nil
	var prerequisites: String? = nil
	var exam: String? = nil
	var methods: String? = nil
	var literature: String? = nil
	var references: String? = nil
	var comment: String? = nil
	var studyPrograms = [MDBStudyProgram]()
	var categories = [MDBCategory]()
	var presence: String? = nil
	var cycle: String? = nil
	var duration: UInt? = nil
}
