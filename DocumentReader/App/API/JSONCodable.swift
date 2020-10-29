import Foundation

struct JSONCodable {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    static func decode<T: Decodable>(fromData data: Data) -> T? {
        do {
            return try decoder.decode(T.self, from: data)
        } catch let error {
            print("🔴 Error: trying to decode \(T.self)" + error.localizedDescription)
            return nil
        }
    }
}
