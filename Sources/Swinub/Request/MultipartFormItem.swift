import CoreTransferable

public struct MultipartFormItem: Sendable {
    public let name: String
    public let value: (any Transferable)?
    
    init(name: String, value: (any Transferable)?) {
        self.name = name
        self.value = value
    }
}
