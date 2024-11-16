import Foundation

class CurrencyViewModel: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var errorMessage: String? = nil

    func fetchExchangeRates() {
        NetworkManager.shared.request("latest", queryParams: ["base": "USD"]) { (result: Result<ExchangeRates, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.rates = response.rates
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
