//
//  ExchangeRates.swift
//  currency-converter
//
//  Created by Do Pham Thanh Huy on 11/16/24.
//

import SwiftUI

struct ExchangeRatesView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                List(viewModel.rates.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        Text("\(viewModel.rates[key] ?? 0.0, specifier: "%.2f")")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchExchangeRates()
        }
    }
}

#Preview {
    ExchangeRatesView()
}
