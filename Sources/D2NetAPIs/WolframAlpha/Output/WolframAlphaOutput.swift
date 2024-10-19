public struct WolframAlphaOutput: Sendable {
    public var success: Bool? = nil
    public var error: Bool? = nil
    public var numpods: Int? = nil
    public var datatypes: String? = nil
    public var timing: Double? = nil
    public var pods: [WolframAlphaPod] = []
}
