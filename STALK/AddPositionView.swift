import SwiftUI

struct AddPositionSheet: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var ticker = ""
    @State private var shares = ""
    @State private var avgCost = ""
    @State private var error: String? = nil
    @State private var isChecking = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Add Position")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(Theme.text)

                    Text("Track a stock in your portfolio")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.text3)
                        .padding(.bottom, 8)

                    fieldLabel("Ticker symbol")
                    TextField("AAPL", text: $ticker)
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                        .autocorrectionDisabled()
                        .stalkInput()
                        .onChange(of: ticker) { _, v in ticker = v.uppercased() }

                    fieldLabel("Number of shares")
                    TextField("10", text: $shares)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .stalkInput()

                    fieldLabel("Average cost per share ($)")
                    TextField("150.00", text: $avgCost)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .stalkInput()

                    if let err = error {
                        Text(err)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.loss)
                            .padding(.top, 8)
                    }

                    Button {
                        Task { await addPosition() }
                    } label: {
                        Group {
                            if isChecking {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Add to Portfolio")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 22)
                    .disabled(isChecking)

                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.text3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .padding(22)
            }
            .background(Theme.bg)
        }
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.text2)
            .padding(.top, 18)
            .padding(.bottom, 7)
    }

    func addPosition() async {
        error = nil
        let t = ticker.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty,
              let s = Double(shares), s > 0,
              let c = Double(avgCost), c > 0
        else {
            error = "Please fill all fields"
            return
        }
        isChecking = true
        do {
            let quote = try await QuoteService.fetchQuote(t)
            appState.quotes[t] = quote
            appState.addPosition(Position(ticker: t, shares: s, avgCost: c))
            Task { await appState.refreshPortfolio() }
            dismiss()
        } catch {
            self.error = "\"\(t)\" not found"
        }
        isChecking = false
    }
}

extension View {
    func stalkInput() -> some View {
        self
            .padding(14)
            .background(Theme.bg)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.border, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .font(.system(size: 16))
    }
}
