struct ExchangeRates: Decodable {
    let base: String
    let rates: [String: Double]
    let date: String
}
