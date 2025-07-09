import Foundation
import HTTPTypes
import Swinub

extension StreamingEndpointRequest {
    public func makeURLRequest(
        url: URL,
        authorization: Authorization?,
        queryItems: [URLQueryItem]
    ) throws -> URLRequest {
        var url = url
        url.append(queryItems: queryItems)
        var urlRequset = URLRequest(url: url)
        if let authorization {
            urlRequset.addValue(
                authorization.oauthToken,
                forHTTPHeaderField: HTTPField.Name.authorization.rawName
            )
            urlRequset.addValue(
                authorization.userAgent,
                forHTTPHeaderField: HTTPField.Name.userAgent.rawName
            )
        }
        return urlRequset
    }
}

extension StreamingEndpointRequest {
    public func makeURLRequest() throws -> URLRequest {
        try makeURLRequest(
            url: url,
            authorization: nil,
            queryItems: queryItems
        )
    }
}

extension StreamingEndpointRequest where AuthorizationType == Authorization? {
    public func makeURLRequest() throws -> URLRequest {
        try makeURLRequest(
            url: url,
            authorization: authorization,
            queryItems: queryItems
        )
    }
}
