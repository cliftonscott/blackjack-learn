import Foundation

enum BlackjackStrategy {
    static func dealerValue(_ card: PlayingCard) -> Int {
        card.rank == .ace ? 11 : min(card.rank.blackjackValue, 10)
    }

    static func legality(
        of action: MoveAction,
        hand: BlackjackHand,
        rules: TableRules,
        hasMoved: Bool,
        isEnded: Bool
    ) -> MoveLegality {
        if isEnded || hand.value.isBust || hand.value.isBlackjack {
            return MoveLegality(legal: false, reason: "This hand is already resolved.")
        }

        switch action {
        case .hit, .stand:
            return MoveLegality(legal: true, reason: "This is a legal table action.")
        case .doubleDown:
            if hasMoved || hand.cards.count != 2 {
                return MoveLegality(legal: false, reason: "Double is available only as the first decision on a two-card hand.")
            }
            return MoveLegality(legal: true, reason: "Double is legal before taking another card.")
        case .split:
            if hasMoved || hand.cards.count != 2 {
                return MoveLegality(legal: false, reason: "Split is available only as the first decision on a two-card hand.")
            }
            if !hand.canSplit {
                return MoveLegality(legal: false, reason: "Split requires two cards with the same blackjack value.")
            }
            return MoveLegality(legal: true, reason: "Split is legal for this pair.")
        case .surrender:
            if !rules.lateSurrender {
                return MoveLegality(legal: false, reason: "Late surrender is off for the current practice table.")
            }
            if hasMoved || hand.cards.count != 2 {
                return MoveLegality(legal: false, reason: "Surrender is available only as the first decision on a two-card hand.")
            }
            return MoveLegality(legal: true, reason: "Late surrender is legal before any other action.")
        }
    }

    static func recommendation(
        for hand: BlackjackHand,
        dealerUpcard: PlayingCard,
        rules: TableRules
    ) -> StrategyRecommendation {
        let dealer = dealerValue(dealerUpcard)

        if hand.canSplit {
            let value = hand.cards[0].splitValue
            if hand.cards[0].rank == .ace || value == 8 {
                return explain(.split, "Beginner strategy splits aces and eights against every upcard.")
            }
            if value == 10 {
                return explain(.stand, "A 20 is already strong. Do not split 10-value hands.")
            }
            if value == 9 {
                return explain([2, 3, 4, 5, 6, 8, 9].contains(dealer) ? .split : .stand, "Split 9s against 2-6, 8, and 9; otherwise stand.")
            }
            if value == 7 {
                return explain((2...7).contains(dealer) ? .split : .hit, "Split 7s against 2-7 and hit against stronger upcards.")
            }
            if value == 6 {
                let shouldSplit = rules.doubleAfterSplit ? (2...6).contains(dealer) : (3...6).contains(dealer)
                return explain(shouldSplit ? .split : .hit, "Split 6s against weak dealer cards; without DAS, dealer 2 is usually a hit.")
            }
            if value == 5 {
                return hardTotalStrategy(total: 10, dealerUpcard: dealerUpcard, rules: rules, prefix: "Treat 5-5 as hard 10.")
            }
            if value == 4 {
                let shouldSplit = rules.doubleAfterSplit && (dealer == 5 || dealer == 6)
                return explain(shouldSplit ? .split : .hit, "Split 4s only when DAS is available against 5 or 6.")
            }
            if value == 2 || value == 3 {
                let shouldSplit = rules.doubleAfterSplit ? (2...7).contains(dealer) : (4...7).contains(dealer)
                return explain(shouldSplit ? .split : .hit, "Split 2s and 3s against 2-7 with DAS, or 4-7 without DAS.")
            }
        }

        let value = hand.value
        if value.isSoft {
            return softTotalStrategy(total: value.total, dealer: dealer, rules: rules)
        }

        return hardTotalStrategy(total: value.total, dealerUpcard: dealerUpcard, rules: rules)
    }

    private static func explain(_ action: MoveAction, _ reason: String) -> StrategyRecommendation {
        StrategyRecommendation(action: action, reason: reason)
    }

