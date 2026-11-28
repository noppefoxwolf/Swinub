import Foundation

// https://docs.joinmastodon.org/entities/ScheduledStatus/
public struct ScheduledStatus: Codable, Identifiable, Sendable {
    public let id: ID
    public let scheduledAt: Date
    public let params: Params
    public let mediaAttachments: [MediaAttachment]

    public struct ID: Equatable, Hashable, Sendable, Codable, CustomStringConvertible {
        public let rawValue: String
        public var description: String { rawValue }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
}

extension ScheduledStatus {
    public struct Params: Codable, Sendable {
        public let text: String
        public let mediaIds: [MediaAttachment.ID]?
        public let sensitive: Bool?
        public let spoilerText: String?
        public let visibility: StatusVisibility?
        public let language: String?
        public let scheduledAt: Date?
        public let poll: Poll?
        public let idempotency: String?
        public let withRateLimit: Bool?
        public let inReplyToId: Status.ID?
        public let applicationId: Int?
        // API Version 7
        public let quotedStatusId: Status.ID?
        // API Version 7
        public let quoteApprovalPolicy: QuoteApprovalPolicy?

        public struct Poll: Codable, Equatable, Sendable {
            public let options: [String]
            public let expiresIn: Int
            public let multiple: Bool?
            public let hideTotals: Bool?

            public init(
                options: [String],
                expiresIn: Int,
                multiple: Bool? = nil,
                hideTotals: Bool? = nil
            ) {
                self.options = options
                self.expiresIn = expiresIn
                self.multiple = multiple
                self.hideTotals = hideTotals
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.options = try container.decode([String].self, forKey: .options)
                if let intValue = try? container.decode(Int.self, forKey: .expiresIn) {
                    self.expiresIn = intValue
                } else {
                    let stringValue = try container.decode(String.self, forKey: .expiresIn)
                    guard let intValue = Int(stringValue) else {
                        throw DecodingError.dataCorruptedError(
                            forKey: .expiresIn,
                            in: container,
                            debugDescription: "Cannot decode expires_in from \(stringValue)"
                        )
                    }
                    self.expiresIn = intValue
                }
                self.multiple = try container.decodeIfPresent(Bool.self, forKey: .multiple)
                self.hideTotals = try container.decodeIfPresent(Bool.self, forKey: .hideTotals)
            }
        }
    }
}
