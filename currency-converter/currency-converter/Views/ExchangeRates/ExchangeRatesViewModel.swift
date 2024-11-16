import Foundation

class CurrencyViewModel: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var errorMessage: String? = nil
    @Published var result: Double? = nil
    private let api: API

    init(api: API = API.shared) {
        self.api = api
    }

    func fetchExchangeRates() {
        if(result != nil) {
            return
        }
        else{
            api.get(endpoint: "latest") { (result: Result<IExchangeRates, Error>) in
                switch result {
                case .success(let exchangeRates):
                    print(result)
                    DispatchQueue.main.async {
                        if self.rates != exchangeRates.rates {
                            self.rates = exchangeRates.rates
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if self.errorMessage != error.localizedDescription {
                            self.errorMessage = error.localizedDescription.description
                        }
                    }
                }
            }
        }
    }

    func convert (amount: Double, from: String, to: String) {
        if let fromRate = rates[from], let toRate = rates[to] {
            DispatchQueue.main.async {
                self.result = (amount / fromRate) * toRate
                self.errorMessage = nil
            }
        }
        else {
            api.get(endpoint: "convert", queryParams: ["from": from, "to": to, "amount": "\(amount)"]) { (result: Result<IExchangeRateResult, Error>) in
                switch result {
                case .success(let conversionResult):
                    DispatchQueue.main.async {
                        self.errorMessage = nil
                        self.result = conversionResult.result
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if self.errorMessage != error.localizedDescription {
                            self.errorMessage = error.localizedDescription
                            self.result = nil
                        }
                    }
                }
            }
        }
    }
    
    func reset () {
        self.result = nil
        self.errorMessage = nil
    }
}
