import Testing

@testable import Swinub

@Suite
struct NNodeInfoRelationshipTests {
    @Test
    func sort() async throws {
        let rels: [NodeInfoLink.Relationship] = [
            .v10,
            .v11,
            .v20,
            .v21,
        ]

        #expect(rels.sorted() == rels)

        #expect(rels.max() == .v21)
    }

    @Test
    func sortLinks() async throws {
        let response = GetWellKnownNodeinfoResponse(links: [
            .init(rel: .v21, href: .temporaryDirectory),
            .init(rel: .v10, href: .temporaryDirectory),
        ])
        let maxRel = response.links.max(by: { $0.rel < $1.rel })?.rel
        #expect(maxRel == .v21)
    }
}
