import Foundation
import Swinub
import HTTPTypes

extension StreamingEndpointRequest {
    public func makeURLRequest(
        url: URL,
        authorization: Authorization?,
        parameters: [String: (any RequestParameterValue)?]
    ) throws -> URLRequest {
        var url = url
        let queryItems = try parameters.compactMapValues({ $0 }).compactMap({
            try URLQueryItem(name: $0.key, value: $0.value.parameterValue)
        })
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
            parameters: parameters
        )
    }
}

extension StreamingEndpointRequest where AuthorizationType == Authorization? {
    public func makeURLRequest() throws -> URLRequest {
        try makeURLRequest(
            url: url,
            authorization: authorization,
            parameters: parameters
        )
    }
}
