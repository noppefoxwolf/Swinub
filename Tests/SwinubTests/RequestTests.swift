import XCTest
import HTTPTypes
@testable import Swinub

class RequestTests: XCTestCase {
    func testConvertURL() async throws {
        struct MockRequest: HTTPEndpointRequest, Sendable {
            struct Response: Codable {}
            
            var method: HTTPRequest.Method = .get
            
            var authority: String = "pokemon.mastportal.info/"
            
            var path: String = "/api/v1/timelines/home"
        }
        
        _ = try MockRequest().url
    }
    
    func testURLComponentIssue() async throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pokemon.mastportal.info/"
        if #available(iOS 17, macOS 14, *) {
            XCTAssertNil(urlComponents.url)
        } else {
            XCTAssertEqual(urlComponents.url, URL(string: "https:")!)
        }
    }
}
