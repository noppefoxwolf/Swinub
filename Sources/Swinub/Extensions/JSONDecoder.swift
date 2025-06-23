import Foundation

extension JSONDecoder.DateDecodingStrategy {
    public static var millisecondsISO8601: Self {
        .custom { decoder -> Date in
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            
            guard let date = iso8601Formatter.date(from: value) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(value)"
                )
            }
            return date
        }
    }
}
