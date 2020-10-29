import Foundation

struct ValidationResponse: Codable {
    let status: String
    let valid: Bool
    let validationScore: Int
    let ocrTexts: [String]
    let ocrLabels: [OcrLabel]
    let data: DataClass

    enum CodingKeys: String, CodingKey {
        case status, valid
        case validationScore = "validation_score"
        case ocrTexts = "ocr_texts"
        case ocrLabels = "ocr_labels"
        case data
    }
}

struct DataClass: Codable {
    let firstName, lastName, birthdate, sex: String
    let personalNumber, documentNumber, documentExpires: String
    let documentValid: Bool

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case birthdate, sex
        case personalNumber = "personal_number"
        case documentNumber = "document_number"
        case documentExpires = "document_expires"
        case documentValid = "document_valid"
    }
}

struct OcrLabel: Codable {
    let ocrLabelDescription: String
    let score: Int

    enum CodingKeys: String, CodingKey {
        case ocrLabelDescription = "description"
        case score
    }
}
