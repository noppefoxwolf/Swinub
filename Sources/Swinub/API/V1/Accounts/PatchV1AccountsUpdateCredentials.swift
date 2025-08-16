import CoreTransferable
import Foundation
import HTTPTypes

// https://docs.joinmastodon.org/methods/accounts/#update_credentials
public struct PatchV1AccountsUpdateCredentials: HTTPEndpointRequest, Sendable {
    public typealias Response = VerifyCredentialAccount
    
    public init(authorization: Authorization) {
        self.authorization = authorization
    }
    public let authorization: Authorization
    
    public var displayName: String? = nil
    public var note: String? = nil
    public var locked: Bool? = nil
    public var bot: Bool? = nil
    public var discoverable: Bool? = nil
    
    public var avatar: (any Transferable & Sendable)? = nil
    public var header: (any Transferable & Sendable)? = nil
    
    public var fieldsAttributes: [FieldAttribute]? = nil
    
    public var defaultPrivacy: StatusVisibility? = nil
    public var defaultSensitive: Bool? = nil
    public var defaultLanguage: Locale.Language? = nil
    public var defaultStatusContentType: String? = nil
    
    public struct FieldAttribute: Sendable {
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
        public var name: String
        public var value: String
    }
    
    public var authority: String { authorization.host }
    public var path: String { "/api/v1/accounts/update_credentials" }
    public let method: HTTPRequest.Method = .patch
    
    public var body: EndpointRequestBody? {
        var items: [MultipartFormItem] = []
        
        items.append(MultipartFormItem(name: "display_name", value: displayName!))
        items.append(MultipartFormItem(name: "note", value: note))
        
        items.append(MultipartFormItem(name: "locked", value: locked?.stringValue))
        items.append(MultipartFormItem(name: "bot", value: bot?.stringValue))
        items.append(MultipartFormItem(name: "discoverable", value: discoverable?.stringValue))
        
        items.append(MultipartFormItem(name: "avatar", value: avatar))
        items.append(MultipartFormItem(name: "header", value: header))
        
        if let fieldsAttributes, !fieldsAttributes.isEmpty {
            for (index, field) in fieldsAttributes.enumerated() {
                items.append(MultipartFormItem(name: "fields_attributes[\(index)][name]", value: field.name))
                items.append(MultipartFormItem(name: "fields_attributes[\(index)][value]", value: field.value))
            }
        }
        
        if let defaultPrivacy { items.append(MultipartFormItem(name: "source[privacy]", value: defaultPrivacy.rawValue)) }
        if let defaultSensitive { items.append(MultipartFormItem(name: "source[sensitive]", value: defaultSensitive.stringValue)) }
        if let defaultLanguage { items.append(MultipartFormItem(name: "source[language]", value: defaultLanguage.languageCode?.identifier)) }
        if let defaultStatusContentType { items.append(MultipartFormItem(name: "source[status_content_type]", value: defaultStatusContentType)) }
        
        return .multipart(items)
    }
}

private extension Bool {
    var stringValue: String { self ? "true" : "false" }
}
