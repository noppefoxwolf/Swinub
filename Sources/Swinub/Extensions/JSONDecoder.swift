import Foundation

extension JSONDecoder.DateDecodingStrategy {
    public static var millisecondsISO8601: Self {
        .custom { decoder -> Date in
            let valueContainer = try decoder.singleValueContainer()
            let value = try valueContainer.decode(String.self)
            if let regex = try? NSRegularExpression(pattern: "\\.\\d+", options: []) {
                let result = regex.stringByReplacingMatches(
                    in: value,
                    options: [],
                    range: NSRange(location: 0, length: value.count),
                    withTemplate: ""
                )
                if let date = ISO8601DateFormatter().date(from: result) {
                    return date
                }
            }
            let context = DecodingError.Context(
                codingPath: valueContainer.codingPath,
                debugDescription: "Invalid date"
            )
            throw DecodingError.dataCorrupted(context)
        }
    }
}
