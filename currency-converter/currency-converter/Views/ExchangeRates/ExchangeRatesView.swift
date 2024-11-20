import SwiftUI

struct Modal: View {
    @Environment(\.dismiss) var dismiss
    @Binding var value: String
    let rates: [String: Double]
    
    @State private var searchQuery: String = ""

    
    var searchResults: [String] {
        if searchQuery.isEmpty {
            return rates.keys.sorted()
        } else {
            return rates.keys.filter { $0.contains(searchQuery.uppercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults, id: \.self) { key in
                    Button(action: {
                        value = key
                        dismiss()
                    }) {
                        HStack {
                            Text(key)
                            Spacer()
                            Text(rates[key] != nil ? String(format: "%.2f", rates[key]!) : "")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Select Currency")
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct ExchangeRatesField: View {
    let label: String
    let rates: [String:Double]
    @Binding var value: String
    
    @State private var showModal: Bool = false
    
    var body: some View {
        HStack{
            Text(label)
            Spacer()
            Button(
                action: {
                    showModal.toggle()
                }
            ){
                Text(value)
            
            }.sheet(isPresented: $showModal, content: {
                Modal(value: $value, rates: rates)
            })
        }
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
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Currency Converter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Section(header: Text("Amount").font(.headline)) {
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { _ in
                                withAnimation {
                                    isConverted = false
                                }
                                //                                isConverted = false
                            }
                            .focused($amountIsFocused)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                        
                        if !isValidAmount && amount != "" {
                            Text("Please enter a valid amount")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                    }
                    
                    Section(header: Text("Currencies").font(.headline)) {
                        VStack {
                            ExchangeRatesField(label: "From", rates: viewModel.rates, value: $from)
                            Button(action: {
                                let temp = from
                                from = to
                                to = temp
                                isConverted = false
                            }) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }.hoverEffect(.highlight)
                            ExchangeRatesField(label: "To", rates: viewModel.rates, value: $to)
                        }
                        .onChange(of: from) { _ in
                            isConverted = false
                        }
                        .onChange(of: to) { _ in
                            isConverted = false
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    
                    if !showAlert && isConverted &&
                        viewModel.result != nil && viewModel.errorMessage == nil {
                        Section(header: Text("Result").font(.headline)) {
                            HStack {
                                Text("\(amount) \(from) = \(String(format: "%.2f", viewModel.result ?? 0)) \(to)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isConverted)
                        }
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
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(!isValidAmount)
                    
                    Spacer()
                }
                .onAppear {
                    viewModel.fetchExchangeRates()
                }
                .onChange(of: viewModel.errorMessage) { errorMessage in
                    showAlert = errorMessage != nil
                }
                .padding(.horizontal)
                .scrollDisabled(false)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? "An unknown error occurred"),
                        dismissButton: .default(Text("OK"), action: {
                            viewModel.reset()
                        })
                    )
                }
            }
            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
            .scrollContentBackground(.hidden)
        }
    }
}
#Preview {
    ExchangeRatesView()
}
