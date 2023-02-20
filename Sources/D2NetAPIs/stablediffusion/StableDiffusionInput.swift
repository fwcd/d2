public struct StableDiffusionInput: Codable {
    public enum CodingKeys: String, CodingKey {
        case prompt
        case negativePrompt = "negative_prompt"
        case width
        case height
        case promptStrength = "prompt_strength"
        case numOutputs = "num_outputs"
        case numInferenceSteps = "num_inference_steps"
        case guidanceScale = "guidance_scale"
        case scheduler
        case seed
    }

    /// Input prompt
    public var prompt: String
    /// Specify things to not see in the output
    public var negativePrompt: String? = nil
    /// Width of output image. Maximum size is 1024x768 or 768x1024 because of memory limits
    public var width: Int = 768
    /// Height of output image. Maximum size is 1024x768 or 768x1024 because of memory limits
    public var height: Int = 768
    /// Prompt strength when using init image. 1.0 corresponds to full destruction of information in init image
    public var promptStrength: Double = 0.8
    /// Number of images to output. (minimum: 1; maximum: 4)
    public var numOutputs: Int = 1
    /// Number of denoising steps (minimum: 1; maximum: 500)
    public var numInferenceSteps: Int = 50
    /// Scale for classifier-free guidance (minimum: 1; maximum: 20)
    public var guidanceScale: Double = 7.5
    /// Choose a scheduler.
    public var scheduler: Scheduler = .kEuler
    /// Random seed. Leave blank to randomize the seed
    public var seed: String? = nil

    public struct Scheduler: RawRepresentable, Codable {
        public static let ddim = Self(rawValue: "DDIM")
        public static let kEuler = Self(rawValue: "K_EULER")
        public static let dpmSolverMultistep = Self(rawValue: "DPMSolverMultistep")
        public static let kEulerAncestral = Self(rawValue: "K_EULER_ANCESTRAL")
        public static let pndm = Self(rawValue: "PNDM")
        public static let klms = Self(rawValue: "KLMS")

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
