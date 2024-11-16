import SwiftUI

struct ExchangeRatePicker: View {
    @Binding var from: String
    @Binding var to: String
    @Binding var isConverted: Bool
    let rates: [String: Double]

    var body: some View {
        Picker("From", selection: $from) {
            ForEach(rates.keys.sorted(), id: \.self) { key in
                Text(key).tag(key)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: .infinity)
        
        Button(action: {
            let temp = from
            from = to
            to = temp
            isConverted = false
        }) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
        
        Picker("To", selection: $to) {
            ForEach(rates.keys.sorted(), id: \.self) { key in
                Text(key).tag(key)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: .infinity)
    }
}


struct ExchangeRatesView: View {
    let langStr = Locale.current.language.languageCode?.identifier ?? "en"
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var amount: String = ""
    @State private var to: String = "USD"
    @State private var from: String
    @State private var isConverted = false
    @State private var showAlert = false
    @FocusState private var amountIsFocused: Bool
    
    init() {
        _from = State(initialValue: Locale.current.language.languageCode?.identifier == "vi" ? "VND" : "USD")
    }
    
    var isValidAmount: Bool {
        Double(amount) != nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Currency Converter")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Form {
                    Section(header: Text("Amount")){
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) {
                                isConverted = false
                            }
                            .focused($amountIsFocused)
                        if !isValidAmount && amount != "" {
                            Text("Please enter a valid amount")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                    }
                    
                    Section(header: Text("Currencies")) {
                        if geometry.size.width > geometry.size.height {
                            HStack {
                                ExchangeRatePicker(from: $from, to: $to,isConverted: $isConverted, rates: viewModel.rates)
                            }
                        }
                        else{
                            VStack {
                                ExchangeRatePicker(from: $from, to: $to,isConverted: $isConverted, rates: viewModel.rates)
                            }
                        }
                    }
                    
                    if !showAlert && isConverted &&
                        viewModel.result != nil && viewModel.errorMessage == nil{
                        Section (header: Text("Result")) {
                            Text("\(amount) \(from) = \(String (format: "%.2f", viewModel.result ?? 0)) \(to)")
                                .font(.headline)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                        dismissButton: .default(Text("OK"), action: {
                            viewModel.reset()
                        })
                    )
                }
                
                Button(action: {
                    guard let amount = Double(amount) else {
                        viewModel.errorMessage = "Invalid input"
                        showAlert = true
                        return
                    }
                    
                    viewModel.convert(amount: amount, from: from, to: to)
                    
                    amountIsFocused = false
                    isConverted = true
                }) {
                    Text("Convert")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidAmount ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(!isValidAmount)
                
                Spacer()
            }.onAppear {
                viewModel.fetchExchangeRates()
            }.onChange(of: viewModel.errorMessage) { errorMessage in
                showAlert = errorMessage != nil
            }
        }
    }
}
#Preview {
    ExchangeRatesView()
}
