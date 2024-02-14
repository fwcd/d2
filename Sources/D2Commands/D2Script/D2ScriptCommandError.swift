enum D2ScriptCommandError: Error {
    case noCommandDefined(String)
    case multipleCommandsDefined(String)
}
