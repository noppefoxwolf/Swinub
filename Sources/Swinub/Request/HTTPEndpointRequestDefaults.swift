import Foundation
import HTTPTypes
import HTTPTypesFoundation
import CoreTransferable

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