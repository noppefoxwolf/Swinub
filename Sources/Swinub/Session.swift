import Foundation
import os
import HTTPTypes
import HTTPTypesFoundation

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public protocol Session: Sendable {
    func response<T: Request>(
        for request: T
    ) async throws -> (T.Response, HTTPResponse)
}

extension URLSession: Session {
    public func response<T: Request>(
        for request: T
    ) async throws -> (T.Response, HTTPResponse) {
        logger.info("\(request.method) \(request.path)")
        let urlRequest = try request.makeURLRequest()
        let (data, httpURLResponse) = try await self.data(for: urlRequest) as! (Data, HTTPURLResponse)
        let httpResponse = httpURLResponse.httpResponse!
        
        let decoder = request.decoder
        do {
            switch httpResponse.status.kind {
            case .successful:
                let response = try decoder.decode(T.Response.self, from: data)
                return (response, httpResponse)
            default:
                if httpResponse.headerFields[.contentType] == "text/html" {
                    let errorDescription = String(
                        localized: "Service Unavailable",
                        bundle: .module
                    )
                    throw GeneralError(errorDescription: errorDescription)
                } else {
                    throw try decoder.decode(MastodonError.self, from: data)
                }
            }
        } catch {
            logger.warning("\(httpURLResponse) \(error)")
            throw SwinubError(error: error, httpResponse: httpResponse)
        }
    }
}
