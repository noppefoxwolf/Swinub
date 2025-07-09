import CoreTransferable

public struct MultipartFormItem: Sendable {
    public let name: String
    public let value: (any Transferable & Sendable)?

    init(name: String, value: (any Transferable & Sendable)?) {
        self.name = name
        self.value = value
    }
}

struct TransferableString: Transferable {
    let rawValue: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .utf8PlainText) {
            if $0.rawValue.isEmpty {
                Data()
            } else {
                Data($0.rawValue.utf8)
            }
        }
    }
}
