import SwiftUI

enum FeedbackTone {
    case neutral
    case correct
    case warning
    case error

    var subtitle: String {
        switch self {
        case .neutral: "Practice"
        case .correct: "Correct"
        case .warning: "Strategy miss"
        case .error: "Illegal move"
        }
    }

    var color: Color {
        switch self {
        case .neutral: .blue
        case .correct: .green
        case .warning: .orange
        case .error: .red
        }
    }

    var icon: String {
        switch self {
        case .neutral: "info"
        case .correct: "checkmark"
        case .warning: "exclamationmark"
        case .error: "xmark"
        }
    }
}

struct TrainerFeedback {
    let title: String
    let copy: String
    let note: String
    let tone: FeedbackTone
}

enum PracticeHandOutcome {
    case win
    case loss
    case push
}

struct PracticeStats {
    var legalDecisions = 0
    var correct = 0
    var strategyMisses = 0
    var illegalMoves = 0
    var streak = 0
    var resolvedHands = 0
    var wonHands = 0
    var lostHands = 0
    var pushedHands = 0
    var cleanResolvedHands = 0
    var cleanWonHands = 0
    var cleanLostHands = 0
    var cleanPushedHands = 0

    var accuracyLabel: String {
        guard legalDecisions > 0 else { return "0%" }
        let accuracy = Double(correct) / Double(legalDecisions)
        return "\(Int((accuracy * 100).rounded()))%"
    }

    var handWinRateLabel: String {
        percentageLabel(count: wonHands, total: resolvedHands)
    }

    var cleanHandWinRateLabel: String {
        percentageLabel(count: cleanWonHands, total: cleanResolvedHands)
    }

    mutating func recordLegalMove(matchesRecommendation: Bool) {
        legalDecisions += 1
        if matchesRecommendation {
            correct += 1
            streak += 1
        } else {
            strategyMisses += 1
            streak = 0
        }
    }

    mutating func recordIllegalMove() {
        illegalMoves += 1
        streak = 0
    }

    mutating func recordHandOutcome(_ outcome: PracticeHandOutcome, cleanlyPlayed: Bool) {
        resolvedHands += 1
        switch outcome {
        case .win:
            wonHands += 1
        case .loss:
            lostHands += 1
        case .push:
            pushedHands += 1
        }

        guard cleanlyPlayed else { return }
        cleanResolvedHands += 1
        switch outcome {
        case .win:
            cleanWonHands += 1
        case .loss:
            cleanLostHands += 1
        case .push:
            cleanPushedHands += 1
        }
    }

    private func percentageLabel(count: Int, total: Int) -> String {
        guard total > 0 else { return "0%" }
        let percentage = Double(count) / Double(total)
        return "\(Int((percentage * 100).rounded()))%"
    }
}

struct PracticeAttempt: Identifiable {
    let id = UUID()
    let handTitle: String
    let selectedMove: MoveAction
    let recommendedMove: MoveAction
    let result: String
    let note: String
    let tone: FeedbackTone
}

private struct DealerResolution {
    let copy: String
    let note: String
    let outcome: PracticeHandOutcome
}

struct PracticeTrainerView: View {
    @Binding var rules: TableRules
    @State private var shoe = BlackjackShoe()
    @State private var shoeAtHandStart = BlackjackShoe()
    @State private var handNumber = 0
    @State private var playerCards: [PlayingCard] = []
    @State private var dealerCards: [PlayingCard] = []
    @State private var hasMoved = false
    @State private var isEnded = false
    @State private var showHint = false
    @State private var showControls = false
    @State private var showHistory = false
    @State private var revealedRecommendation: StrategyRecommendation?
    @State private var stats = PracticeStats()
    @State private var recentAttempts: [PracticeAttempt] = []
    @State private var currentHandHadStrategyMiss = false
    @State private var currentHandHadIllegalMove = false
    @State private var currentHandUsedHint = false
    @State private var currentHandOutcomeRecorded = false
    @State private var feedback = TrainerFeedback(
        title: "Deal a random hand",
        copy: "Practice deals from a shuffled local shoe.",
        note: "Choose before revealing the answer.",
        tone: .neutral
    )

    private var hasActiveHand: Bool {
        playerCards.count >= 2 && !dealerCards.isEmpty
    }

    private var hand: BlackjackHand {
        BlackjackHand(cards: playerCards)
    }

    private var dealerHand: BlackjackHand {
        BlackjackHand(cards: dealerCards)
    }

    private var dealerUpcard: PlayingCard {
        dealerCards.first ?? .c(.ace, .spades)
    }

    private var recommendation: StrategyRecommendation {
        guard hasActiveHand else {
            return StrategyRecommendation(action: .hit, reason: "Deal a random hand before choosing a move.")
        }
        return BlackjackStrategy.recommendation(for: hand, dealerUpcard: dealerUpcard, rules: rules)
    }

