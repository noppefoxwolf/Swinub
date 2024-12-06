import Testing
import HTTPTypes
@testable import Swinub
import Foundation

@Suite
struct RequestTests {
    @Test func convertURL() async throws {
        struct MockRequest: HTTPEndpointRequest, Sendable {
            struct Response: Codable {}
            
            var method: HTTPRequest.Method = .get
            
            var authority: String = "pokemon.mastportal.info/"
            
            var path: String = "/api/v1/timelines/home"
        }
        
        _ = try MockRequest().url
    }
    
    @Test func uRLComponentIssue() async throws {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "pokemon.mastportal.info/"
        if #available(iOS 17, macOS 14, *) {
            #expect(urlComponents.url == nil)
        } else {
            #expect(urlComponents.url == URL(string: "https:")!)
        }
    }
}
