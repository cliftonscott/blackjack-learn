import SwiftUI

struct StrategyView: View {
    @Binding var rules: TableRules

    private let dealerCards: [PlayingCard] = [
        .c(.two, .clubs), .c(.three, .clubs), .c(.four, .clubs), .c(.five, .clubs),
        .c(.six, .clubs), .c(.seven, .clubs), .c(.eight, .clubs), .c(.nine, .clubs),
        .c(.ten, .clubs), .c(.ace, .clubs)
    ]

    private let hardRows: [StrategyChartRow] = [
        StrategyChartRow(label: "Hard 5", cards: [.c(.two, .hearts), .c(.three, .clubs)]),
        StrategyChartRow(label: "Hard 6", cards: [.c(.two, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "Hard 7", cards: [.c(.three, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "Hard 8", cards: [.c(.three, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "Hard 9", cards: [.c(.four, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "Hard 10", cards: [.c(.six, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "Hard 11", cards: [.c(.six, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "Hard 12", cards: [.c(.ten, .hearts), .c(.two, .clubs)]),
        StrategyChartRow(label: "Hard 13", cards: [.c(.ten, .hearts), .c(.three, .clubs)]),
        StrategyChartRow(label: "Hard 14", cards: [.c(.ten, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "Hard 15", cards: [.c(.ten, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "Hard 16", cards: [.c(.ten, .hearts), .c(.six, .clubs)]),
        StrategyChartRow(label: "Hard 17+", cards: [.c(.ten, .hearts), .c(.seven, .clubs)])
    ]

    private let softRows: [StrategyChartRow] = [
        StrategyChartRow(label: "A,2", cards: [.c(.ace, .hearts), .c(.two, .clubs)]),
        StrategyChartRow(label: "A,3", cards: [.c(.ace, .hearts), .c(.three, .clubs)]),
        StrategyChartRow(label: "A,4", cards: [.c(.ace, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "A,5", cards: [.c(.ace, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "A,6", cards: [.c(.ace, .hearts), .c(.six, .clubs)]),
        StrategyChartRow(label: "A,7", cards: [.c(.ace, .hearts), .c(.seven, .clubs)]),
        StrategyChartRow(label: "A,8", cards: [.c(.ace, .hearts), .c(.eight, .clubs)]),
        StrategyChartRow(label: "A,9", cards: [.c(.ace, .hearts), .c(.nine, .clubs)])
    ]

    private let pairRows: [StrategyChartRow] = [
        StrategyChartRow(label: "A,A", cards: [.c(.ace, .hearts), .c(.ace, .clubs)]),
        StrategyChartRow(label: "10,10", cards: [.c(.king, .hearts), .c(.queen, .clubs)]),
        StrategyChartRow(label: "9,9", cards: [.c(.nine, .hearts), .c(.nine, .clubs)]),
        StrategyChartRow(label: "8,8", cards: [.c(.eight, .hearts), .c(.eight, .clubs)]),
        StrategyChartRow(label: "7,7", cards: [.c(.seven, .hearts), .c(.seven, .clubs)]),
        StrategyChartRow(label: "6,6", cards: [.c(.six, .hearts), .c(.six, .clubs)]),
        StrategyChartRow(label: "5,5", cards: [.c(.five, .hearts), .c(.five, .clubs)]),
        StrategyChartRow(label: "4,4", cards: [.c(.four, .hearts), .c(.four, .clubs)]),
        StrategyChartRow(label: "3,3", cards: [.c(.three, .hearts), .c(.three, .clubs)]),
        StrategyChartRow(label: "2,2", cards: [.c(.two, .hearts), .c(.two, .clubs)])
    ]

    var body: some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RuleControls(rules: $rules)
                StrategyMemoryAid()
                legend
                StrategyChart(
                    title: "Hard totals",
                    subtitle: "Hands without a flexible ace.",
                    rows: hardRows,
                    dealerCards: dealerCards,
                    rules: rules
                )
                StrategyChart(
                    title: "Soft hands",
                    subtitle: "Ace counted as 11 without busting.",
                    rows: softRows,
                    dealerCards: dealerCards,
                    rules: rules
                )
                StrategyChart(
                    title: "Pairs",
                    subtitle: "First-decision split guidance.",
                    rows: pairRows,
                    dealerCards: dealerCards,
                    rules: rules
                )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Strategy")
    }

    private var legend: some View {
        InfoPanel(title: "Chart key", subtitle: "Generated from the current table rules.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                ForEach(MoveAction.allCases) { action in
                    HStack(spacing: 8) {
                        Text(action.chartShortLabel)
                            .font(.caption.weight(.black))
                            .frame(width: 28, height: 24)
                            .background(action.chartColor.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text(action.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

private struct StrategyChartRow: Identifiable {
    let label: String
    let cards: [PlayingCard]

    var id: String { label }
}

private struct StrategyChart: View {
    let title: String
    let subtitle: String
    let rows: [StrategyChartRow]
    let dealerCards: [PlayingCard]
    let rules: TableRules

    private let rowLabelWidth: CGFloat = 50
    private let columnSpacing: CGFloat = 3
    private let rowSpacing: CGFloat = 7
    private let tileHeight: CGFloat = 27

    var body: some View {
        InfoPanel(title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: rowSpacing) {
                HStack(spacing: columnSpacing) {
                    headerLabel("Hand", alignment: .leading)
                        .frame(width: rowLabelWidth, alignment: .leading)
                    ForEach(dealerCards) { card in
                        headerLabel(card.rank.rawValue, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(rows) { row in
                    HStack(spacing: columnSpacing) {
                        rowLabel(row.label)
                        ForEach(dealerCards) { dealer in
                            let move = BlackjackStrategy.recommendation(
                                for: BlackjackHand(cards: row.cards),
                                dealerUpcard: dealer,
                                rules: rules
                            ).action
                            ChartActionTile(move: move, height: tileHeight)
                                .accessibilityLabel("\(row.label) versus dealer \(dealer.rank.rawValue): \(move.label)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
        }
    }

    private func headerLabel(_ text: String, alignment: Alignment) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    private func rowLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(width: rowLabelWidth, alignment: .leading)
    }
}

private struct ChartActionTile: View {
    let move: MoveAction
    let height: CGFloat

    var body: some View {
        Text(move.chartShortLabel)
            .font(.caption2.weight(.black))
            .foregroundStyle(move.chartColor)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(move.chartColor.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

private extension MoveAction {
    var chartShortLabel: String {
        switch self {
        case .hit: "H"
        case .stand: "S"
        case .doubleDown: "D"
        case .split: "P"
        case .surrender: "R"
        }
    }

    var chartColor: Color {
        switch self {
        case .hit: .blue
        case .stand: .green
        case .doubleDown: .orange
        case .split: .purple
        case .surrender: .red
        }
    }
}

struct StrategyMemoryAid: View {
    private let steps = [
        MemoryStep(
            icon: "rectangle.on.rectangle.angled",
            title: "Pairs first",
            detail: "Split A,A and 8,8. Never split 10s or 5s.",
            tint: Color.purple
        ),
        MemoryStep(
            icon: "sparkles",
            title: "Soft hands next",
            detail: "A,8 or better stands. A,2 through A,7 usually hits or doubles against weak dealer cards.",
            tint: Color.orange
        ),
        MemoryStep(
            icon: "number",
            title: "Hard totals last",
            detail: "17+ stands. 13-16 stands vs 2-6. 12 stands only vs 4-6.",
            tint: Color.blue
        )
    ]

    var body: some View {
        InfoPanel(title: "Remember the move", subtitle: "Dealer 2-6 is weak. Dealer 7-A is strong.") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weak dealer: hold stiff, double good hands. Strong dealer: improve or die trying.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.green)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(steps) { step in
                        MemoryStepRow(step: step)
                    }
                }

                BulletList(items: [
                    "11 doubles; 10 doubles vs 2-9; 9 doubles vs 3-6.",
                    "Skip insurance and even money while learning basic strategy."
                ])
            }
        }
    }
}

private struct MemoryStep: Identifiable {
    let icon: String
    let title: String
    let detail: String
    let tint: Color

    var id: String { title }
}

private struct MemoryStepRow: View {
    let step: MemoryStep

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: step.icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(step.tint)
                .frame(width: 28, height: 28)
                .background(step.tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline.weight(.semibold))
                Text(step.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct RulesReferenceView: View {
    var body: some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 16) {
                InfoPanel(title: "Goal") {
                    Text("Beat the dealer by finishing closer to 21 without going over. If both totals tie, the hand pushes and the bet is returned.")
                        .foregroundStyle(.secondary)
                }
                InfoPanel(title: "Card values") {
                    BulletList(items: [
                        "Number cards count as their number.",
                        "10, J, Q, and K count as 10.",
                        "Ace counts as 1 or 11, whichever helps without busting."
                    ])
                }
                InfoPanel(title: "Player actions") {
                    BulletList(items: [
                        "Hit: take another card.",
                        "Stand: stop with the current total.",
                        "Double: double the bet, take one final card, then stand.",
                        "Split: if the first two cards have the same blackjack value, make two hands with a second equal bet.",
                        "Surrender: only if the table offers late surrender, give up half the bet before another action."
                    ])
                }
                InfoPanel(title: "Dealer and payouts") {
                    BulletList(items: [
                        "Dealer reveals the hole card after player decisions.",
                        "H17 means the dealer hits soft 17; S17 means the dealer stands.",
                        "Blackjack is ace plus a 10-value card as the first two cards.",
                        "3:2 blackjack payouts are better than 6:5 payouts.",
                        "Insurance is a separate side bet against a dealer ace; beginner strategy skips it."
                    ])
                }
                AppearanceControl()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Rules")
    }
}
