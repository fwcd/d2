public struct WolframAlphaOutput {
	var success: Bool? = nil
	var error: Bool? = nil
	var numpods: Int? = nil
	var datatypes: String? = nil
	var timing: Double? = nil
	var pods: [WolframAlphaPod] = []
}
