public protocol Startable {
    /**
     * Starts something implementation-specific.
     * Should not block.
     */
    func start() throws
}
