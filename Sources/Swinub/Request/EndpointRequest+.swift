import CoreTransferable
import Foundation
import HTTPTypes
import HTTPTypesFoundation

struct RequestFailedToMakeComponentsError: LocalizedError {
    var errorDescription: String? { "Request failed to make url components." }
}

extension EndpointRequest {
    public var url: URL {
        get throws {
            let relativeToURL = URL(string: "\(scheme)://\(authority)")
            let url = relativeToURL.map({ URL(string: path, relativeTo: $0) }).flatMap({ $0 })
            guard let url else {
                throw GeneralError(
                    errorDescription: "Can not convert URL from \(scheme)://\(authority)"
                )
            }
            return url
        }
    }

    public func decode(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsISO8601
        return try decoder.decode(Response.self, from: data)
    }
}

extension EndpointRequest where AuthorizationType == Never {
    public var authorization: Never { fatalError() }
}

extension HTTPEndpointRequest {
    public var scheme: String {
        "https"
    }

    public var queryItems: [URLQueryItem] { [] }

    public var body: EndpointRequestBody? { nil }

    func makeHTTPRequest(
        method: HTTPRequest.Method,
        url: URL,
        authorization: Authorization?,
        queryItems: [URLQueryItem],
        body: EndpointRequestBody?
    ) async throws -> (HTTPRequest, Data) {
        let requestURL = url.appending(queryItems: queryItems)
        var httpRequest = HTTPRequest(method: method, url: requestURL)
        httpRequest.headerFields[.accept] = "application/json"
        if let authorization {
            httpRequest.headerFields[.authorization] = "Bearer \(authorization.oauthToken)"
            httpRequest.headerFields[.userAgent] = authorization.userAgent
        }

        switch body {
        case .none:
            return (httpRequest, Data())
        case .json(let jsonObject):
            let data = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: []
            )
            httpRequest.headerFields[.contentType] = "application/json; charset=utf-8"
            return (httpRequest, data)
        case .multipart(let multipartFormItems):
            let multipartBuilder = MultipartBuilder()
            httpRequest.headerFields[.contentType] = multipartBuilder.contentType
            let data = try await multipartBuilder.build(multipartFormItems)
            return (httpRequest, data)
        }
    }
}

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
