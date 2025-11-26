import Foundation
import Testing

@testable import Swinub

@Suite
struct DecodeArrayOrValueTests {
    private struct Sample: Decodable, Equatable {
        let values: [Int]

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            values = try container.decodeArrayOrValue(Int.self, forKey: .values)
        }

        enum CodingKeys: String, CodingKey {
            case values
        }
    }

    @Test func decodesArrayWhenArrayProvided() throws {
        let json = """
            {
                "values": [1, 2, 3]
            }
            """
        let decoded = try JSONDecoder().decode(Sample.self, from: Data(json.utf8))
        #expect(decoded.values == [1, 2, 3])
    }

    @Test func wrapsSingleValueIntoArray() throws {
        let json = """
            {
                "values": 1
            }
            """
        let decoded = try JSONDecoder().decode(Sample.self, from: Data(json.utf8))
        #expect(decoded.values == [1])
    }
}
