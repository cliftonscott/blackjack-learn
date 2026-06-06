import SwiftUI

struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let copy: String
    let bullets: [String]
    let example: String
}

private let lessons: [Lesson] = [
    Lesson(
        title: "Table assumptions",
        copy: "Blackjack rules vary. Practice and Strategy let you toggle key table variants.",
        bullets: ["Dealer hits soft 17 by default.", "Blackjack pays 3:2 by default.", "Late surrender starts off."],
        example: "If a table pays 6:5 instead of 3:2, it is a worse table even though the core actions look familiar."
    ),
    Lesson(
        title: "Hard and soft totals",
        copy: "A hard hand has no flexible ace. A soft hand has an ace still counted as 11.",
        bullets: ["A-7 is soft 18.", "10-6 is hard 16.", "Soft hands can often hit without immediately busting."],
        example: "A-7 against dealer 9 usually hits, while hard 18 would stand."
    ),
    Lesson(
        title: "Dealer pressure",
        copy: "The dealer upcard changes your risk. Low upcards are often weaker; 7 through ace apply pressure.",
        bullets: ["Stand more often against dealer 2-6.", "Improve weak hands against dealer 7-A.", "Do not use a simple never-bust rule."],
        example: "Hard 16 against dealer 10 is weak. With surrender off, beginner strategy hits."
    ),
    Lesson(
        title: "Remember the move",
        copy: "When you are unsure, check the hand in this order: pairs, soft hands, then hard totals.",
        bullets: [
            "Dealer 2-6 is weak. Dealer 7-A is strong.",
            "Pairs first: split A,A and 8,8; never split 10s or 5s.",
            "Hard 13-16 stands vs 2-6 and hits vs 7-A; hard 12 stands only vs 4-6."
        ],
        example: "Weak dealer: hold stiff, double good hands. Strong dealer: improve or die trying."
    ),
    Lesson(
        title: "Doubling",
        copy: "Double down means double the bet, take exactly one card, then stand.",
        bullets: ["Hard 11 is often a strong double.", "Hard 10 doubles against 2-9.", "Double is normally a first-decision action."],
        example: "Hard 11 against dealer 6 is a high-confidence double."
    ),
    Lesson(
        title: "Pairs",
        copy: "Splitting turns one pair into two separate hands with a second equal bet.",
        bullets: ["Always split aces and eights in beginner strategy.", "Never split 10-value cards.", "Treat 5-5 as hard 10."],
        example: "8-8 is a bad hard 16, so split it even against strong dealer cards."
    ),
    Lesson(
        title: "Insurance and side bets",
        copy: "Insurance is a separate side bet when the dealer shows an ace.",
        bullets: ["It pays only if the dealer has blackjack.", "Beginner basic strategy skips it.", "Side bets are not needed to learn table play."],
        example: "If the dealer shows ace, avoid insurance and play the hand normally."
    )
]

struct LearnView: View {
    @State private var lessonIndex = 0

    private var lesson: Lesson { lessons[lessonIndex] }

    var body: some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                lessonCard
                progress
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Blackjack Learn")
    }

    private var header: some View {
        InfoPanel(title: "Guided lessons", subtitle: "Short table-ready concepts.") {
            Text("Use these cards to learn legal actions, beginner strategy, and the rule words to check before sitting down.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var lessonCard: some View {
        InfoPanel(title: lesson.title, subtitle: "Lesson \(lessonIndex + 1) of \(lessons.count)") {
            VStack(alignment: .leading, spacing: 12) {
                Text(lesson.copy)
                    .font(.body)
                BulletList(items: lesson.bullets)
                Text("Example: \(lesson.example)")
                    .font(.callout)
                    .foregroundStyle(.blue)
                    .padding(12)
                    .background(.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var progress: some View {
        HStack {
            Button("Back") {
                lessonIndex = max(lessonIndex - 1, 0)
            }
            .disabled(lessonIndex == 0)

            Spacer()

            Text("\(lessonIndex + 1) / \(lessons.count)")
                .foregroundStyle(.secondary)
                .font(.footnote.weight(.semibold))

            Spacer()

            Button(lessonIndex == lessons.count - 1 ? "Restart" : "Next") {
                lessonIndex = lessonIndex == lessons.count - 1 ? 0 : lessonIndex + 1
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 4)
    }
}

struct RuleControls: View {
    @Binding var rules: TableRules

    var body: some View {
        InfoPanel(title: "Chart rules", subtitle: rules.summary) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Dealer soft 17", selection: $rules.dealerSoft17) {
                    ForEach(DealerSoft17.allCases) { option in
                        Text(option.shortLabel).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Blackjack payout", selection: $rules.blackjackPayout) {
                    ForEach(BlackjackPayout.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Double after split", isOn: $rules.doubleAfterSplit)
                Toggle("Late surrender", isOn: $rules.lateSurrender)
            }
        }
    }
}
