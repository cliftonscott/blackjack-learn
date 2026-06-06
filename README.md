# Blackjack Learn

A local-only Blackjack learning app for rules, valid moves, and beginner
strategy practice. It includes a native iOS app and a browser-based prototype.
It is a personal study tool: no backend, no deploy, no auth, no analytics, and
no real-money gambling.

## Start

### Native iOS app

Open the Xcode project:

```bash
cd blackjack-learn
open BlackjackLearn.xcodeproj
```

To run on your iPhone:

1. Connect the iPhone by USB or make sure it is available for wireless Xcode
   development.
2. In Xcode, select the `BlackjackLearn` scheme.
3. Select your iPhone as the run destination.
4. Open the target's **Signing & Capabilities** tab, choose your Apple ID team,
   and let Xcode manage signing.
5. If Xcode says the bundle identifier is already taken, change
   `com.local.blackjacklearn` to any unique personal identifier.
6. Press Run. If iOS asks you to trust the developer profile, approve it in
   Settings on the phone.

Simulator build check:

```bash
cd blackjack-learn
xcodebuild -project BlackjackLearn.xcodeproj \
  -scheme BlackjackLearn \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### Local web app

Open directly:

```bash
open blackjack-learn/index.html
```

Or run a local server:

```bash
cd blackjack-learn
python3 -m http.server 5174
```

Then open:

```text
http://localhost:5174
```

## Practice table assumptions

Blackjack rules vary by casino and table. This app labels variants explicitly
and uses these assumptions for practice feedback:

- Dealer hits soft 17 (`H17`).
- Blackjack pays `3:2`.
- Doubling is allowed on the first two cards.
- Splitting is allowed on two cards with the same blackjack value.
- Rule controls can switch H17/S17, 3:2/6:5 payout, DAS examples, and late
  surrender.
- Surrender is legal only when the late-surrender rule is enabled.
- Insurance is explained but not offered as a practice action.
- Native Practice uses a local shuffled six-deck shoe and skips dealt player
  blackjacks so each hand has a decision.
- Split practice is a one-decision drill; it confirms legality and strategy
  rather than playing out both split hands.
- Strategy prompts use beginner/basic-strategy examples, not card counting.

## What is covered

- Native iOS app with Learn, Practice, Strategy, and Rules tabs.
- Native Strategy tab has separate charts for hard totals, soft hands, and pairs.
- Native appearance support with System, Light, and Dark modes.
- Rules reference: goal, card values, turn flow, hit, stand, double, split,
  dealer resolution, blackjack payout, push, insurance, and common table rules.
- Guided tutorial from card values through hard totals, soft hands, pairs, and
  table-rule checks.
- Native Practice mode deals random hands from a local shuffled six-deck shoe,
  hides the dealer hole card, and gives immediate feedback for legal moves,
  illegal moves, and legal-but-not-recommended strategy choices.
- Practice draws hit, double, and dealer-resolution cards from the same shoe;
  Replay restores the same starting hand and draw order.
- Dealer resolution in native Practice follows the selected H17/S17 rule after
  stand or double. Split practice remains a one-decision drill.
- Basic strategy drills with local score, streak, legality feedback, and saved
  misses.
- Interactive strategy chart for hard totals, soft hands, and pairs under the
  selected table rules.
- Local-only recent-attempt review for practice decisions.
- Strategy primer for hard totals, soft hands, pairs, dealer upcards, insurance,
  bankroll discipline, and common beginner mistakes.

## Rule and strategy source spot-check

Primary rule source:

```text
https://bicyclecards.com/how-to-play/blackjack
```

Strategy and variation sources:

```text
https://wizardofodds.com/games/blackjack/basics/
https://www.blackjackapprenticeship.com/wp-content/uploads/2024/09/H17-Basic-Strategy.pdf
```

Spot-checked claims used by the app:

1. The goal is to beat the dealer by getting closer to 21 without busting.
2. Face cards count as 10, aces count as 1 or 11, and number cards use pip value.
3. Common player actions include hit, stand, double down, and split.
4. A blackjack is an ace plus a 10-value card and commonly pays 3:2.
5. Insurance is offered only against a dealer ace and is a separate side bet.
6. Beginner strategy sources recommend always splitting aces and eights and not
   taking insurance/even money.
7. Rule variations such as H17 vs S17, double after split, surrender, and 6:5
   blackjack payouts change the quality of a table; this app labels them.

## Local verification checklist

Native Practice smoke:

```bash
cd blackjack-learn
xcodebuild -project BlackjackLearn.xcodeproj \
  -scheme BlackjackLearn \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Then run the app in Xcode or Simulator:

- Open Practice; it should show a random six-deck shoe with 308 cards left after
  the initial four-card deal.
- Confirm the dealer hole card is hidden until the hand resolves.
- Attempt Split on a non-pair; it should reject the move and increment Illegal.
- Hit, Stand, or Double; drawn cards should reduce the shoe count and update the
  hand from the same shoe.
- Tap Replay; the same starting hand and draw order should return.

Local web app smoke:

```bash
ls blackjack-learn
cd blackjack-learn
python3 -m http.server 5174
```

Then verify in the browser:

- Tutorial: open Tutorial and click Next through Complete.
- Practice illegal split: scenario `Hard 16 vs dealer 10`, click Split. It
  should reject because the hand is not a pair or same-value pair.
- Practice illegal double: same scenario, click Hit, then Double. It should
  reject because doubling is only available before taking another card.
- Practice legal-but-bad move: scenario `Pair of 8s vs dealer 9`, click Hit.
  It should accept the move as legal but explain that split is the recommended
  beginner strategy.
- Practice recommended move: scenario `Hard 11 vs dealer 6`, click Double. It
  should accept, draw one card, reveal the dealer, resolve the round, and
  explain the recommendation.
- Rule toggle: enable late surrender, then scenario `Hard 16 vs dealer 10`
  should recommend Surrender.
- Drills: answer `Pair of 8s vs 9` with Hit. It should record a strategy miss
  and show the miss in Review.
- Chart: open Chart and click any cell. The detail panel should show the
  selected hand, dealer upcard, current rules, and explanation.
