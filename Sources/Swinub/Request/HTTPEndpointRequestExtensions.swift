import Foundation
import HTTPTypes
import HTTPTypesFoundation

extension HTTPEndpointRequest {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: nil,
            queryItems: queryItems,
            body: body,
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            queryItems: queryItems,
            body: body,
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization? {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            queryItems: queryItems,
            body: body,
        )
    }
}