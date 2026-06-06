import SwiftUI

struct PracticeStatsRow: View {
    let stats: PracticeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StatSectionHeader(title: "Decisions", detail: "Move accuracy")
            HStack(spacing: 6) {
                MiniStat(title: "Acc", value: stats.accuracyLabel)
                MiniStat(title: "Streak", value: "\(stats.streak)")
                MiniStat(title: "Good", value: "\(stats.correct)")
                MiniStat(title: "Illegal", value: "\(stats.illegalMoves)")
            }

            StatSectionHeader(title: "Hands", detail: "All resolved / \(stats.handWinRateLabel) win")
            OutcomeStatGrid(
                hands: stats.resolvedHands,
                wins: stats.wonHands,
                losses: stats.lostHands,
                pushes: stats.pushedHands
            )

            StatSectionHeader(title: "Clean hands", detail: "No hint, illegal move, or miss / \(stats.cleanHandWinRateLabel) win")
            OutcomeStatGrid(
                hands: stats.cleanResolvedHands,
                wins: stats.cleanWonHands,
                losses: stats.cleanLostHands,
                pushes: stats.cleanPushedHands
            )

            Text("Split drills stop before branch play, so they are not counted as hand wins or losses.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct StatSectionHeader: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer(minLength: 0)
        }
    }
}

private struct OutcomeStatGrid: View {
    let hands: Int
    let wins: Int
    let losses: Int
    let pushes: Int

    var body: some View {
        HStack(spacing: 6) {
            MiniStat(title: "Hands", value: "\(hands)")
            MiniStat(title: "Win", value: "\(wins)")
            MiniStat(title: "Lose", value: "\(losses)")
            MiniStat(title: "Push", value: "\(pushes)")
        }
    }
}

private struct MiniStat: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.caption.weight(.bold).monospacedDigit())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CardRow: View {
    let title: String
    let cards: [PlayingCard]
    var showHiddenDealerCard = false

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        if showHiddenDealerCard && index > 0 {
                            HiddenCardTile(size: 54)
                        } else {
                            CardTile(card: card, size: 54)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct PracticeFeltSurface<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                Color(red: 15 / 255, green: 91 / 255, blue: 70 / 255)
                LinearGradient(
                    colors: [.white.opacity(0.08), .black.opacity(0.10)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 11 / 255, green: 62 / 255, blue: 49 / 255), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }
}

struct PracticeTableIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.callout.weight(.bold))
                .frame(width: 34, height: 32)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(.black.opacity(isDisabled ? 0.18 : 0.34))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(isDisabled ? 0.10 : 0.22), lineWidth: 1)
        }
        .opacity(isDisabled ? 0.48 : 1)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct HiddenCardTile: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 35 / 255, green: 57 / 255, blue: 93 / 255))
            LinearGradient(
                colors: [.white.opacity(0.18), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 159 / 255, green: 176 / 255, blue: 209 / 255), lineWidth: 2)
            Image(systemName: "questionmark")
                .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size * 1.32)
        .accessibilityLabel("Hidden dealer card")
    }
}

struct FeedbackBanner: View {
    let feedback: TrainerFeedback

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: feedback.tone.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(feedback.tone.color)
                .frame(width: 24, height: 24)
                .background(feedback.tone.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(feedback.title)
                        .font(.callout.weight(.semibold))
                    Text(feedback.tone.subtitle)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(feedback.tone.color)
                }
                Text(feedback.copy)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(feedback.note)
                    .font(.caption)
                    .foregroundStyle(feedback.tone.color)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(feedback.tone.color.opacity(0.22), lineWidth: 1)
        }
    }
}

struct PracticeControlsPanel: View {
    @Binding var rules: TableRules
    @Binding var isExpanded: Bool
    let rulesSummary: String
    let shoeLabel: String
    let remainingCount: Int
    let dealNewHand: () -> Void
    let shuffleShoe: () -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                CompactRuleControls(rules: $rules)
                HStack(spacing: 8) {
                    Button {
                        dealNewHand()
                    } label: {
                        Label("New hand", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        shuffleShoe()
                    } label: {
                        Label("Shuffle", systemImage: "arrow.2.squarepath")
                    }
                    .buttonStyle(.bordered)
                }
                .font(.callout.weight(.semibold))
            }
            .padding(.top, 10)
        } label: {
            HStack(spacing: 8) {
                Label("Table & shoe", systemImage: "slider.horizontal.3")
                    .font(.callout.weight(.semibold))
                Spacer(minLength: 0)
                Text("\(remainingCount) cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 1)
        }
        .accessibilityHint("\(shoeLabel). \(rulesSummary)")
    }
}

private struct CompactRuleControls: View {
    @Binding var rules: TableRules

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Dealer", selection: $rules.dealerSoft17) {
                ForEach(DealerSoft17.allCases) { option in
                    Text(option.shortLabel).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Picker("Blackjack", selection: $rules.blackjackPayout) {
                ForEach(BlackjackPayout.allCases) { payout in
                    Text(payout.label).tag(payout)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Double after split", isOn: $rules.doubleAfterSplit)
            Toggle("Late surrender", isOn: $rules.lateSurrender)
        }
        .font(.callout)
    }
}

struct RecentAttemptsPanel: View {
    let attempts: [PracticeAttempt]
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(attempts) { attempt in
                    AttemptRow(attempt: attempt)
                }
            }
            .padding(.top, 10)
        } label: {
            HStack {
                Label("Recent", systemImage: "clock")
                    .font(.callout.weight(.semibold))
                Spacer()
                Text("\(attempts.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct AttemptRow: View {
    let attempt: PracticeAttempt

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: attempt.tone.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(attempt.tone.color)
                .frame(width: 22, height: 22)
                .background(attempt.tone.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(attempt.handTitle)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Text("\(attempt.result): \(attempt.selectedMove.label), best \(attempt.recommendedMove.label).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(attempt.note)
                    .font(.caption)
                    .foregroundStyle(attempt.tone.color)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
    }
}
