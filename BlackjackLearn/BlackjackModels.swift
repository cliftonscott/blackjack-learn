import SwiftUI

enum Suit: String, CaseIterable, Identifiable {
    case hearts
    case diamonds
    case clubs
    case spades

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .hearts: "H"
        case .diamonds: "D"
        case .clubs: "C"
        case .spades: "S"
        }
    }

    var symbolName: String {
        switch self {
        case .hearts: "suit.heart.fill"
        case .diamonds: "suit.diamond.fill"
        case .clubs: "suit.club.fill"
        case .spades: "suit.spade.fill"
        }
    }

    var tint: Color {
        switch self {
        case .hearts, .diamonds: .red
        case .clubs, .spades: .black
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum Rank: String, CaseIterable, Identifiable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"

    var id: String { rawValue }

    var blackjackValue: Int {
        switch self {
        case .two: 2
        case .three: 3
        case .four: 4
        case .five: 5
        case .six: 6
        case .seven: 7
        case .eight: 8
        case .nine: 9
        case .ten, .jack, .queen, .king: 10
        case .ace: 11
        }
    }
}

struct PlayingCard: Identifiable, Hashable {
    let id = UUID()
    let rank: Rank
    let suit: Suit

    var label: String {
        "\(rank.rawValue)\(suit.shortLabel)"
    }

    var splitValue: Int {
        rank == .ace ? 11 : min(rank.blackjackValue, 10)
    }
}

struct HandValue {
    let total: Int
    let isSoft: Bool
    let isBust: Bool
    let isBlackjack: Bool

    var label: String {
        if isBlackjack { return "Blackjack" }
        if isBust { return "Bust \(total)" }
        return "\(isSoft ? "Soft" : "Hard") \(total)"
    }
}

struct BlackjackHand {
    var cards: [PlayingCard]

    var value: HandValue {
        let aceCount = cards.filter { $0.rank == .ace }.count
        var total = cards.reduce(0) { sum, card in
            sum + (card.rank == .ace ? 1 : min(card.rank.blackjackValue, 10))
        }
        var isSoft = false

        if aceCount > 0 && total + 10 <= 21 {
            total += 10
            isSoft = true
        }

        return HandValue(
            total: total,
            isSoft: isSoft,
            isBust: total > 21,
            isBlackjack: cards.count == 2 && total == 21
        )
    }

    var canSplit: Bool {
        guard cards.count == 2 else { return false }
        return cards[0].splitValue == cards[1].splitValue
    }

    var summary: String {
        cards.map(\.label).joined(separator: " ")
    }
}

enum DealerSoft17: String, CaseIterable, Identifiable {
    case hit
    case stand

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hit: "Dealer hits soft 17"
        case .stand: "Dealer stands soft 17"
        }
    }

    var shortLabel: String {
        switch self {
        case .hit: "H17"
        case .stand: "S17"
        }
    }
}

enum BlackjackPayout: String, CaseIterable, Identifiable {
    case threeToTwo
    case sixToFive

    var id: String { rawValue }

    var label: String {
        switch self {
        case .threeToTwo: "3:2"
        case .sixToFive: "6:5"
        }
    }
}

struct TableRules: Equatable {
    var dealerSoft17: DealerSoft17 = .hit
    var blackjackPayout: BlackjackPayout = .threeToTwo
    var doubleAfterSplit: Bool = true
    var lateSurrender: Bool = false

    var summary: String {
        [
            dealerSoft17.shortLabel,
            "Blackjack \(blackjackPayout.label)",
            doubleAfterSplit ? "DAS on" : "DAS off",
            lateSurrender ? "Late surrender on" : "No surrender"
        ].joined(separator: " / ")
    }
}

enum MoveAction: String, CaseIterable, Identifiable {
    case hit
    case stand
    case doubleDown
    case split
    case surrender

    var id: String { rawValue }

    var label: String {
        switch self {
        case .hit: "Hit"
        case .stand: "Stand"
        case .doubleDown: "Double"
        case .split: "Split"
        case .surrender: "Surrender"
        }
    }

    var icon: String {
        switch self {
        case .hit: "plus"
        case .stand: "hand.raised"
        case .doubleDown: "xmark"
        case .split: "arrow.left.and.right"
        case .surrender: "flag"
        }
    }
}

struct StrategyRecommendation {
    let action: MoveAction
    let reason: String
}

struct MoveLegality {
    let legal: Bool
    let reason: String
}

struct BlackjackDeal {
    let playerCards: [PlayingCard]
    let dealerCards: [PlayingCard]
}

struct BlackjackShoe {
    let deckCount: Int
    private(set) var cards: [PlayingCard]

    init(deckCount: Int = 6) {
        let safeDeckCount = max(1, deckCount)
        self.deckCount = safeDeckCount
        self.cards = Self.makeCards(deckCount: safeDeckCount).shuffled()
    }

    var remainingCount: Int { cards.count }

    var label: String {
        deckCount == 1 ? "Single deck" : "\(deckCount)-deck shoe"
    }

    var shouldShuffleBeforeNewHand: Bool {
        remainingCount < max(26, deckCount * 13)
    }

    mutating func shuffleNewShoe() {
        cards = Self.makeCards(deckCount: deckCount).shuffled()
    }

    mutating func drawCard() -> PlayingCard {
        if cards.isEmpty {
            shuffleNewShoe()
        }
        return cards.removeLast()
    }

    mutating func drawInitialDeal() -> BlackjackDeal {
        ensureCards(4)
        let firstPlayerCard = drawCard()
        let dealerUpcard = drawCard()
        let secondPlayerCard = drawCard()
        let dealerHoleCard = drawCard()
        return BlackjackDeal(
            playerCards: [firstPlayerCard, secondPlayerCard],
            dealerCards: [dealerUpcard, dealerHoleCard]
        )
    }

    private mutating func ensureCards(_ neededCount: Int) {
        if cards.count < neededCount {
            shuffleNewShoe()
        }
    }

    private static func makeCards(deckCount: Int) -> [PlayingCard] {
        var cards: [PlayingCard] = []
        for _ in 0..<deckCount {
            for suit in Suit.allCases {
                for rank in Rank.allCases {
                    cards.append(PlayingCard(rank: rank, suit: suit))
                }
            }
        }
        return cards
    }
}

extension PlayingCard {
    static func c(_ rank: Rank, _ suit: Suit) -> PlayingCard {
        PlayingCard(rank: rank, suit: suit)
    }
}
