import Foundation
import Utils

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct StableDiffusionQuery {
    private let input: StableDiffusionInput

    // TODO: Obtain API key for production D2 and add stable diffusion support using https://replicate.com/stability-ai/stable-diffusion/versions/f178fa7a1ae43a9a9af01b833b9d2ecf97b1bcb0acfd2dc5dd04895e042863f1/api#run
}
