import Foundation
import Testing
@testable import Swinub

@Suite
struct InstanceV2Tests {
    @Test func decodesFeatureQuote() throws {
        let json = """
            {
              "domain": "fedibird.com",
              "title": "Fedibird",
              "version": "3.4.1",
              "description": "",
              "thumbnail": {
                "url": "https://example.com/thumbnail.png"
              },
              "rules": [],
              "configuration": {
                "accounts": {
                  "max_featured_tags": 30
                },
                "statuses": {
                  "max_characters": 560,
                  "max_media_attachments": 20
                },
                "media_attachments": {
                  "supported_mime_types": [],
                  "image_size_limit": 25165824,
                  "image_matrix_limit": 33177600,
                  "video_size_limit": 103809024,
                  "video_frame_rate_limit": 120,
                  "video_matrix_limit": 8294400
                },
                "polls": {
                  "max_options": 4,
                  "max_characters_per_option": 50,
                  "min_expiration": 300,
                  "max_expiration": 2629746
                }
              },
              "contact": {
                "email": "support@example.com"
              },
              "registrations": {
                "enabled": false,
                "approval_required": false
              },
              "feature_quote": true
            }
            """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let instance = try decoder.decode(InstanceV2.self, from: Data(json.utf8))

        #expect(instance.featureQuote == true)
    }
}
