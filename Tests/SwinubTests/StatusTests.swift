import XCTest

@testable import Swinub

class StatusTests: XCTestCase {
    func testCodable() throws {
        let json = #"""
            {
              "id": "110064600195523314",
              "created_at": "2023-03-22T02:35:14.000Z",
              "in_reply_to_id": null,
              "in_reply_to_account_id": null,
              "sensitive": false,
              "spoiler_text": "",
              "visibility": "public",
              "language": "en",
              "uri": "https://botsin.space/users/RaspiArduino/statuses/110064600001570337",
              "url": "https://botsin.space/@RaspiArduino/110064600001570337",
              "replies_count": 0,
              "reblogs_count": 0,
              "favourites_count": 0,
              "edited_at": null,
              "content": "<p>The price one pays for pursuing any profession, or calling, is an intimate<br>knowledge of its ugly side.  -- James Baldwin</p>",
              "reblog": null,
              "account": {
                "id": "109826218965396365",
                "username": "RaspiArduino",
                "acct": "RaspiArduino@botsin.space",
                "display_name": "Raspberry Arduino",
                "locked": false,
                "bot": true,
                "discoverable": false,
                "group": false,
                "created_at": "2023-02-06T00:00:00.000Z",
                "note": "<p>I am a Raspberry Pi, Arduino composite (OK it's really a ShrimpingIt kit). I spurt out tweets using Node-RED and physical stuff on a thermal printer.</p>",
                "url": "https://botsin.space/@RaspiArduino",
                "avatar": "https://files.mastodon.social/cache/accounts/avatars/109/826/218/965/396/365/original/ad0972eebd704f3c.jpg",
                "avatar_static": "https://files.mastodon.social/cache/accounts/avatars/109/826/218/965/396/365/original/ad0972eebd704f3c.jpg",
                "header": "https://mastodon.social/headers/original/missing.png",
                "header_static": "https://mastodon.social/headers/original/missing.png",
                "followers_count": 2,
                "following_count": 0,
                "statuses_count": 3073,
                "last_status_at": "2023-03-22",
                "emojis": [],
                "fields": []
              },
              "media_attachments": [],
              "mentions": [],
              "tags": [],
              "emojis": [],
              "card": null,
              "poll": null,
              "filtered": []
            }
            """#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601
        let status = try decoder.decode(Status.self, from: Data(json.utf8))
        XCTAssertEqual(status.id.rawValue, "110064600195523314")
    }

    func testStream() throws {
        let json = #"""
            {"stream":["public"],"event":"update","payload":"{\"id\":\"110066038263943268\",\"created_at\":\"2023-03-22T08:41:00.823Z\",\"in_reply_to_id\":null,\"in_reply_to_account_id\":null,\"sensitive\":false,\"spoiler_text\":\"\",\"visibility\":\"public\",\"language\":\"de\",\"uri\":\"https://mastodon.social/users/thomasotto/statuses/110066038263943268\",\"url\":\"https://mastodon.social/@thomasotto/110066038263943268\",\"replies_count\":0,\"reblogs_count\":0,\"favourites_count\":0,\"edited_at\":null,\"content\":\"<p>»The fact that ChatGPT rephrases material from the Web [...] makes it seem like a student expressing ideas in her own words, rather than simply regurgitating what she’s read; it creates the illusion that ChatGPT understands the material.« <a href=\\\"https://www.newyorker.com/tech/annals-of-technology/chatgpt-is-a-blurry-jpeg-of-the-web\\\" target=\\\"_blank\\\" rel=\\\"nofollow noopener noreferrer\\\"><span class=\\\"invisible\\\">https://www.</span><span class=\\\"ellipsis\\\">newyorker.com/tech/annals-of-t</span><span class=\\\"invisible\\\">echnology/chatgpt-is-a-blurry-jpeg-of-the-web</span></a> <a href=\\\"https://mastodon.social/tags/ChatGPT\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>ChatGPT</span></a> <a href=\\\"https://mastodon.social/tags/AI\\\" class=\\\"mention hashtag\\\" rel=\\\"tag\\\">#<span>AI</span></a></p>\",\"reblog\":null,\"application\":{\"name\":\"Buffer\",\"website\":\"https://buffer.com\"},\"account\":{\"id\":\"109361610499318763\",\"username\":\"thomasotto\",\"acct\":\"thomasotto\",\"display_name\":\"Thomas Otto (he/him)\",\"locked\":false,\"bot\":false,\"discoverable\":true,\"group\":false,\"created_at\":\"2022-11-17T00:00:00.000Z\",\"note\":\"<p>Leading Design &amp; UX at Upper.co | A.I. &amp; ML | Data (ethics) &amp; Privacy | Between design, tech, and business. (opinions are mine)</p>\",\"url\":\"https://mastodon.social/@thomasotto\",\"avatar\":\"https://files.mastodon.social/accounts/avatars/109/361/610/499/318/763/original/0189414ba6cb93a4.jpg\",\"avatar_static\":\"https://files.mastodon.social/accounts/avatars/109/361/610/499/318/763/original/0189414ba6cb93a4.jpg\",\"header\":\"https://files.mastodon.social/accounts/headers/109/361/610/499/318/763/original/bcd4cc11e1af8b0c.jpg\",\"header_static\":\"https://files.mastodon.social/accounts/headers/109/361/610/499/318/763/original/bcd4cc11e1af8b0c.jpg\",\"followers_count\":40,\"following_count\":38,\"statuses_count\":22,\"last_status_at\":\"2023-03-22\",\"noindex\":false,\"emojis\":[],\"roles\":[],\"fields\":[{\"name\":\"Web\",\"value\":\"<a href=\\\"https://www.thomas-otto.net\\\" target=\\\"_blank\\\" rel=\\\"nofollow noopener noreferrer me\\\"><span class=\\\"invisible\\\">https://www.</span><span class=\\\"\\\">thomas-otto.net</span><span class=\\\"invisible\\\"></span></a>\",\"verified_at\":null},{\"name\":\"Data ethics toolkit\",\"value\":\"<a href=\\\"https://www.designhumandata.net\\\" target=\\\"_blank\\\" rel=\\\"nofollow noopener noreferrer me\\\"><span class=\\\"invisible\\\">https://www.</span><span class=\\\"\\\">designhumandata.net</span><span class=\\\"invisible\\\"></span></a>\",\"verified_at\":null}]},\"media_attachments\":[],\"mentions\":[],\"tags\":[{\"name\":\"chatgpt\",\"url\":\"https://mastodon.social/tags/chatgpt\"},{\"name\":\"ai\",\"url\":\"https://mastodon.social/tags/ai\"}],\"emojis\":[],\"card\":null,\"poll\":null,\"filtered\":[]}"}
            """#
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601
        _ = try decoder.decode(Message.self, from: Data(json.utf8))

    }

    func testhoge() throws {
        let json = #"""
            {
                "message" : "\"hoge\""
            }
            """#
        print(json)
        struct JSON: Codable {
            let message: String
        }
        let decoder = JSONDecoder()

        let object = try decoder.decode(JSON.self, from: Data(json.utf8))
        XCTAssertEqual(object.message, #""hoge""#)
    }
}
