import Foundation
import Swinub
import Testing

@Suite
struct NonFrozenEnumTests {
    private enum Sample: String, Codable, Sendable {
        case foo
        case snakeCase = "snake_case"
    }

    private struct Wrapper: Codable, Sendable {
        let value: NonFrozenEnum<Sample>
    }

    @Test func decodesSnakeCase() throws {
        let json = #"{"value":"snake_case"}"#
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(Wrapper.self, from: data)
        let isSnakeCase: Bool
        if case .value(.snakeCase) = decoded.value {
            isSnakeCase = true
        } else {
            isSnakeCase = false
        }
        #expect(isSnakeCase)
    }

    @Test func decodesUnknownCase() throws {
        let json = #"{"value":"bar"}"#
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(Wrapper.self, from: data)
        let isBarUnknown: Bool
        if case .unknown("bar") = decoded.value {
            isBarUnknown = true
        } else {
            isBarUnknown = false
        }
        #expect(isBarUnknown)
    }

    @Test func encodesSnakeCase() throws {
        let wrapper = Wrapper(value: .value(.snakeCase))
        let data = try JSONEncoder().encode(wrapper)
        let json = String(decoding: data, as: UTF8.self)
        #expect(json == #"{"value":"snake_case"}"#)
    }

    @Test func encodesUnknownCase() throws {
        let wrapper = Wrapper(value: .unknown("bar"))
        let data = try JSONEncoder().encode(wrapper)
        let json = String(decoding: data, as: UTF8.self)
        #expect(json == #"{"value":"bar"}"#)
    }
}
