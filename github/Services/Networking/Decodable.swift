import Foundation

protocol Decodable {
    static func fromJSON(_ json: Any) -> Self
}

extension Decodable {
    static func fromJSONArray(_ json: [Any]) -> [Self] {
        return json.map { Self.fromJSON($0) }
    }
}
