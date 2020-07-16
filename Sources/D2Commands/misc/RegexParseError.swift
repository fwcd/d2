enum RegexParseError: Error {
    case missingParenthesis(String)
    case invalidCharacterSet
    case missingChoiceBranch(String)
}

