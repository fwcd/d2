enum CampusCommandError: Error {
    case noRoomFound
    case roomHasNoAddress(String)
}
