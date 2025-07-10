import CoreTransferable

public struct MultipartFormItem: Sendable {
    public let name: String
    public let value: (any Transferable & Sendable)?

    init(name: String, value: (any Transferable & Sendable)?) {
        self.name = name
        self.value = value
    }
    
    init(name: String, value: String?) {
        self.name = name
        self.value = value?.isEmpty == true ? value : .none
    }
}

