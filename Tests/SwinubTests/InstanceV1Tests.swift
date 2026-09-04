import Foundation
import Testing
@testable import Swinub

@Suite
struct InstanceV1Tests {
    @Test func decodesFedibirdQuoteProperties() throws {
        let json = """
            {
              "uri": "fedibird.com",
              "title": "Fedibird",
              "short_description": "",
              "description": "",
              "version": "3.4.1",
              "stats": {
                "user_count": 40332,
                "status_count": 29644904,
                "domain_count": 51279
              },
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
                  "max_options": 10,
                  "max_characters_per_option": 50,
                  "min_expiration": 300,
                  "max_expiration": 2629746
                }
              },
              "feature_quote": true
            }
            """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let instance = try decoder.decode(InstanceV1.self, from: Data(json.utf8))

        #expect(instance.featureQuote == true)
    }

    @Test func decodesSharkeyCompatibleResponseWithoutShortDescription() throws {
        let json = """
            {
              "uri": "ddoskey.com",
              "title": "Sharkey",
              "description": "",
              "version": "3.0.0",
              "stats": {
                "user_count": 1,
                "status_count": 2,
                "domain_count": 3
              },
              "configuration": {
                "accounts": {
                  "max_featured_tags": 20
                },
                "statuses": {
                  "max_characters": 3000,
                  "max_media_attachments": 16
                },
                "media_attachments": {
                  "supported_mime_types": [],
                  "image_size_limit": 1,
                  "image_matrix_limit": 2,
                  "video_size_limit": 3,
                  "video_frame_limit": 4,
                  "video_matrix_limit": 5
                },
                "polls": {
                  "max_options": 10,
                  "max_characters_per_option": 150,
                  "min_expiration": 50,
                  "max_expiration": 2629746
                }
              },
              "registrations": true,
              "approval_required": false
            }
            """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let instance = try decoder.decode(InstanceV1.self, from: Data(json.utf8))

        #expect(instance.shortDescription == nil)
        #expect(instance.registrations == true)
        #expect(instance.approvalRequired == false)
    }
}
