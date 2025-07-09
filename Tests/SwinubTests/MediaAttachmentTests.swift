import Foundation
import Swinub
import Testing

@Suite
struct MediaAttachmentTests {
    @Test
    func testDecode() async throws {
        let json = """
            {
              "id": "21165404",
              "type": "audio",
              "url": "https://files.mastodon.social/media_attachments/files/021/165/404/original/a31a4a46cd713cd2.mp3",
              "preview_url": "https://files.mastodon.social/media_attachments/files/021/165/404/small/a31a4a46cd713cd2.mp3",
              "remote_url": null,
              "text_url": "https://mastodon.social/media/5O4uILClVqBWx0NNgvo",
              "meta": {
                "length": "0:06:42.86",
                "duration": 402.86,
                "audio_encode": "mp3",
                "audio_bitrate": "44100 Hz",
                "audio_channels": "stereo",
                "original": {
                  "duration": 402.860408,
                  "bitrate": 166290
                }
              },
              "description": null,
              "blurhash": null
            }
            """

        let decoded = try JSONDecoder().decode(MediaAttachment.self, from: Data(json.utf8))
        #expect(decoded.meta?.original != nil)
        #expect(decoded.meta?.original!.aspect == nil)
        #expect(decoded.meta?.small == nil)
    }
}
