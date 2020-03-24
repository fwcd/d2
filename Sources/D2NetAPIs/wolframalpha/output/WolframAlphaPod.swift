public struct WolframAlphaPod {
	public var title: String? = nil
	public var scanner: String? = nil
	public var id: String? = nil
	public var position: Int? = nil
	public var error: Bool? = nil
	public var numsubpods: Int? = nil
	public var subpods: [WolframAlphaSubpod] = []
	public var states: [WolframAlphaState] = []
	public var infos: [WolframAlphaInfo] = []
}
