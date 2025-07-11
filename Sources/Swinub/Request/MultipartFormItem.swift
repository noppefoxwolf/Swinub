import CoreTransferable

public struct MultipartFormItem: Sendable {
    public let name: String
    public let value: (any Transferable & Sendable)?

    init(name: String, value: (any Transferable & Sendable)?) {
        self.name = name
        self.value = value
    }
}

