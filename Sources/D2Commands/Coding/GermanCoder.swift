import Foundation
import Utils

private let encodedZero = "SCHNITZEL"
private let encodedOne = "BEER"

private func germanEncodeByte(_ byte: UInt8) -> [String] {
    var words = [String]()
    for i in (0..<8).reversed() {
        let bit = ((byte >> i) & 1) == 1
        words.append(bit ? encodedOne : encodedZero)
    }
    return words
}

private func germanDecodeByte(_ words: [String]) -> UInt8 {
    words
        .compactMap { (w: String) -> UInt8? in
            switch w {
                case encodedZero: 0
                case encodedOne: 1
                default: nil
            }
        }
        .enumerated()
        .map { (i, b) in b << (7 - i) }
        .reduce(0, |)
}

func germanEncode(_ data: Data) -> String {
    data.flatMap(germanEncodeByte).joined(separator: " ")
}

func germanDecode(_ s: String) -> Data {
    Data(s.split(separator: " ").map(String.init).chunks(ofLength: 8).map(Array.init).map(germanDecodeByte))
}
