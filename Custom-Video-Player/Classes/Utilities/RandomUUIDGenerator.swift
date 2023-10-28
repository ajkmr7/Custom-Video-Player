import Foundation

class RandomUUIDGenerator {
    
    static let alphanumericCharacters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"
    
    static func generateRandomUUID(length: Int) -> String {
        var randomUUID = ""
        
        for _ in 0..<length {
            let randomIndex = alphanumericCharacters.index(alphanumericCharacters.startIndex, offsetBy: Int.random(in: 0..<alphanumericCharacters.count))
            let randomCharacter = alphanumericCharacters[randomIndex]
            randomUUID.append(randomCharacter)
        }
        
        return randomUUID
    }
}
