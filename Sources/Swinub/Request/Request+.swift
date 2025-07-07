import HTTPTypes
import HTTPTypesFoundation
import Foundation

struct RequestFailedToMakeComponentsError: LocalizedError {
    var errorDescription: String? { "Request failed to make url components." }
}

extension EndpointRequest {
    public var url: URL {
        get throws {
            let relativeToURL = URL(string: "\(scheme)://\(authority)")
            let url = relativeToURL.map({ URL(string: path, relativeTo: $0) }).flatMap({ $0 })
            guard let url else { throw GeneralError(errorDescription: "Can not convert URL from \(scheme)://\(authority)") }
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
    
    public var parameters: [String: (any RequestParameterValue)?] { [:] }
    
    func makeRequestURL(url: URL) throws -> URL {
        url.appending(queryItems: queryItems)
    }
    
    func makeHTTPRequest(
        method: HTTPRequest.Method,
        url: URL,
        authorization: Authorization?,
        parameters: [String: (any RequestParameterValue)?]
    ) async throws -> (HTTPRequest, Data) {
        let requestURL = try makeRequestURL(url: url)
        var httpRequest = HTTPRequest(method: method, url: requestURL)
        httpRequest.headerFields[.accept] = "application/json"
        if let authorization {
            httpRequest.headerFields[.authorization] = "Bearer \(authorization.oauthToken)"
            httpRequest.headerFields[.userAgent] = authorization.userAgent
        }
        
        let httpBody = try await makeHTTPBody(method: method, parameters: parameters, httpRequest: &httpRequest)
        return (httpRequest, httpBody)
    }
    
    private func makeHTTPBody(
        method: HTTPRequest.Method,
        parameters: [String: (any RequestParameterValue)?],
        httpRequest: inout HTTPRequest
    ) async throws -> Data {
        let multipartBuilder = MultipartBuilder()
        
        if [.post, .patch, .put].contains(method) && !multipartBuilder.isMultipartRequired(parameters: parameters) {
            let data = try JSONSerialization.data(
                withJSONObject: parameters.compactMapValues({ $0 }),
                options: []
            )
            httpRequest.headerFields[.contentType] = "application/json; charset=utf-8"
            return data
        } else if [.post, .patch].contains(method) && multipartBuilder.isMultipartRequired(parameters: parameters) {
            httpRequest.headerFields[.contentType] = multipartBuilder.contentType
            return try await multipartBuilder.build([])
        }
        
        return Data()
    }
}

extension HTTPEndpointRequest {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: nil,
            parameters: parameters
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            parameters: parameters
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization? {
    public func makeHTTPRequest() async throws -> (HTTPRequest, Data) {
        try await makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            parameters: parameters
        )
    }
}
