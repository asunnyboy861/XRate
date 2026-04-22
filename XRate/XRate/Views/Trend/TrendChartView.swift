import SwiftUI
import Charts

struct TrendChartView: View {
    let sourceCurrency: Currency
    let targetCurrency: Currency
    let currentRate: Double?

    @State private var viewModel = TrendViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    chartSection
                    timeRangePicker
                    statsSection
                }
                .padding(20)
                .iPadMaxWidth()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("\(sourceCurrency.code) / \(targetCurrency.code)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await viewModel.loadTrendData(
                base: sourceCurrency.code,
                quote: targetCurrency.code,
                range: .oneWeek
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let rate = currentRate {
                Text("1 \(sourceCurrency.code) = \(rate.formattedRate) \(targetCurrency.code)")
                    .font(.system(size: 22, weight: .semibold))
            }

            if let change = viewModel.dailyChange {
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%+.2f%%", change))
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(change >= 0 ? Color.green : Color.red)
            }
        }
    }

    private var chartSection: some View {
        Group {
            if viewModel.isLoading {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(height: 200)
                    .overlay {
                        ProgressView()
                    }
            } else if viewModel.trendData.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(height: 200)
                    .overlay {
                        Text("No data available")
                            .foregroundStyle(.secondary)
                    }
            } else {
                chartContent
            }
        }
    }

    private var chartContent: some View {
        Chart(viewModel.trendData) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Rate", point.rate)
            )
            .foregroundStyle(Color.accentColor)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date),
                y: .value("Rate", point.rate)
            )
            .foregroundStyle(Color.accentColor.opacity(0.1))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: viewModel.selectedRange.days > 30 ? 7 : 1)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 200)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var timeRangePicker: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    Task {
                        await viewModel.loadTrendData(
                            base: sourceCurrency.code,
                            quote: targetCurrency.code,
                            range: range
                        )
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: viewModel.selectedRange == range ? .semibold : .regular))
                        .foregroundStyle(viewModel.selectedRange == range ? .white : Color.accentColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedRange == range ? Color.accentColor : Color.clear,
                            in: Capsule()
                        )
                }
            }
        }
        .padding(4)
        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
    }

    private var statsSection: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("High")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let high = viewModel.highRate {
                    Text(high.formattedRate)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Low")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let low = viewModel.lowRate {
                    Text(low.formattedRate)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
