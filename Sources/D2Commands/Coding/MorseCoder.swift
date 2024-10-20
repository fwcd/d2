import Utils

private let morseTable: BiDictionary<String, String> = [
    "A": ".-",
    "B": "-...",
    "C": "-.-.",
    "D": "-..",
    "E": ".",
    "F": "..-.",
    "G": "--.",
    "H": "....",
    "I": "..",
    "J": ".---",
    "K": "-.-",
    "L": ".-..",
    "M": "--",
    "N": "-.",
    "O": "---",
    "P": ".--.",
    "Q": "--.-",
    "R": ".-.",
    "S": "...",
    "T": "-",
    "U": "..-",
    "V": "...-",
    "W": ".--",
    "X": "-..-",
    "Y": "-.--",
    "Z": "--..",
    "1": ".----",
    "2": "..---",
    "3": "...--",
    "4": "....-",
    "5": ".....",
    "6": "-....",
    "7": "--...",
    "8": "---..",
    "9": "----.",
    "0": "-----",
    "Ä": ".-.-",
    "Ö": "---.",
    "Ü": "..--",
    ",": "..-..",
    ".": ".-.-.-",
    "?": "..--..",
    ";": "-.-.-",
    ":": "---...",
    "/": "-..-.",
    "+": ".-.-.",
    "-": "-....-",
    "=": "-...-"
]

private let wordSeparator = "   "
private let charSeparator = " "

func morseEncode(_ s: String) -> String {
    s.split(separator: " ")
        .map { $0.map { morseTable[$0.uppercased()] ?? String($0) }.joined(separator: charSeparator) }
        .joined(separator: wordSeparator)
}

func morseDecode(_ s: String) -> String {
    s.components(separatedBy: wordSeparator)
        .map { $0.split(separator: " ").map(String.init).map { morseTable[value: $0] ?? $0 }.joined().lowercased() }
        .joined(separator: " ")
}