    private var answerIsVisible: Bool {
        showHint || isEnded
    }

    private var displayedRecommendation: StrategyRecommendation {
        revealedRecommendation ?? recommendation
    }

    private var decisionTitle: String {
        guard hasActiveHand else { return "No hand dealt" }
        return "\(hand.value.label) vs dealer \(dealerUpcard.rank.rawValue)"
    }

    private var currentHandIsClean: Bool {
        !currentHandHadStrategyMiss && !currentHandHadIllegalMove && !currentHandUsedHint
    }

    var body: some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 12) {
                tableView
                controlsPanel
                recentAttemptsPanel
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Practice")
        .onAppear {
            if !hasActiveHand {
                dealNewHand()
            }
        }
        .onChange(of: rules) { _, _ in refreshFeedbackForRules() }
    }

    private var tableView: some View {
        InfoPanel(title: hasActiveHand ? decisionTitle : "Random hand", subtitle: hasActiveHand ? nil : tableProgressLabel) {
            VStack(alignment: .leading, spacing: 12) {
                PracticeStatsRow(stats: stats)

                if hasActiveHand {
                    PracticeFeltSurface {
                        tableHeader
                        cardSection
                    }

                    actionGrid
                    FeedbackBanner(feedback: feedback)
                } else {
                    Button {
                        dealNewHand()
                    } label: {
                        Label("Deal", systemImage: "shuffle")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private var tableProgressLabel: String {
        handNumber == 0 ? "6-deck shoe" : "Hand \(handNumber) / \(shoe.remainingCount) cards"
    }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text(tableProgressLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 0)

            PracticeTableIconButton(
                systemImage: "lightbulb",
                accessibilityLabel: answerIsVisible ? "Hint shown" : "Show hint",
                isDisabled: answerIsVisible,
                action: revealHint
            )
            PracticeTableIconButton(
                systemImage: "arrow.counterclockwise",
                accessibilityLabel: "Replay hand",
                isDisabled: false,
                action: replayHand
            )
        }
    }

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardRow(
                title: isEnded ? "Dealer: \(dealerHand.value.label)" : "Dealer",
                cards: dealerCards,
                showHiddenDealerCard: !isEnded
            )
            CardRow(title: "You: \(hand.value.label)", cards: playerCards)
        }
    }

    private var actionGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 8
        ) {
            ForEach(MoveAction.allCases) { action in
                MoveButton(action: action, isRecommended: answerIsVisible && action == displayedRecommendation.action) {
                    perform(action)
                }
                .disabled(!hasActiveHand || isEnded)
            }
            Button {
                dealNewHand()
            } label: {
                Label("Deal", systemImage: "shuffle")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private var controlsPanel: some View {
        PracticeControlsPanel(
            rules: $rules,
            isExpanded: $showControls,
            rulesSummary: rules.summary,
            shoeLabel: shoe.label,
            remainingCount: shoe.remainingCount,
            dealNewHand: dealNewHand,
            shuffleShoe: shuffleShoeAndDeal
        )
    }

    @ViewBuilder
    private var recentAttemptsPanel: some View {
        if !recentAttempts.isEmpty {
            RecentAttemptsPanel(
                attempts: recentAttempts,
                isExpanded: $showHistory
            )
        }
    }

    private func perform(_ action: MoveAction) {
        guard hasActiveHand else {
            feedback = TrainerFeedback(
                title: "No hand dealt",
                copy: "Deal a random hand before choosing a move.",
                note: "Practice draws every hand from the local shuffled shoe.",
                tone: .neutral
            )
            return
        }

        let currentRecommendation = recommendation
        let currentDecisionTitle = decisionTitle
        let legality = BlackjackStrategy.legality(
            of: action,
            hand: hand,
            rules: rules,
            hasMoved: hasMoved,
            isEnded: isEnded
        )

        guard legality.legal else {
            currentHandHadIllegalMove = true
            stats.recordIllegalMove()
            recordAttempt(
                handTitle: currentDecisionTitle,
                selectedAction: action,
                recommendedAction: currentRecommendation.action,
                result: "Illegal",
                note: legality.reason,
                tone: .error
            )
            feedback = TrainerFeedback(
                title: "Illegal \(action.label)",
                copy: legality.reason,
                note: "Try a legal move first; strategy comes after legality.",
                tone: .error
            )
            return
        }

        let matches = action == currentRecommendation.action
        if !matches {
            currentHandHadStrategyMiss = true
        }
        stats.recordLegalMove(matchesRecommendation: matches)
        recordAttempt(
            handTitle: currentDecisionTitle,
            selectedAction: action,
            recommendedAction: currentRecommendation.action,
            result: matches ? "Correct" : "Miss",
            note: matches ? currentRecommendation.reason : "Best move: \(currentRecommendation.action.label)",
            tone: matches ? .correct : .warning
        )

        switch action {
        case .hit:
            applyHit(matches: matches, recommendation: currentRecommendation)
        case .stand:
            applyStand(matches: matches, recommendation: currentRecommendation)
        case .doubleDown:
            applyDouble(matches: matches, recommendation: currentRecommendation)
        case .split:
            endDecisionOnlyHand(
                title: matches ? "Correct split" : "Legal split, strategy miss",
                copy: "You split the pair into two separate hands.",
                matches: matches,
                recommendation: currentRecommendation,
                fallbackNote: "Split practice stops at the first decision, so it is not counted in win/loss hand stats."
            )
        case .surrender:
            endDecisionOnlyHand(
                title: matches ? "Correct surrender" : "Legal surrender, strategy miss",
                copy: "You surrendered and gave up half the bet.",
                matches: matches,
                recommendation: currentRecommendation,
                fallbackNote: "Surrender ends the hand immediately and counts as a loss in hand stats.",
                outcome: .loss
            )
        }
    }

    private func applyHit(matches: Bool, recommendation: StrategyRecommendation) {
        let card = nextDrawCard()
        playerCards.append(card)
        hasMoved = true
        showHint = false
        revealedRecommendation = nil

        let newHand = BlackjackHand(cards: playerCards)
        if newHand.value.isBust {
            isEnded = true
            revealedRecommendation = recommendation
            recordHandOutcome(.loss)
            feedback = TrainerFeedback(
                title: matches ? "Correct hit, then bust" : "Legal hit, strategy miss",
                copy: "You drew \(card.label) and busted at \(newHand.value.total).",
                note: matches ? recommendation.reason : "Basic strategy preferred \(recommendation.action.label). \(recommendation.reason)",
                tone: matches ? .correct : .warning
            )
            return
        }

        feedback = TrainerFeedback(
            title: matches ? "Correct hit" : "Legal hit, strategy miss",
            copy: "You drew \(card.label). Your new hand is \(newHand.value.label).",
            note: matches ? "Now make the next decision." : "Basic strategy preferred \(recommendation.action.label). \(recommendation.reason)",
            tone: matches ? .correct : .warning
        )
    }

    private func applyStand(matches: Bool, recommendation: StrategyRecommendation) {
        hasMoved = true
        isEnded = true
        revealedRecommendation = recommendation
        let resolution = resolveDealerRound()
        recordHandOutcome(resolution.outcome)
        feedback = TrainerFeedback(
            title: matches ? "Correct stand" : "Legal stand, strategy miss",
            copy: "You stood on \(hand.value.label). \(resolution.copy)",
            note: matches ? "\(recommendation.reason) \(resolution.note)" : "Basic strategy preferred \(recommendation.action.label). \(recommendation.reason) \(resolution.note)",
            tone: matches ? .correct : .warning
        )
    }

    private func applyDouble(matches: Bool, recommendation: StrategyRecommendation) {
        let card = nextDrawCard()
        playerCards.append(card)
        hasMoved = true
        isEnded = true
        revealedRecommendation = recommendation

        if hand.value.isBust {
            recordHandOutcome(.loss)
            feedback = TrainerFeedback(
                title: matches ? "Correct double, then bust" : "Legal double, strategy miss",
                copy: "You doubled, drew \(card.label), and busted at \(hand.value.total).",
                note: matches ? recommendation.reason : "Double was legal, but basic strategy preferred \(recommendation.action.label). \(recommendation.reason)",
                tone: matches ? .correct : .warning
            )
            return
        }

        let resolution = resolveDealerRound()
        recordHandOutcome(resolution.outcome)
        feedback = TrainerFeedback(
            title: matches ? "Correct double" : "Legal double, strategy miss",
            copy: "You doubled, drew \(card.label), and stopped at \(hand.value.label). \(resolution.copy)",
            note: matches ? "\(recommendation.reason) \(resolution.note)" : "Double was legal, but basic strategy preferred \(recommendation.action.label). \(recommendation.reason) \(resolution.note)",
            tone: matches ? .correct : .warning
        )
    }

    private func endDecisionOnlyHand(
        title: String,
        copy: String,
        matches: Bool,
        recommendation: StrategyRecommendation,
        fallbackNote: String,
        outcome: PracticeHandOutcome? = nil
    ) {
        hasMoved = true
        isEnded = true
        revealedRecommendation = recommendation
        if let outcome {
            recordHandOutcome(outcome)
        }
        feedback = TrainerFeedback(
            title: title,
            copy: copy,
            note: matches ? "\(recommendation.reason) \(fallbackNote)" : "Basic strategy preferred \(recommendation.action.label). \(recommendation.reason)",
            tone: matches ? .correct : .warning
        )
    }

    private func nextDrawCard() -> PlayingCard {
        shoe.drawCard()
    }

    private func revealHint() {
        guard hasActiveHand else { return }
        currentHandUsedHint = true
        showHint = true
        revealedRecommendation = recommendation
        feedback = TrainerFeedback(
            title: "Hint",
            copy: "Best move: \(recommendation.action.label).",
            note: recommendation.reason,
            tone: .neutral
        )
    }

    private func dealNewHand() {
        let deal = drawDecisionDeal()
        handNumber += 1
        load(deal, title: "Random hand dealt", note: "Choose a move or reveal a hint.")
    }

    private func replayHand() {
        guard handNumber > 0 else { return }
        shoe = shoeAtHandStart
        let deal = shoe.drawInitialDeal()
        load(deal, title: "Hand replayed", note: "Same starting cards and draw order restored.")
    }

    private func shuffleShoeAndDeal() {
        shoe.shuffleNewShoe()
        let deal = drawDecisionDeal()
        handNumber += 1
        load(deal, title: "Shoe shuffled", note: "Fresh \(shoe.label.lowercased()).")
    }

    private func drawDecisionDeal() -> BlackjackDeal {
        var attempts = 0
        while true {
            if shoe.shouldShuffleBeforeNewHand {
                shoe.shuffleNewShoe()
            }
            shoeAtHandStart = shoe
            let deal = shoe.drawInitialDeal()
            attempts += 1
            let dealtHand = BlackjackHand(cards: deal.playerCards)
            if !dealtHand.value.isBlackjack || attempts >= 12 {
                return deal
            }
        }
    }

    private func load(_ deal: BlackjackDeal, title: String, note: String) {
        playerCards = deal.playerCards
        dealerCards = deal.dealerCards
        hasMoved = false
        showHint = false
        revealedRecommendation = nil
        currentHandHadStrategyMiss = false
        currentHandHadIllegalMove = false
        currentHandUsedHint = false
        currentHandOutcomeRecorded = false

        if BlackjackHand(cards: deal.playerCards).value.isBlackjack {
            isEnded = true
            recordHandOutcome(.win)
            feedback = TrainerFeedback(
                title: "Blackjack dealt",
                copy: "This random hand was already blackjack.",
                note: "Deal another hand for a decision drill.",
                tone: .correct
            )
        } else {
            isEnded = false
            feedback = TrainerFeedback(
                title: title,
                copy: "\(decisionTitle) from the \(shoe.label.lowercased()).",
                note: note,
                tone: .neutral
            )
        }
    }

    private func refreshFeedbackForRules() {
        guard !hasMoved else { return }
        if showHint {
            revealHint()
        } else {
            feedback = TrainerFeedback(
                title: "Rules updated",
                copy: rules.summary,
                note: "The recommendation may change.",
                tone: .neutral
            )
        }
    }

    private func resolveDealerRound() -> DealerResolution {
        while shouldDealerHit {
            dealerCards.append(nextDrawCard())
        }

        let dealerValue = dealerHand.value
        let playerValue = hand.value
        let dealerCardsLabel = dealerCards.map(\.label).joined(separator: " ")
        let copy = "Dealer finished at \(dealerValue.label) with \(dealerCardsLabel)."
        let note: String
        let outcome: PracticeHandOutcome

        if dealerValue.isBust {
            note = "Dealer busted."
            outcome = .win
        } else if playerValue.total > dealerValue.total {
            note = "Your total won."
            outcome = .win
        } else if playerValue.total < dealerValue.total {
            note = "Dealer total won."
            outcome = .loss
        } else {
            note = "Equal totals push."
            outcome = .push
        }

        return DealerResolution(copy: copy, note: note, outcome: outcome)
    }

    private var shouldDealerHit: Bool {
        let value = dealerHand.value
        if value.total < 17 {
            return true
        }
        return value.total == 17 && value.isSoft && rules.dealerSoft17 == .hit
    }

    private func recordAttempt(
        handTitle: String,
        selectedAction: MoveAction,
        recommendedAction: MoveAction,
        result: String,
        note: String,
        tone: FeedbackTone
    ) {
        recentAttempts.insert(
            PracticeAttempt(
                handTitle: handTitle,
                selectedMove: selectedAction,
                recommendedMove: recommendedAction,
                result: result,
                note: note,
                tone: tone
            ),
            at: 0
        )
        recentAttempts = Array(recentAttempts.prefix(5))
    }

    private func recordHandOutcome(_ outcome: PracticeHandOutcome) {
        guard !currentHandOutcomeRecorded else { return }
        stats.recordHandOutcome(outcome, cleanlyPlayed: currentHandIsClean)
        currentHandOutcomeRecorded = true
    }
}
