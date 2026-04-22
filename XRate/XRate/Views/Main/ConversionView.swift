import SwiftUI

struct ConversionView: View {
    @State private var viewModel: ConversionViewModel
    @State private var showCurrencyPicker = false
    @State private var isPickingSource = true
    @State private var showTrendChart = false
    @Environment(\.modelContext) private var modelContext

    init() {
        let usd = Currency(code: "USD", name: "US Dollar", symbol: "$",
                           flagEmoji: "🇺🇸", continent: "North America", isPopular: true)
        let eur = Currency(code: "EUR", name: "Euro", symbol: "€",
                           flagEmoji: "🇪🇺", continent: "Europe", isPopular: true)
        _viewModel = State(initialValue: ConversionViewModel(sourceCurrency: usd, targetCurrency: eur))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        sourceCard
                        swapButton
                        targetCard
                        quickAccessBar
                        miniTrendChart
                        lastUpdatedLabel
                    }
                    .padding(.horizontal, 20)
                    .iPadMaxWidth()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("XRate")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .task {
            viewModel.loadCurrencies()
            await viewModel.loadRates(context: modelContext)
        }
        .refreshable {
            await viewModel.loadRates(context: modelContext)
        }
        .sheet(isPresented: $showCurrencyPicker) {
            CurrencyPickerView(
                isPickingSource: isPickingSource,
                selectedCurrency: isPickingSource ? viewModel.sourceCurrency : viewModel.targetCurrency,
                allCurrencies: viewModel.allCurrencies,
                onSelect: { currency in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if isPickingSource {
                            viewModel.sourceCurrency = currency
                        } else {
                            viewModel.targetCurrency = currency
                        }
                    }
                    Task { await viewModel.loadRates(context: modelContext) }
                }
            )
        }
        .sheet(isPresented: $showTrendChart) {
            TrendChartView(
                sourceCurrency: viewModel.sourceCurrency,
                targetCurrency: viewModel.targetCurrency,
                currentRate: viewModel.exchangeRate
            )
        }
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isPickingSource = true
                showCurrencyPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.sourceCurrency.flagEmoji)
                        .font(.system(size: 28))
                    Text(viewModel.sourceCurrency.code)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            TextField("0", text: $viewModel.sourceAmount)
                .font(.system(size: 42, weight: .light, design: .monospaced))
                .keyboardType(.decimalPad)
                .onChange(of: viewModel.sourceAmount) { _, _ in
                    viewModel.updateConvertedAmount()
                }
        }
        .cardStyle()
    }

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isPickingSource = false
                showCurrencyPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.targetCurrency.flagEmoji)
                        .font(.system(size: 28))
                    Text(viewModel.targetCurrency.code)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(viewModel.convertedAmount)
                .font(.system(size: 42, weight: .light, design: .monospaced))
                .foregroundStyle(Color.accentColor)
        }
        .cardStyle()
    }

    private var swapButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.swapCurrencies()
            }
            Task { await viewModel.loadRates(context: modelContext) }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.accentColor, in: Circle())
        }
        .padding(.vertical, -10)
        .zIndex(1)
    }

    private var quickAccessBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.quickAccessCurrencies.prefix(5)) { currency in
                    quickAccessChip(currency)
                }
                Button {
                    isPickingSource = false
                    showCurrencyPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 16)
    }

    @ViewBuilder
    private func quickAccessChip(_ currency: Currency) -> some View {
        Button {
            viewModel.selectQuickAccessCurrency(currency)
            Task { await viewModel.loadRates(context: modelContext) }
        } label: {
            HStack(spacing: 4) {
                Text(currency.flagEmoji)
                Text(currency.code)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
        }
    }

    private var miniTrendChart: some View {
        Button { showTrendChart = true } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("7-Day Trend")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.secondary)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(height: 40)
                    .overlay {
                        Text("Tap to view")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 12)
    }

    private var lastUpdatedLabel: some View {
        HStack(spacing: 4) {
            if viewModel.isOffline {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            if let date = viewModel.lastUpdated {
                Text("Updated \(date, style: .relative)")
            } else {
                Text("Loading...")
            }
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}
