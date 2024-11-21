struct IExchangeRates: Decodable {
    let base: String
    let rates: [String: Double]
    let date: String
}

struct IExchangeRateResult: Decodable {
    let from: String
    let to: String
    let amount: Double
    let result: Double
}