    private static func hardTotalStrategy(
        total: Int,
        dealerUpcard: PlayingCard,
        rules: TableRules,
        prefix: String = ""
    ) -> StrategyRecommendation {
        let dealer = dealerValue(dealerUpcard)
        let preface = prefix.isEmpty ? "" : "\(prefix) "

        if total >= 17 {
            return explain(.stand, "\(preface)Hard \(total) is strong enough to stand.")
        }
        if total == 16 {
            if rules.lateSurrender && [9, 10, 11].contains(dealer) {
                return explain(.surrender, "\(preface)Late surrender is best for hard 16 against 9, 10, or ace when available.")
            }
            return explain((2...6).contains(dealer) ? .stand : .hit, "\(preface)Hard 16 stands against 2-6 and hits against 7-A if surrender is unavailable.")
        }
        if total == 15 {
            if rules.lateSurrender && dealer == 10 {
                return explain(.surrender, "\(preface)Late surrender is best for hard 15 against dealer 10 when available.")
            }
            return explain((2...6).contains(dealer) ? .stand : .hit, "\(preface)Hard 15 stands against 2-6 and hits against stronger upcards.")
        }
        if (13...14).contains(total) {
            return explain((2...6).contains(dealer) ? .stand : .hit, "\(preface)Hard \(total) stands against 2-6 and hits against 7-A.")
        }
        if total == 12 {
            return explain((4...6).contains(dealer) ? .stand : .hit, "\(preface)Hard 12 stands against 4-6 and hits otherwise.")
        }
        if total == 11 {
            if dealerUpcard.rank == .ace && rules.dealerSoft17 == .stand {
                return explain(.hit, "\(preface)With S17, hard 11 against ace is usually hit rather than double.")
            }
            return explain(.doubleDown, "\(preface)Hard 11 is a strong double spot.")
        }
        if total == 10 {
            return explain((2...9).contains(dealer) ? .doubleDown : .hit, "\(preface)Hard 10 doubles against 2-9 and hits against 10 or ace.")
        }
        if total == 9 {
            return explain((3...6).contains(dealer) ? .doubleDown : .hit, "\(preface)Hard 9 doubles against 3-6 and hits otherwise.")
        }

        return explain(.hit, "\(preface)Hard \(total) is too low to stand.")
    }

    private static func softTotalStrategy(
        total: Int,
        dealer: Int,
        rules: TableRules
    ) -> StrategyRecommendation {
        if total >= 20 {
            return explain(.stand, "Soft \(total) is strong enough to stand.")
        }
        if total == 19 {
            let action: MoveAction = rules.dealerSoft17 == .hit && dealer == 6 ? .doubleDown : .stand
            return explain(action, "Soft 19 usually stands; H17 charts often double against 6.")
        }
        if total == 18 {
            if (3...6).contains(dealer) { return explain(.doubleDown, "Soft 18 doubles against dealer 3-6.") }
            if dealer == 2 && rules.dealerSoft17 == .hit { return explain(.doubleDown, "On H17 tables, soft 18 can double against dealer 2.") }
            if dealer == 2 { return explain(.stand, "On S17 tables, soft 18 stands against dealer 2.") }
            if dealer == 7 || dealer == 8 { return explain(.stand, "Soft 18 stands against dealer 7 or 8.") }
            return explain(.hit, "Soft 18 hits against dealer 9, 10, or ace.")
        }
        if total == 17 {
            return explain((3...6).contains(dealer) ? .doubleDown : .hit, "Soft 17 doubles against 3-6 and hits otherwise.")
        }
        if total == 16 || total == 15 {
            return explain((4...6).contains(dealer) ? .doubleDown : .hit, "Soft \(total) doubles against 4-6 and hits otherwise.")
        }
        if total == 14 || total == 13 {
            return explain((5...6).contains(dealer) ? .doubleDown : .hit, "Soft \(total) doubles against 5-6 and hits otherwise.")
        }

        return explain(.hit, "Soft \(total) is too low to stand.")
    }
}

