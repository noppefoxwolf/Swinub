import Foundation
import os
import HTTPTypes
import HTTPTypesFoundation

public protocol Session: Sendable {
    func response<T: Request>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse)
}

extension URLSession: Session {
    public func response<T: Request>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse) {
        let urlRequest = try request.makeURLRequest()
        let (data, httpURLResponse) = try await self.data(for: urlRequest) as! (Data, HTTPURLResponse)
        let httpResponse = httpURLResponse.httpResponse!
        
        do {
            switch httpResponse.status.kind {
            case .successful:
                let response = try request.decode(data)
                return (response, httpResponse)
            default:
                if httpResponse.headerFields[.contentType] == "text/html" {
                    let errorDescription = String(
                        localized: "Service Unavailable",
                        bundle: .module
                    )
                    throw GeneralError(errorDescription: errorDescription)
                } else {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .millisecondsISO8601
                    throw try decoder.decode(MastodonError.self, from: data)
                }
            }
        } catch {
            throw SwinubError(error: error, httpResponse: httpResponse)
        }
    }
}


