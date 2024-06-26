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
    
    public var parameters: [String: (any RequestParameterValue)?] { [:] }
    
    func makeRequestURL(
        method: HTTPRequest.Method,
        url: URL,
        parameters: [String: (any RequestParameterValue)?]
    ) throws -> URL {
        var url = url
        if [.get].contains(method) {
            let queryItems =
            try parameters
                .compactMapValues({ $0 })
                .map({ (key, value) in
                    try URLQueryItem(name: key, value: value.parameterValue)
                })
            url.append(queryItems: queryItems)
        }
        return url
    }
    
    func makeHTTPRequest(
        method: HTTPRequest.Method,
        url: URL,
        authorization: Authorization?,
        parameters: [String: (any RequestParameterValue)?]
    ) throws -> (HTTPRequest, Data) {
        let requestURL = try makeRequestURL(
            method: method,
            url: url,
            parameters: parameters
        )
        var httpRequest = HTTPRequest(method: method, url: requestURL)
        httpRequest.headerFields[.accept] = "application/json"
        if let authorization {
            httpRequest.headerFields[.authorization] = "Bearer \(authorization.oauthToken)"
            httpRequest.headerFields[.userAgent] = authorization.userAgent
        }
        var httpBody = Data()
        let isMultipartEmpty = parameters.compactMapValues({ $0?.multipartContentType }).isEmpty
        if [.post, .patch, .put].contains(method) && isMultipartEmpty {
            httpBody = try JSONSerialization.data(
                withJSONObject: parameters.compactMapValues({ $0 }),
                options: []
            )
            httpRequest.headerFields[.contentType] = "application/json; charset=utf-8"
        } else if [.post, .patch].contains(method) && !isMultipartEmpty {
            // iOSシミュレータだと送れないことがある
            /*
             Task <C95152FC-AFE0-4E62-BF69-1BF22B42A85B>.<1> finished with error [40] Error Domain=NSPOSIXErrorDomain Code=40 "Message too long" UserInfo={_NSURLErrorFailingURLSessionTaskErrorKey=LocalDataTask <C95152FC-AFE0-4E62-BF69-1BF22B42A85B>.<1>, _kCFStreamErrorDomainKey=1, NSErrorPeerAddressKey=<CFData 0x600001ef2d50 [0x1043381d0]>{length = 16, capacity = 16, bytes = 0x100201bbac4399830000000000000000}, _kCFStreamErrorCodeKey=40, _NSURLErrorRelatedURLSessionTaskErrorKey=(
                 "LocalDataTask <C95152FC-AFE0-4E62-BF69-1BF22B42A85B>.<1>"
             )}
             */
            // https://github.com/mastodon/mastodon-ios/blob/85ad331a5e3a67e59ccc065d5df13497c71bce49/MastodonSDK/Sources/MastodonSDK/API/Mastodon%2BAPI%2BAccount%2BCredentials.swift#L208
            let boundary = "__boundary__"
            for parameter in parameters.compactMapValues({ $0 }) {
                try httpBody.append(
                    .multipart(
                        boundary: boundary,
                        key: parameter.key,
                        value: parameter.value
                    )
                )
            }
            httpBody.append(Data.multipartEnd(boundary: boundary))
            httpRequest.headerFields[.contentType] = #"multipart/form-data; charset=utf-8; boundary="\#(boundary)""#
        }
        return (httpRequest, httpBody)
    }
}

extension HTTPEndpointRequest {
    public func makeHTTPRequest() throws -> (HTTPRequest, Data) {
        try makeHTTPRequest(
            method: method,
            url: url,
            authorization: nil,
            parameters: parameters
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization {
    public func makeHTTPRequest() throws -> (HTTPRequest, Data) {
        try makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            parameters: parameters
        )
    }
}

extension HTTPEndpointRequest where AuthorizationType == Authorization? {
    public func makeHTTPRequest() throws -> (HTTPRequest, Data) {
        try makeHTTPRequest(
            method: method,
            url: url,
            authorization: authorization,
            parameters: parameters
        )
    }
}
