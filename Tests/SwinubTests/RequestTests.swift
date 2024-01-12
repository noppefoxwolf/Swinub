import XCTest
import HTTPTypes
@testable import Swinub

class RequestTests: XCTestCase {
    func testConvertURL() async throws {
        struct MockRequest: Request {
            struct Response: Codable {}
            
            var method: HTTPTypes.HTTPRequest.Method = .get
            
            var authority: String = "pokemon.mastportal.info/"
            
            var path: String = "/api/v1/timelines/home"
        }
        
        _ = try MockRequest().url
    }
    
    func testURLComponentIssue() async throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pokemon.mastportal.info/"
        XCTAssertNil(urlComponents.url)
    }
}
