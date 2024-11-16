//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var viewModel = CurrencyViewModel()
//
//    var body: some View {
//        VStack {
//            if let errorMessage = viewModel.errorMessage {
//                Text("Error: \(errorMessage)")
//            } else {
//                List(viewModel.rates.keys.sorted(), id: \.self) { key in
//                    HStack {
//                        Text(key)
//                        Spacer()
//                        Text("\(viewModel.rates[key] ?? 0.0, specifier: "%.2f")")
//                    }
//                }
//            }
//        }
//        .onAppear {
//            viewModel.fetchExchangeRates()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
