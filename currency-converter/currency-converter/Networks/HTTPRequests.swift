import Foundation

let apiBaseURL: String = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? ""
let apiKey: String = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
