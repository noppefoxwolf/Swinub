import Foundation
import Testing

@Suite
struct FedibirdPropertyTests {
    @Test func _1() throws {
        let server1Json = """
            {"id" : "1"}
            """
        let server2Json = """
            {"id" : "1", "extra": {"name": "name"}}
            """
        let server3Json = """
            {"id" : "1", "extra": {"id": "id"}}
            """
        let decoder = JSONDecoder()
        let decoded1 = try decoder.decode(JSON.self, from: Data(server1Json.utf8))
        #expect(decoded1.id == "1")
        #expect(decoded1.extra == nil)
        let decoded2 = try decoder.decode(JSON.self, from: Data(server2Json.utf8))
        #expect(decoded2.id == "1")
        #expect(decoded2.extra != nil)
        let decoded3 = try decoder.decode(JSON.self, from: Data(server3Json.utf8))
        #expect(decoded3.id == "1")
        #expect(decoded3.extra == nil)
    }

    @Test func _2() throws {

        let json = """
            {
                "capabilities" : [
                    "emoji",
                    "unknown",
                ]
            }
            """
        struct Object: Codable {
            let capabilities: [Capability]?
        }
        let object = try JSONDecoder().decode(Object.self, from: Data(json.utf8))
        #expect(object.capabilities!.count == 1)
    }

    @Test func _3() throws {

        let json = """
            {
            }
            """
        struct Object: Codable {
            let capabilities: [Capability]?
        }
        let object = try JSONDecoder().decode(Object.self, from: Data(json.utf8))
        #expect(object.capabilities == nil)
    }
}

enum Capability: String, Codable {
    case emoji
}

extension KeyedDecodingContainer {
    func decodeIfPresent(_ type: [Capability].Type, forKey key: Key) throws -> [Capability]? {
        guard contains(key) else { return nil }
        let capabilities = try decode([String].self, forKey: key)
        return capabilities.compactMap(Capability.init(rawValue:))
    }
}

struct JSON: Codable {
    struct Extra: Codable, Equatable {
        let name: String
    }

    let id: String

    let extra: Extra?

    //    init(from decoder: Decoder) throws {
    //        let container = try decoder.container(keyedBy: JSON.CodingKeys.self)
    //        self.id = try container.decode(String.self, forKey: .id)
    //        self.extra = try? container.decodeIfPresent(Extra.self, forKey: .extra)
    //    }
}

extension KeyedDecodingContainer {
    // override decoder
    func decodeIfPresent(_ type: JSON.Extra.Type, forKey key: Key) throws -> JSON.Extra? {
        try? self.decode(type, forKey: key)
    }
}
