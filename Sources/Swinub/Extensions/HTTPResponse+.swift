import HTTPTypes
import Foundation

extension HTTPResponse {
    public func link() -> (prev: PrevCursor?, next: NextCursor?) {
        guard let linkFieldValue = headerFields[.link] else { return (nil, nil) }
        let linkData = Data(linkFieldValue.utf8)
        let decoder = ResponseHeaderLinkDecoder()
        return decoder.decode(from: linkData)
    }
}
