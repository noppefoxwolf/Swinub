import Foundation
import os
import HTTPTypes
import HTTPTypesFoundation

public protocol Session: Sendable {
    func response<T: HTTPEndpointRequest>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse)
}

extension URLSession: Session {
    public func response<T: HTTPEndpointRequest>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse) {
        let (httpRequest, data) = try request.makeHTTPRequest()
        
        let (responseData, httpResponse): (Data, HTTPResponse)
        switch request.method {
        case .post:
            (responseData, httpResponse) = try await self.upload(for: httpRequest, from: data)
        default:
            (responseData, httpResponse) = try await self.data(for: httpRequest)
        }
        
        do {
            switch httpResponse.status.kind {
            case .successful:
                let response = try request.decode(responseData)
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
                    throw try decoder.decode(MastodonError.self, from: responseData)
                }
            }
        } catch {
            throw SwinubError(error: error, httpResponse: httpResponse)
        }
    }
}


