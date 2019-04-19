public struct WolframAlphaPod {
	var title: String? = nil
	var scanner: String? = nil
	var id: String? = nil
	var position: Int? = nil
	var error: Bool? = nil
	var numsubpods: Int? = nil
	var subpods: [WolframAlphaSubpod] = []
	var states: [WolframAlphaState] = []
	var infos: [WolframAlphaInfo] = []
}
