import Foundation
import HTTPTypes
import HTTPTypesFoundation
import os

public protocol Session: Sendable {
    func response<T: HTTPEndpointRequest>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse)
}

extension URLSession: Session {
    public func response<T: HTTPEndpointRequest>(
        for request: T
    ) async throws -> (response: T.Response, httpResponse: HTTPResponse) {
        let (httpRequest, data) = try await request.makeHTTPRequest()

        let (responseData, httpResponse): (Data, HTTPResponse)
        switch request.method {
        case .post, .put, .patch:
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
                switch httpResponse.headerFields[.contentType] {
                case let .some(contentType) where contentType.contains("text/html"):
                    let errorDescription = String(
                        localized: "Service Unavailable",
                        bundle: .module
                    )
                    throw GeneralError(errorDescription: errorDescription)
                case let .some(contentType) where contentType.contains("text/plain"):
                    let errorDescription = String(data: responseData, encoding: .utf8)
                    throw GeneralError(errorDescription: errorDescription)
                default:
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
