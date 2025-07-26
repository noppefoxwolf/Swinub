import Foundation
import HTTPTypes
import Testing

@testable import Swinub

@Suite
struct TrendingTagsTests {
    @Test func trendingTagsURL() async throws {
        let request = GetV1TrendsTags(host: "mastodon.social")
        let url = try request.url
        
        #expect(url.absoluteString == "https://mastodon.social/api/v1/trends/tags")
    }
    
    @Test func trendingTagsWithLimit() async throws {
        let request = GetV1TrendsTags(host: "mastodon.social", limit: 5)
        let (httpRequest, _) = try await request.makeHTTPRequest()
        
        #expect(httpRequest.url?.absoluteString == "https://mastodon.social/api/v1/trends/tags?limit=5")
    }
    
    @Test func trendingTagsWithOffset() async throws {
        let request = GetV1TrendsTags(host: "mastodon.social", offset: 10)
        let (httpRequest, _) = try await request.makeHTTPRequest()
        
        #expect(httpRequest.url?.absoluteString == "https://mastodon.social/api/v1/trends/tags?offset=10")
    }
    
    @Test func trendingTagsWithLimitAndOffset() async throws {
        let request = GetV1TrendsTags(host: "mastodon.social", limit: 5, offset: 10)
        let (httpRequest, _) = try await request.makeHTTPRequest()
        
        #expect(httpRequest.url?.query?.contains("limit=5") == true)
        #expect(httpRequest.url?.query?.contains("offset=10") == true)
    }
}