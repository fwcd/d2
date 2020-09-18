public enum AnimatedGifError: Error {
    // frameWidth, frameHeight, width, height
    case frameSizeMismatch(Int, Int, Int, Int)

    case noFrameData(Image)
}
