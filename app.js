"use strict";

const suits = {
  hearts: "♥",
  diamonds: "♦",
  clubs: "♣",
  spades: "♠"
};

const lessons = [
  {
    title: "Goal",
    body: "Blackjack is a player-versus-dealer game. Your job is to finish closer to 21 than the dealer without going over.",
    bullets: ["Other players do not affect your payout.", "Going over 21 is a bust.", "A push means your bet comes back."],
    example: "If you finish at 19 and the dealer finishes at 18, you win. If both finish at 19, it pushes."
  },
  {
    title: "Card values",
    body: "Number cards use their pip value, face cards count as 10, and aces flex between 1 and 11.",
    bullets: ["A soft hand has an ace counted as 11.", "A hard hand has no flexible ace.", "Soft hands can often take one more card safely."],
    example: "A-7 is soft 18. If you draw a 9, the ace becomes 1 and the hand becomes hard 17."
  },
  {
    title: "First decision",
    body: "Most decisions compare your hand type and total against the dealer upcard.",
    bullets: ["Dealer 2-6 is often weak.", "Dealer 7-A is pressure.", "A legal move can still be the wrong strategy."],
    example: "Hard 16 versus dealer 10 is ugly. With no surrender, beginner strategy hits."
  },
  {
    title: "Hit and stand",
    body: "Hit adds a card. Stand locks your total and sends play to the next hand or dealer.",
    bullets: ["Stand on strong made hands.", "Hit weak hands against strong dealer upcards.", "Do not use 'never bust' as a strategy."],
    example: "Hard 12 stands against 4-6, but hits against 2, 3, or 7-A."
  },
  {
    title: "Double down",
    body: "Double means doubling the bet, taking one card, and stopping. This app allows double only on the first two cards.",
    bullets: ["Hard 10 and 11 are common doubles.", "Some soft hands double against weak dealer cards.", "After hitting, double is no longer available here."],
    example: "Hard 11 against dealer 6 is a classic double."
  },
  {
    title: "Splits",
    body: "Split turns two same-value cards into two hands with a second equal bet.",
    bullets: ["Always split aces and eights in beginner strategy.", "Never split 10-value hands.", "Treat 5-5 like hard 10, usually a double."],
    example: "8-8 against dealer 9 is a split: you escape hard 16 and create two starting hands."
  },
  {
    title: "Table rules",
    body: "Blackjack tables are not all the same. Read the felt before sitting down.",
    bullets: ["3:2 blackjack is much better than 6:5.", "H17 means dealer hits soft 17.", "DAS, surrender, and resplit rules matter."],
    example: "Use the table rule controls to compare H17/S17, 3:2/6:5 payout, DAS, and late surrender."
  },
  {
    title: "Ready to practice",
    body: "Use the trainer to separate legal moves from strategy recommendations.",
    bullets: ["Try an illegal split.", "Try a legal but bad hit.", "Try a recommended double."],
    example: "Complete: go to Practice and test yourself against each scenario."
  }
];

const strategies = [
  {
    title: "Hard totals",
    body: "Hard hands do not have a flexible ace. The key is whether the dealer is weak enough to let stand.",
    example: "Hard 13-16 stands against dealer 2-6, but hits against 7-A. Hard 12 is fussier: stand against 4-6, hit otherwise."
  },
  {
    title: "Soft hands",
    body: "A soft hand has an ace still counting as 11. Because the ace can fall back to 1, soft doubles can be powerful.",
    example: "A-7 against dealer 6 is a double on the H17 chart. If double is not allowed, stand or hit depends on the exact total."
  },
  {
    title: "Pairs",
    body: "Pairs are not just two-card totals. Split decisions consider future hand quality.",
    example: "Always split A-A and 8-8 in beginner strategy. Never split 10s; a 20 is already strong."
  },
  {
    title: "Dealer upcard pressure",
    body: "Dealer 2-6 is often a busting position. Dealer 7-A pressures you to improve more often.",
    example: "Hard 16 versus dealer 5 stands. Hard 16 versus dealer 10 hits if surrender is not available."
  },
  {
    title: "Insurance",
    body: "Insurance is a separate side bet that the dealer has blackjack. It is usually not part of beginner strategy.",
    example: "Even when you have a good hand, the insurance bet is evaluated separately. Beginner rule: skip it."
  },
  {
    title: "Table-rule variants",
    body: "Good strategy depends on the table. H17, S17, DAS, surrender, and blackjack payout can change decisions.",
    example: "A 6:5 blackjack payout is a major downgrade compared with 3:2. This app labels it as a variant to avoid."
  }
];

const scenarios = [
  {
    id: "hard16v10",
    title: "Hard 16 vs dealer 10",
    summary: "Hard 16 against a dealer 10 is uncomfortable. Late surrender changes this decision when enabled.",
    player: [card("10", "spades"), card("6", "hearts")],
    dealer: [card("10", "clubs"), card("?", "back")],
    deck: [card("5", "diamonds"), card("2", "clubs")],
    dealerHole: card("7", "diamonds"),
    dealerDraws: [card("4", "clubs")],
    recommended: "hit",
    why: "With no surrender, hard 16 against a dealer 10 is too weak to stand on."
  },
  {
    id: "hard11v6",
    title: "Hard 11 vs dealer 6",
    summary: "A strong total against a weak dealer upcard. This is a classic double.",
    player: [card("6", "clubs"), card("5", "diamonds")],
    dealer: [card("6", "spades"), card("?", "back")],
    deck: [card("10", "hearts")],
    dealerHole: card("10", "spades"),
    dealerDraws: [card("6", "diamonds")],
    recommended: "double",
    why: "Hard 11 has many 10-value cards that make 21, and dealer 6 is vulnerable."
  },
  {
    id: "pair8v9",
    title: "Pair of 8s vs dealer 9",
    summary: "A hard 16 is weak. Splitting 8s gives two better starting hands.",
    player: [card("8", "hearts"), card("8", "clubs")],
    dealer: [card("9", "spades"), card("?", "back")],
    deck: [card("3", "diamonds"), card("10", "clubs")],
    dealerHole: card("7", "hearts"),
    dealerDraws: [card("5", "clubs")],
    recommended: "split",
    why: "Beginner strategy splits 8-8 against every dealer upcard."
  },
  {
    id: "soft18v6",
    title: "Soft 18 vs dealer 6",
    summary: "Soft 18 is safe enough to press. On the H17 chart, double if allowed.",
    player: [card("A", "diamonds"), card("7", "clubs")],
    dealer: [card("6", "hearts"), card("?", "back")],
    deck: [card("3", "spades")],
    dealerHole: card("A", "clubs"),
    dealerDraws: [card("4", "diamonds"), card("9", "clubs")],
    recommended: "double",
    why: "A-7 against a weak dealer 6 is a double in this H17 practice setup."
  },
  {
    id: "twentiesv6",
    title: "Two 10-values vs dealer 6",
    summary: "Splitting may be legal at many tables, but strategy says keep the 20.",
    player: [card("K", "hearts"), card("Q", "spades")],
    dealer: [card("6", "diamonds"), card("?", "back")],
    deck: [card("2", "hearts")],
    dealerHole: card("9", "clubs"),
    dealerDraws: [card("7", "spades")],
    recommended: "stand",
    why: "A total of 20 is already excellent. Never split 10-value hands as a beginner."
  },
  {
    id: "hard9v7",
    title: "Hard 9 vs dealer 7",
    summary: "Not a double spot here. Take a card and keep building.",
    player: [card("4", "clubs"), card("5", "hearts")],
    dealer: [card("7", "diamonds"), card("?", "back")],
    deck: [card("8", "spades")],
    dealerHole: card("10", "clubs"),
    dealerDraws: [],
    recommended: "hit",
    why: "Hard 9 doubles mainly against dealer 3-6. Against 7, hit."
  }
];

const drillHands = [
  {
    id: "drill-hard16v10",
    title: "Hard 16 vs 10",
    player: [card("10", "spades"), card("6", "hearts")],
    dealer: card("10", "clubs")
  },
  {
    id: "drill-hard11v6",
    title: "Hard 11 vs 6",
    player: [card("6", "clubs"), card("5", "diamonds")],
    dealer: card("6", "spades")
  },
  {
    id: "drill-pair8v9",
    title: "8-8 vs 9",
    player: [card("8", "hearts"), card("8", "clubs")],
    dealer: card("9", "spades")
  },
  {
    id: "drill-soft18v6",
    title: "A-7 vs 6",
    player: [card("A", "diamonds"), card("7", "clubs")],
    dealer: card("6", "hearts")
  },
  {
    id: "drill-20v6",
    title: "10-value pair vs 6",
    player: [card("K", "hearts"), card("Q", "spades")],
    dealer: card("6", "diamonds")
  },
  {
    id: "drill-hard12v3",
    title: "Hard 12 vs 3",
    player: [card("10", "clubs"), card("2", "hearts")],
    dealer: card("3", "spades")
  },
  {
    id: "drill-hard12v5",
    title: "Hard 12 vs 5",
    player: [card("10", "diamonds"), card("2", "clubs")],
    dealer: card("5", "hearts")
  },
  {
    id: "drill-aces",
    title: "A-A vs 9",
    player: [card("A", "hearts"), card("A", "clubs")],
    dealer: card("9", "diamonds")
  },
  {
    id: "drill-soft19v6",
    title: "A-8 vs 6",
    player: [card("A", "spades"), card("8", "clubs")],
    dealer: card("6", "clubs")
  },
  {
    id: "drill-pair4v5",
    title: "4-4 vs 5",
    player: [card("4", "hearts"), card("4", "spades")],
    dealer: card("5", "diamonds")
  },
  {
    id: "drill-hard15v10",
    title: "Hard 15 vs 10",
    player: [card("10", "hearts"), card("5", "spades")],
    dealer: card("10", "diamonds")
  }
];

let lessonIndex = 0;
let scenarioIndex = 0;
let practice = createPractice(scenarios[0]);
const themeStorageKey = "blackjack-learn-theme";
const rulesStorageKey = "blackjack-learn-rules";
const mistakeStorageKey = "blackjack-learn-mistakes";
const dealerColumns = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"];
const actionLabels = {
  hit: "Hit",
  stand: "Stand",
  double: "Double",
  split: "Split",
  surrender: "Surrender"
};
const actionShortLabels = {
  hit: "H",
  stand: "S",
  double: "D",
  split: "P",
  surrender: "Rh"
};
let tableRules = loadTableRules();
let mistakes = loadMistakes();
let drillIndex = 0;
let drillStats = { correct: 0, attempts: 0, streak: 0 };
let drillAnswered = false;

function card(rank, suit) {
  return { rank, suit };
}

function createPractice(scenario) {
  return {
    scenario,
    player: scenario.player.map((item) => ({ ...item })),
    dealer: scenario.dealer.map((item) => ({ ...item })),
    deck: scenario.deck.map((item) => ({ ...item })),
    dealerHole: { ...scenario.dealerHole },
    dealerDraws: scenario.dealerDraws.map((item) => ({ ...item })),
    bet: 1,
    moved: false,
    ended: false,
    doubled: false,
    split: false,
    roundResult: null,
    history: []
  };
}

function rankValue(rank) {
  if (rank === "A") return 11;
  if (["K", "Q", "J", "10"].includes(rank)) return 10;
  return Number(rank);
}

function handInfo(cards) {
  const visible = cards.filter((item) => item.rank !== "?");
  const rawTotal = visible.reduce((sum, item) => sum + rankValue(item.rank), 0);
  let total = rawTotal;
  let acesAsEleven = visible.filter((item) => item.rank === "A").length;
  while (total > 21 && acesAsEleven > 0) {
    total -= 10;
    acesAsEleven -= 1;
  }
  const soft = total <= 21 && acesAsEleven > 0;
  const blackjack = visible.length === 2 && total === 21;
  return { total, soft, blackjack, bust: total > 21 };
}

function cardName(item) {
  if (item.rank === "?") return "Hole card";
  return `${item.rank}${suits[item.suit]}`;
}

function sameSplitValue(cards) {
  return cards.length === 2 && cards.every((item) => item.rank !== "?") && rankValue(cards[0].rank) === rankValue(cards[1].rank);
}

function dealerUpValue(cardItem) {
  if (cardItem.rank === "A") return 11;
  return rankValue(cardItem.rank);
}

function loadTableRules() {
  const fallback = { dealerSoft17: "h17", blackjackPayout: "3to2", doubleAfterSplit: false, surrender: false };
  try {
    const parsed = { ...fallback, ...JSON.parse(localStorage.getItem(rulesStorageKey) || "{}") };
    return {
      dealerSoft17: parsed.dealerSoft17 === "s17" ? "s17" : "h17",
      blackjackPayout: parsed.blackjackPayout === "6to5" ? "6to5" : "3to2",
      doubleAfterSplit: Boolean(parsed.doubleAfterSplit),
      surrender: Boolean(parsed.surrender)
    };
  } catch {
    return fallback;
  }
}

function saveTableRules() {
  localStorage.setItem(rulesStorageKey, JSON.stringify(tableRules));
}

function loadMistakes() {
  try {
    const parsed = JSON.parse(localStorage.getItem(mistakeStorageKey) || "[]");
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function saveMistakes() {
  localStorage.setItem(mistakeStorageKey, JSON.stringify(mistakes.slice(0, 50)));
}

function ruleLabel() {
  return tableRules.dealerSoft17 === "h17" ? "H17" : "S17";
}

function ruleSummary() {
  const payout = tableRules.blackjackPayout === "3to2" ? "3:2 blackjack" : "6:5 blackjack";
  const das = tableRules.doubleAfterSplit ? "DAS" : "no DAS";
  const surrender = tableRules.surrender ? "late surrender" : "no surrender";
  return `${ruleLabel()}, ${payout}, ${surrender}, ${das}.`;
}

function renderRuleControls() {
  const dealerRule = document.querySelector("#dealer-rule");
  const payoutRule = document.querySelector("#payout-rule");
  const dasRule = document.querySelector("#das-rule");
  const surrenderRule = document.querySelector("#surrender-rule");
  const ruleSummaryText = document.querySelector("#rule-summary");
  const practiceRuleLabel = document.querySelector("#practice-rule-label");
  const drillRuleLabel = document.querySelector("#drill-rule-label");
  const chipRule = document.querySelector("#chip-rule");
  const chipPayout = document.querySelector("#chip-payout");
  const assumptions = document.querySelector("#practice-table-assumptions");

  if (dealerRule) dealerRule.value = tableRules.dealerSoft17;
  if (payoutRule) payoutRule.value = tableRules.blackjackPayout;
  if (dasRule) dasRule.checked = tableRules.doubleAfterSplit;
  if (surrenderRule) surrenderRule.checked = tableRules.surrender;
  if (ruleSummaryText) ruleSummaryText.textContent = ruleSummary();
  if (practiceRuleLabel) practiceRuleLabel.textContent = ruleLabel();
  if (drillRuleLabel) drillRuleLabel.textContent = ruleLabel();
  if (chipRule) chipRule.textContent = ruleLabel();
  if (chipPayout) chipPayout.textContent = tableRules.blackjackPayout === "3to2" ? "3:2" : "6:5";
  if (assumptions) {
    assumptions.innerHTML = [
      `Dealer ${tableRules.dealerSoft17 === "h17" ? "hits" : "stands on"} soft 17.`,
      `Blackjack pays ${tableRules.blackjackPayout === "3to2" ? "3:2" : "6:5"}.`,
      tableRules.surrender ? "Late surrender available." : "Late surrender off.",
      tableRules.doubleAfterSplit ? "DAS variant enabled for strategy examples." : "No double after split in strategy examples."
    ].map((item) => `<li>${item}</li>`).join("");
  }
}

function bindRuleControls() {
  const dealerRule = document.querySelector("#dealer-rule");
  const payoutRule = document.querySelector("#payout-rule");
  const dasRule = document.querySelector("#das-rule");
  const surrenderRule = document.querySelector("#surrender-rule");
  const updateRules = () => {
    tableRules = {
      dealerSoft17: dealerRule.value === "s17" ? "s17" : "h17",
      blackjackPayout: payoutRule.value === "6to5" ? "6to5" : "3to2",
      doubleAfterSplit: dasRule.checked,
      surrender: surrenderRule.checked
    };
    saveTableRules();
    renderRuleControls();
    renderPractice();
    renderDrill();
    renderStrategyCharts();
    renderMistakeReview();
    setChartDetail(null);
  };

  [dealerRule, payoutRule, dasRule, surrenderRule].forEach((control) => {
    control.addEventListener("change", updateRules);
  });
}

function strategyFor(cards, dealerCard, rules = tableRules) {
  const info = handInfo(cards);
  const dealerValue = dealerUpValue(dealerCard);
  const dealerRank = dealerCard.rank;

  if (sameSplitValue(cards)) {
    const value = rankValue(cards[0].rank);
    if (cards[0].rank === "A" || value === 8) {
      return explainStrategy("split", "Beginner strategy splits aces and eights against every upcard.");
    }
    if (value === 10) {
      return explainStrategy("stand", "A 20 is already strong; do not split 10-value hands.");
    }
    if (value === 9) {
      return explainStrategy([2, 3, 4, 5, 6, 8, 9].includes(dealerValue) ? "split" : "stand", "Split 9s against 2-6, 8, and 9; otherwise keep the made hand.");
    }
    if (value === 7) {
      return explainStrategy(dealerValue >= 2 && dealerValue <= 7 ? "split" : "hit", "Split 7s against dealer 2-7; hit against stronger upcards.");
    }
    if (value === 6) {
      const shouldSplit = rules.doubleAfterSplit ? dealerValue >= 2 && dealerValue <= 6 : dealerValue >= 3 && dealerValue <= 6;
      return explainStrategy(shouldSplit ? "split" : "hit", "Split 6s against weak dealer cards; without DAS, dealer 2 is usually a hit.");
    }
    if (value === 5) {
      return hardTotalStrategy(10, dealerRank, dealerValue, rules, "Treat 5-5 as hard 10.");
    }
    if (value === 4) {
      return explainStrategy(rules.doubleAfterSplit && (dealerValue === 5 || dealerValue === 6) ? "split" : "hit", "Split 4s only when DAS is available against 5 or 6.");
    }
    if (value === 2 || value === 3) {
      const shouldSplit = rules.doubleAfterSplit ? dealerValue >= 2 && dealerValue <= 7 : dealerValue >= 4 && dealerValue <= 7;
      return explainStrategy(shouldSplit ? "split" : "hit", "Split 2s and 3s against 2-7 with DAS, or 4-7 without DAS.");
    }
  }

  if (info.soft) {
    return softTotalStrategy(info.total, dealerRank, dealerValue, rules);
  }

  return hardTotalStrategy(info.total, dealerRank, dealerValue, rules);
}

function explainStrategy(action, reason) {
  return { action, reason };
}

function hardTotalStrategy(total, dealerRank, dealerValue, rules, prefix = "") {
  const preface = prefix ? `${prefix} ` : "";
  if (total >= 17) return explainStrategy("stand", `${preface}Hard ${total} is strong enough to stand.`);
  if (total === 16) {
    if (rules.surrender && ["9", "10", "A"].includes(dealerRank)) {
      return explainStrategy("surrender", `${preface}Late surrender is best for hard 16 against 9, 10, or ace when available.`);
    }
    return explainStrategy(dealerValue >= 2 && dealerValue <= 6 ? "stand" : "hit", `${preface}Hard 16 stands against 2-6 and hits against 7-A if surrender is unavailable.`);
  }
  if (total === 15) {
    if (rules.surrender && dealerRank === "10") {
      return explainStrategy("surrender", `${preface}Late surrender is best for hard 15 against dealer 10 when available.`);
    }
    return explainStrategy(dealerValue >= 2 && dealerValue <= 6 ? "stand" : "hit", `${preface}Hard 15 stands against 2-6 and hits against stronger upcards.`);
  }
  if (total >= 13 && total <= 14) {
    return explainStrategy(dealerValue >= 2 && dealerValue <= 6 ? "stand" : "hit", `${preface}Hard ${total} stands against 2-6 and hits against 7-A.`);
  }
  if (total === 12) {
    return explainStrategy(dealerValue >= 4 && dealerValue <= 6 ? "stand" : "hit", `${preface}Hard 12 stands against 4-6 and hits otherwise.`);
  }
  if (total === 11) {
    if (dealerRank === "A" && rules.dealerSoft17 === "s17") {
      return explainStrategy("hit", `${preface}With S17, hard 11 against ace is usually hit rather than double.`);
    }
    return explainStrategy("double", `${preface}Hard 11 is a strong double spot.`);
  }
  if (total === 10) {
    return explainStrategy(dealerValue >= 2 && dealerValue <= 9 ? "double" : "hit", `${preface}Hard 10 doubles against 2-9 and hits against 10 or ace.`);
  }
  if (total === 9) {
    return explainStrategy(dealerValue >= 3 && dealerValue <= 6 ? "double" : "hit", `${preface}Hard 9 doubles against 3-6 and hits otherwise.`);
  }
  return explainStrategy("hit", `${preface}Hard ${total} is too low to stand.`);
}

function softTotalStrategy(total, dealerRank, dealerValue, rules) {
  if (total >= 20) return explainStrategy("stand", `Soft ${total} is strong enough to stand.`);
  if (total === 19) {
    return explainStrategy(rules.dealerSoft17 === "h17" && dealerValue === 6 ? "double" : "stand", "Soft 19 usually stands; H17 charts often double against 6.");
  }
  if (total === 18) {
    if (dealerValue >= 3 && dealerValue <= 6) return explainStrategy("double", "Soft 18 doubles against dealer 3-6 in this beginner chart.");
    if (dealerValue === 2 && rules.dealerSoft17 === "h17") return explainStrategy("double", "On H17 tables, soft 18 can double against dealer 2.");
    if (dealerValue === 2) return explainStrategy("stand", "On S17 tables, soft 18 stands against dealer 2.");
    if (dealerValue === 7 || dealerValue === 8) return explainStrategy("stand", "Soft 18 stands against dealer 7 or 8.");
    return explainStrategy("hit", "Soft 18 hits against dealer 9, 10, or ace.");
  }
  if (total === 17) return explainStrategy(dealerValue >= 3 && dealerValue <= 6 ? "double" : "hit", "Soft 17 doubles against 3-6 and hits otherwise.");
  if (total === 16 || total === 15) return explainStrategy(dealerValue >= 4 && dealerValue <= 6 ? "double" : "hit", `Soft ${total} doubles against 4-6 and hits otherwise.`);
  if (total === 14 || total === 13) return explainStrategy(dealerValue >= 5 && dealerValue <= 6 ? "double" : "hit", `Soft ${total} doubles against 5-6 and hits otherwise.`);
  return explainStrategy("hit", `Soft ${total} is too low to stand.`);
}

function legalAction(action) {
  const info = handInfo(practice.player);
  if (practice.ended || info.bust || info.blackjack) {
    return { legal: false, reason: "This hand is already resolved." };
  }
  if (action === "hit" || action === "stand") {
    return { legal: true };
  }
  if (action === "double") {
    if (practice.moved || practice.player.length !== 2) {
      return { legal: false, reason: "Double is available only before taking another card on the first two-card hand in this trainer." };
    }
    return { legal: true };
  }
  if (action === "split") {
    if (practice.moved || practice.player.length !== 2) {
      return { legal: false, reason: "Split is available only as the first decision on a two-card hand." };
    }
    if (!sameSplitValue(practice.player)) {
      return { legal: false, reason: "You can split only two cards with the same blackjack value." };
    }
    return { legal: true };
  }
  if (action === "surrender") {
    if (!tableRules.surrender) {
      return { legal: false, reason: "Late surrender is not enabled for the selected table rules." };
    }
    if (practice.moved || practice.player.length !== 2) {
      return { legal: false, reason: "Late surrender is available only as the first decision on a two-card hand in this trainer." };
    }
    return { legal: true };
  }
  return { legal: false, reason: "Unknown action." };
}

function showView(viewName) {
  document.querySelectorAll(".view").forEach((view) => {
    view.classList.toggle("active", view.id === `${viewName}-view`);
  });
  document.querySelectorAll(".nav-button").forEach((button) => {
    button.classList.toggle("active", button.dataset.view === viewName);
  });
}

function applyThemePreference(preference) {
  const normalized = ["auto", "light", "dark"].includes(preference) ? preference : "auto";
  document.documentElement.dataset.themePreference = normalized;
  if (normalized === "dark" || normalized === "light") {
    document.documentElement.dataset.theme = normalized;
  } else {
    delete document.documentElement.dataset.theme;
  }
}

function initThemeControls() {
  const select = document.querySelector("#theme-select");
  if (!select) return;
  const savedPreference = localStorage.getItem(themeStorageKey) || "auto";
  applyThemePreference(savedPreference);
  select.value = document.documentElement.dataset.themePreference;
  select.addEventListener("change", () => {
    localStorage.setItem(themeStorageKey, select.value);
    applyThemePreference(select.value);
  });
}

function renderTutorial() {
  const progress = document.querySelector("#lesson-progress");
  const panel = document.querySelector("#lesson-panel");
  const lesson = lessons[lessonIndex];

  progress.innerHTML = lessons.map((item, index) => {
    const status = index < lessonIndex ? "done" : index === lessonIndex ? "active" : "";
    return `<button class="progress-step ${status}" type="button" data-lesson="${index}">${index + 1}. ${item.title}</button>`;
  }).join("");

  panel.innerHTML = `
    <span class="lesson-kicker">Lesson ${lessonIndex + 1} of ${lessons.length}</span>
    <h3>${lesson.title}</h3>
    <p>${lesson.body}</p>
    <ul>${lesson.bullets.map((bullet) => `<li>${bullet}</li>`).join("")}</ul>
    <div class="lesson-example"><strong>Example:</strong> ${lesson.example}</div>
  `;

  document.querySelector("#lesson-back").disabled = lessonIndex === 0;
  document.querySelector("#lesson-next").textContent = lessonIndex === lessons.length - 1 ? "Complete" : "Next";
}

function renderStrategy() {
  document.querySelector("#strategy-grid").innerHTML = strategies.map((item) => `
    <article class="strategy-card">
      <h3>${item.title}</h3>
      <p>${item.body}</p>
      <div class="example"><strong>Concrete example:</strong> ${item.example}</div>
    </article>
  `).join("");
}

function formatHandTotal(info) {
  if (info.blackjack) return "Blackjack";
  return `${info.soft ? "Soft " : ""}${info.total}${info.bust ? " bust" : ""}`;
}

function dealerVisibleLabel() {
  if (practice.roundResult) {
    return formatHandTotal(handInfo(practice.dealer));
  }
  const dealerUp = practice.dealer[0];
  return dealerUp.rank === "A" ? "A" : String(rankValue(dealerUp.rank));
}

function describeHand(cards) {
  return cards.map((item) => cardName(item)).join(" ");
}

function describeDealer(cardItem) {
  return `dealer ${cardName(cardItem)}`;
}

function renderPractice() {
  const info = handInfo(practice.player);
  document.querySelector("#hand-total").textContent = formatHandTotal(info);
  document.querySelector("#dealer-total").textContent = dealerVisibleLabel();
  document.querySelector("#bet-text").textContent = `${practice.bet} unit${practice.bet === 1 ? "" : "s"}`;
  document.querySelector("#scenario-summary").textContent = practice.scenario.summary;
  document.querySelector("#hand-note").textContent = practice.ended ? "Hand resolved" : practice.moved ? "After first move" : "First decision";
  document.querySelector("#dealer-note").textContent = practice.roundResult ? "Hole card revealed" : "Upcard visible";

  document.querySelector("#dealer-hand").innerHTML = practice.dealer.map((item) => renderCard(item)).join("");
  document.querySelector("#player-hand").innerHTML = practice.player.map((item) => renderCard(item)).join("");
  renderRuleControls();
  renderScenarioSelect();
  renderActionStates();
  renderHistory();
  renderTips();
  renderRoundResult();
}

function renderCard(item) {
  const isBack = item.rank === "?";
  const isRed = item.suit === "hearts" || item.suit === "diamonds";
  const suit = suits[item.suit] ?? "";
  return `
    <div class="playing-card ${isBack ? "card-back" : ""} ${isRed ? "red-suit" : ""}" aria-label="${cardName(item)}">
      <span class="card-rank">${isBack ? "?" : item.rank}</span>
      <span class="card-suit">${isBack ? "◆" : suit}</span>
      <span class="card-caption">${isBack ? "Hole" : cardName(item)}</span>
    </div>
  `;
}

function renderScenarioSelect() {
  const select = document.querySelector("#scenario-select");
  const current = select.value || practice.scenario.id;
  select.innerHTML = scenarios.map((scenario) => `<option value="${scenario.id}">${scenario.title}</option>`).join("");
  select.value = scenarios.some((scenario) => scenario.id === current) ? current : practice.scenario.id;
}

function renderActionStates() {
  document.querySelectorAll("[data-action]").forEach((button) => {
    button.disabled = practice.ended;
  });
}

function renderHistory() {
  const history = document.querySelector("#history-list");
  if (practice.history.length === 0) {
    history.innerHTML = "<li>No moves yet.</li>";
    return;
  }
  history.innerHTML = practice.history.slice(-8).reverse().map((item) => `<li>${item}</li>`).join("");
}

function renderTips() {
  const info = handInfo(practice.player);
  const legalSplit = sameSplitValue(practice.player);
  const strategy = strategyFor(practice.player, practice.dealer[0], tableRules);
  const tips = [
    `Recommended move: ${labelAction(strategy.action)}.`,
    `${info.soft ? "Soft" : "Hard"} total ${info.total} against dealer ${cardName(practice.dealer[0])}.`,
    legalSplit ? "Split is legal here, but check whether strategy wants it." : "Split is not legal unless the first two cards share blackjack value.",
    tableRules.surrender ? "Late surrender is available only as the first two-card decision." : "Late surrender is currently off; use the rule panel to compare it."
  ];
  document.querySelector("#table-tips").innerHTML = tips.map((tip) => `<li>${tip}</li>`).join("");
}

function renderRoundResult() {
  const panel = document.querySelector("#round-result");
  if (!practice.roundResult) {
    panel.className = "round-result";
    panel.innerHTML = `
      <h3>Round Result</h3>
      <p>Stand or double to reveal the dealer and resolve the hand.</p>
    `;
    return;
  }

  const result = practice.roundResult;
  panel.className = `round-result ${result.outcome}`;
  panel.innerHTML = `
    <h3>${result.title}</h3>
    <p>${result.copy}</p>
    <div class="result-note">${result.note}</div>
  `;
}

function revealDealerHole() {
  if (practice.dealer[1] && practice.dealer[1].rank === "?") {
    practice.dealer[1] = { ...practice.dealerHole };
    addHistory(`Dealer revealed ${cardName(practice.dealerHole)}.`);
  }
}

function drawDealerCard() {
  return practice.dealerDraws.shift() || card("10", "clubs");
}

function shouldDealerDraw(info) {
  if (info.total < 17) return true;
  return info.total === 17 && info.soft && tableRules.dealerSoft17 === "h17";
}

function blackjackPayoutUnits() {
  return tableRules.blackjackPayout === "3to2" ? 1.5 : 1.2;
}

function formatUnitDelta(value) {
  if (value === 0) return "Push: 0 units.";
  const absValue = Math.abs(value);
  const amount = Number.isInteger(absValue) ? String(absValue) : absValue.toFixed(1);
  return `${value > 0 ? "Win" : "Lose"} ${amount} unit${absValue === 1 ? "" : "s"}.`;
}

function makeRoundResult(outcome, title, copy, note) {
  return { outcome, title, copy, note };
}

function resultFromTotals(trigger) {
  const playerInfo = handInfo(practice.player);
  const dealerInfo = handInfo(practice.dealer);
  const playerLabel = formatHandTotal(playerInfo);
  const dealerLabel = formatHandTotal(dealerInfo);
  const reason = trigger === "double" ? "Double resolves after one card." : "Stand sends the hand to dealer resolution.";

  if (playerInfo.bust) {
    return makeRoundResult("loss", "Player Bust", `You finished at ${playerInfo.total}, so the dealer does not need to draw.`, formatUnitDelta(-practice.bet));
  }
  if (playerInfo.blackjack && dealerInfo.blackjack) {
    return makeRoundResult("push", "Blackjack Push", `Both you and the dealer have blackjack.`, "Your original bet is returned.");
  }
  if (dealerInfo.blackjack) {
    return makeRoundResult("loss", "Dealer Blackjack", `Dealer reveals ${dealerLabel}; your ${playerLabel} loses.`, formatUnitDelta(-practice.bet));
  }
  if (playerInfo.blackjack) {
    const payout = blackjackPayoutUnits() * practice.bet;
    return makeRoundResult("win", "Blackjack Wins", `Your blackjack beats dealer ${dealerLabel}.`, `${formatUnitDelta(payout)} Table payout is ${tableRules.blackjackPayout === "3to2" ? "3:2" : "6:5"}.`);
  }
  if (dealerInfo.bust) {
    return makeRoundResult("win", "Dealer Bust", `Dealer draws to ${dealerInfo.total}; your ${playerLabel} wins.`, `${formatUnitDelta(practice.bet)} ${reason}`);
  }
  if (playerInfo.total > dealerInfo.total) {
    return makeRoundResult("win", "Player Wins", `Your ${playerLabel} beats dealer ${dealerLabel}.`, `${formatUnitDelta(practice.bet)} ${reason}`);
  }
  if (playerInfo.total < dealerInfo.total) {
    return makeRoundResult("loss", "Dealer Wins", `Dealer ${dealerLabel} beats your ${playerLabel}.`, `${formatUnitDelta(-practice.bet)} ${reason}`);
  }
  return makeRoundResult("push", "Push", `Your ${playerLabel} ties dealer ${dealerLabel}.`, "Your original bet is returned.");
}

function resolveRound(trigger) {
  revealDealerHole();
  let dealerInfo = handInfo(practice.dealer);
  const playerInfo = handInfo(practice.player);

  if (!playerInfo.bust && !playerInfo.blackjack && !dealerInfo.blackjack) {
    while (shouldDealerDraw(dealerInfo)) {
      const next = drawDealerCard();
      practice.dealer.push(next);
      addHistory(`Dealer drew ${cardName(next)}.`);
      dealerInfo = handInfo(practice.dealer);
    }
  }

  practice.ended = true;
  practice.roundResult = resultFromTotals(trigger);
  return practice.roundResult;
}

function settlePlayerBust() {
  const info = handInfo(practice.player);
  practice.ended = true;
  practice.roundResult = makeRoundResult(
    "loss",
    "Player Bust",
    `You drew to ${info.total}, which is over 21.`,
    `${formatUnitDelta(-practice.bet)} A bust loses before the dealer acts.`
  );
}

function settleSurrender() {
  practice.moved = true;
  practice.ended = true;
  practice.roundResult = makeRoundResult(
    "loss",
    "Late Surrender",
    "You gave up the hand before drawing.",
    `${formatUnitDelta(-0.5 * practice.bet)} This trainer treats surrender as late surrender after the dealer has checked for blackjack.`
  );
}

function setFeedback(title, copy, note = "") {
  document.querySelector("#feedback-title").textContent = title;
  document.querySelector("#feedback-copy").textContent = copy;
  document.querySelector("#feedback-note").textContent = note || "A legal move can still be a strategy mistake.";
}

function labelAction(action) {
  return actionLabels[action] || action.charAt(0).toUpperCase() + action.slice(1);
}

function addHistory(message) {
  practice.history.push(message);
}

function drawCard() {
  return practice.deck.shift() || card("2", "clubs");
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "\"": "&quot;",
    "'": "&#39;"
  })[character]);
}

function recordMistake({ source, hand, dealer, chosen, recommended, explanation, scenarioId = "" }) {
  const id = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  mistakes = [
    {
      id,
      source,
      hand,
      dealer,
      chosen,
      recommended,
      explanation,
      scenarioId,
      rule: ruleSummary(),
      createdAt: new Date().toLocaleString()
    },
    ...mistakes
  ].slice(0, 50);
  saveMistakes();
}

function renderMistakeReview() {
  const summary = document.querySelector("#mistake-summary");
  const list = document.querySelector("#mistake-list");
  if (!summary || !list) return;

  if (mistakes.length === 0) {
    summary.innerHTML = `
      <article class="mistake-stat">
        <span class="stat-label">Misses</span>
        <strong>0</strong>
        <p>No saved misses yet. Try a drill or make a legal strategy mistake in Practice.</p>
      </article>
    `;
    list.innerHTML = "<li>No mistakes recorded.</li>";
    return;
  }

  const recommendedCounts = mistakes.reduce((counts, mistake) => {
    counts[mistake.recommended] = (counts[mistake.recommended] || 0) + 1;
    return counts;
  }, {});
  const mostCommon = Object.entries(recommendedCounts).sort((a, b) => b[1] - a[1])[0];
  const latest = mistakes[0];

  summary.innerHTML = `
    <article class="mistake-stat">
      <span class="stat-label">Misses</span>
      <strong>${mistakes.length}</strong>
      <p>Saved locally in this browser.</p>
    </article>
    <article class="mistake-stat">
      <span class="stat-label">Most missed answer</span>
      <strong>${labelAction(mostCommon[0])}</strong>
      <p>${mostCommon[1]} recent miss${mostCommon[1] === 1 ? "" : "es"} where this was best.</p>
    </article>
    <article class="mistake-stat">
      <span class="stat-label">Latest rule set</span>
      <strong>${escapeHtml(ruleLabel())}</strong>
      <p>${escapeHtml(latest.rule)}</p>
    </article>
  `;

  list.innerHTML = mistakes.map((mistake) => `
    <li>
      <strong>${escapeHtml(mistake.source)}: ${escapeHtml(mistake.hand)} vs ${escapeHtml(mistake.dealer)}</strong>
      <span class="mistake-meta">${escapeHtml(mistake.createdAt)} · ${escapeHtml(mistake.rule)}</span>
      <span>You chose ${escapeHtml(labelAction(mistake.chosen))}; chart says ${escapeHtml(labelAction(mistake.recommended))}.</span>
      <span>${escapeHtml(mistake.explanation)}</span>
      ${mistake.scenarioId ? `<button class="inline-button" type="button" data-review-scenario="${escapeHtml(mistake.scenarioId)}">Retry scenario</button>` : ""}
    </li>
  `).join("");
}

function setDrillFeedback(title, copy, note = "") {
  document.querySelector("#drill-feedback-title").textContent = title;
  document.querySelector("#drill-feedback-copy").textContent = copy;
  document.querySelector("#drill-feedback-note").textContent = note || "Mistakes are saved to Review.";
}

function currentDrill() {
  return drillHands[drillIndex % drillHands.length];
}

function drillActionLegality(action, cards) {
  if (action === "hit" || action === "stand" || action === "double") {
    return { legal: true };
  }
  if (action === "split") {
    return sameSplitValue(cards)
      ? { legal: true }
      : { legal: false, reason: "Split is legal only when the first two cards share the same blackjack value." };
  }
  if (action === "surrender") {
    return tableRules.surrender
      ? { legal: true }
      : { legal: false, reason: "Late surrender is not enabled for the selected table rules." };
  }
  return { legal: false, reason: "Unknown action." };
}

function renderDrill() {
  const drill = currentDrill();
  const info = handInfo(drill.player);
  const strategy = strategyFor(drill.player, drill.dealer, tableRules);

  document.querySelector("#drill-correct").textContent = String(drillStats.correct);
  document.querySelector("#drill-attempts").textContent = String(drillStats.attempts);
  document.querySelector("#drill-streak").textContent = String(drillStats.streak);
  document.querySelector("#drill-rule-label").textContent = ruleLabel();
  document.querySelector("#drill-hand").innerHTML = drill.player.map((item) => renderCard(item)).join("");
  document.querySelector("#drill-dealer").innerHTML = renderCard(drill.dealer);
  document.querySelector("#drill-total").textContent = `${drill.title} · ${formatHandTotal(info)}`;

  document.querySelectorAll(".drill-answer").forEach((button) => {
    const action = button.dataset.drillAction;
    button.disabled = drillAnswered || (action === "surrender" && !tableRules.surrender);
    button.classList.toggle("recommended", drillAnswered && action === strategy.action);
  });
}

function answerDrill(action) {
  if (drillAnswered) return;

  const drill = currentDrill();
  const strategy = strategyFor(drill.player, drill.dealer, tableRules);
  const legality = drillActionLegality(action, drill.player);
  const correct = legality.legal && action === strategy.action;

  drillStats.attempts += 1;
  drillStats.correct += correct ? 1 : 0;
  drillStats.streak = correct ? drillStats.streak + 1 : 0;
  drillAnswered = true;

  if (!correct) {
    recordMistake({
      source: "Drill",
      hand: describeHand(drill.player),
      dealer: cardName(drill.dealer),
      chosen: action,
      recommended: strategy.action,
      explanation: legality.legal ? strategy.reason : `${legality.reason} ${strategy.reason}`
    });
  }

  if (!legality.legal) {
    setDrillFeedback(
      `Illegal ${labelAction(action)}`,
      legality.reason,
      `Best answer: ${labelAction(strategy.action)}. ${strategy.reason}`
    );
  } else if (correct) {
    setDrillFeedback(
      "Correct",
      `${labelAction(action)} is the beginner chart move for ${drill.title}.`,
      strategy.reason
    );
  } else {
    setDrillFeedback(
      "Strategy miss",
      `${labelAction(action)} is not the best answer for ${drill.title}.`,
      `Best answer: ${labelAction(strategy.action)}. ${strategy.reason}`
    );
  }

  renderDrill();
  renderMistakeReview();
}

function nextDrill() {
  drillIndex = (drillIndex + 1) % drillHands.length;
  drillAnswered = false;
  setDrillFeedback("Ready", "Choose the best first move for this hand.", "Mistakes are saved to Review.");
  renderDrill();
}

function resetDrills() {
  drillStats = { correct: 0, attempts: 0, streak: 0 };
  drillAnswered = false;
  setDrillFeedback("Score reset", "Choose the best first move for this hand.", "Mistakes are saved to Review.");
  renderDrill();
}

function dealerCardFromLabel(label) {
  return card(label, "spades");
}

function hardCardsForTotal(total) {
  if (total <= 8) return [card("5", "clubs"), card("3", "hearts")];
  if (total === 9) return [card("5", "clubs"), card("4", "hearts")];
  if (total === 10) return [card("6", "clubs"), card("4", "hearts")];
  if (total === 11) return [card("6", "clubs"), card("5", "hearts")];
  return [card("10", "clubs"), card(String(total - 10), "hearts")];
}

function chartCards(kind, rowLabel) {
  if (kind === "hard") {
    if (rowLabel === "17+") return hardCardsForTotal(17);
    if (rowLabel === "8-") return hardCardsForTotal(8);
    return hardCardsForTotal(Number(rowLabel));
  }
  if (kind === "soft") {
    const rank = rowLabel.split(",")[1];
    return [card("A", "clubs"), card(rank, "hearts")];
  }
  const rank = rowLabel.split(",")[0];
  return [card(rank, "clubs"), card(rank, "hearts")];
}

function actionClass(action) {
  return `action-${action}`;
}

function renderStrategyChart(targetSelector, kind, rows) {
  const target = document.querySelector(targetSelector);
  const header = dealerColumns.map((dealer) => `<th scope="col" data-chart-axis-dealer="${dealer}">${dealer}</th>`).join("");
  const body = rows.map((rowLabel) => {
    const cells = dealerColumns.map((dealer) => {
      const strategy = strategyFor(chartCards(kind, rowLabel), dealerCardFromLabel(dealer), tableRules);
      return `
        <td data-chart-axis-row="${rowLabel}" data-chart-axis-dealer="${dealer}">
          <button
            class="chart-cell ${actionClass(strategy.action)}"
            type="button"
            data-chart-kind="${kind}"
            data-chart-row="${rowLabel}"
            data-chart-dealer="${dealer}"
            aria-label="${rowLabel} versus dealer ${dealer}: ${labelAction(strategy.action)}"
          >${actionShortLabels[strategy.action]}</button>
        </td>
      `;
    }).join("");
    return `<tr><th scope="row" data-chart-axis-row="${rowLabel}">${rowLabel}</th>${cells}</tr>`;
  }).join("");

  target.innerHTML = `
    <table class="chart-table">
      <thead><tr><th scope="col">Hand</th>${header}</tr></thead>
      <tbody>${body}</tbody>
    </table>
  `;
}

function renderStrategyCharts() {
  renderStrategyChart("#hard-chart", "hard", ["17+", "16", "15", "14", "13", "12", "11", "10", "9", "8-"]);
  renderStrategyChart("#soft-chart", "soft", ["A,9", "A,8", "A,7", "A,6", "A,5", "A,4", "A,3", "A,2"]);
  renderStrategyChart("#pair-chart", "pair", ["A,A", "10,10", "9,9", "8,8", "7,7", "6,6", "5,5", "4,4", "3,3", "2,2"]);
}

function setChartDetail(detail) {
  const title = document.querySelector("#chart-detail-title");
  const copy = document.querySelector("#chart-detail-copy");
  const note = document.querySelector("#chart-detail-note");

  if (!detail) {
    title.textContent = "Select a cell";
    copy.textContent = "Click any chart decision to see the hand, dealer upcard, and rule-sensitive explanation.";
    note.textContent = "H = Hit, S = Stand, D = Double, P = Split, Rh = Surrender if available.";
    return;
  }

  title.textContent = `${detail.rowLabel} vs dealer ${detail.dealerLabel}: ${labelAction(detail.strategy.action)}`;
  copy.textContent = `${describeHand(detail.cards)} against ${describeDealer(detail.dealerCard)}. ${detail.strategy.reason}`;
  note.textContent = `Current rules: ${ruleSummary()}`;
}

function openChartDetail(kind, rowLabel, dealerLabel) {
  const cards = chartCards(kind, rowLabel);
  const dealerCard = dealerCardFromLabel(dealerLabel);
  const strategy = strategyFor(cards, dealerCard, tableRules);
  setChartDetail({ rowLabel, dealerLabel, cards, dealerCard, strategy });
}

function clearChartAxisHighlights(chart = document) {
  chart.querySelectorAll(".axis-highlight, .axis-origin").forEach((element) => {
    element.classList.remove("axis-highlight", "axis-origin");
  });
}

function highlightChartAxes(button) {
  const chart = button.closest(".strategy-chart");
  if (!chart) return;
  const row = button.dataset.chartRow;
  const dealer = button.dataset.chartDealer;

  clearChartAxisHighlights(chart);
  chart.querySelectorAll("[data-chart-axis-row], [data-chart-axis-dealer]").forEach((element) => {
    if (element.dataset.chartAxisRow === row || element.dataset.chartAxisDealer === dealer) {
      element.classList.add("axis-highlight");
    }
  });
  button.classList.add("axis-origin");
}

function performAction(action) {
  const legality = legalAction(action);
  if (!legality.legal) {
    setFeedback(`Illegal ${labelAction(action)}`, legality.reason, "Rules legality comes before strategy feedback.");
    addHistory(`Rejected ${labelAction(action)}: ${legality.reason}`);
    renderPractice();
    return;
  }

  const strategy = strategyFor(practice.player, practice.dealer[0], tableRules);
  const recommended = strategy.action;
  const matchesStrategy = action === recommended;

  if (!matchesStrategy) {
    recordMistake({
      source: "Practice",
      hand: describeHand(practice.player),
      dealer: cardName(practice.dealer[0]),
      chosen: action,
      recommended,
      explanation: strategy.reason,
      scenarioId: practice.scenario.id
    });
  }

  if (action === "hit") {
    const next = drawCard();
    practice.player.push(next);
    practice.moved = true;
    const info = handInfo(practice.player);
    if (info.bust) {
      settlePlayerBust();
    }
    const title = matchesStrategy ? "Legal hit, recommended" : "Legal hit, strategy miss";
    const copy = info.bust
      ? `You drew ${cardName(next)} and busted at ${info.total}.`
      : `You drew ${cardName(next)}. Your new total is ${info.soft ? "soft " : ""}${info.total}.`;
    setFeedback(title, copy, matchesStrategy ? strategy.reason : `This move is legal, but beginner strategy recommends ${labelAction(recommended)} here. ${strategy.reason}`);
    addHistory(`${labelAction(action)}: drew ${cardName(next)}.`);
  }

  if (action === "stand") {
    practice.moved = true;
    const info = handInfo(practice.player);
    const result = resolveRound("stand");
    setFeedback(
      matchesStrategy ? "Legal stand, recommended" : "Legal stand, strategy miss",
      `You stood on ${info.soft ? "soft " : ""}${info.total}. ${result.title}: ${result.copy}`,
      matchesStrategy ? strategy.reason : `Standing is allowed, but beginner strategy recommends ${labelAction(recommended)} here. ${strategy.reason}`
    );
    addHistory(`Stood on ${info.total}.`);
  }

  if (action === "double") {
    const next = drawCard();
    practice.player.push(next);
    practice.bet = 2;
    practice.moved = true;
    practice.doubled = true;
    const info = handInfo(practice.player);
    const result = info.bust ? (settlePlayerBust(), practice.roundResult) : resolveRound("double");
    setFeedback(
      matchesStrategy ? "Legal double, recommended" : "Legal double, strategy miss",
      `You doubled to 2 units, drew ${cardName(next)}, and ended at ${formatHandTotal(info)}. ${result.title}: ${result.copy}`,
      matchesStrategy ? strategy.reason : `Double is legal before a hit, but beginner strategy recommends ${labelAction(recommended)} here. ${strategy.reason}`
    );
    addHistory(`Doubled: drew ${cardName(next)}.`);
  }

  if (action === "split") {
    practice.moved = true;
    practice.split = true;
    practice.ended = true;
    practice.roundResult = makeRoundResult(
      "push",
      "Split Started",
      "The pair was split into two separate practice hands.",
      "This trainer confirms split legality and strategy; it does not play out both split hands yet."
    );
    setFeedback(
      matchesStrategy ? "Legal split, recommended" : "Legal split, strategy miss",
      "You split the pair into two hands with a second equal practice bet.",
      matchesStrategy ? strategy.reason : `Split is legal here, but beginner strategy recommends ${labelAction(recommended)}. ${strategy.reason}`
    );
    addHistory(`Split ${cardName(practice.player[0])} and ${cardName(practice.player[1])}.`);
  }

  if (action === "surrender") {
    settleSurrender();
    setFeedback(
      matchesStrategy ? "Legal surrender, recommended" : "Legal surrender, strategy miss",
      "You surrendered the hand and gave up half the practice bet.",
      matchesStrategy ? strategy.reason : `Surrender is legal here, but beginner strategy recommends ${labelAction(recommended)}. ${strategy.reason}`
    );
    addHistory("Surrendered for half the practice bet.");
  }

  renderPractice();
  renderMistakeReview();
}

function loadScenario(index) {
  scenarioIndex = (index + scenarios.length) % scenarios.length;
  practice = createPractice(scenarios[scenarioIndex]);
  document.querySelector("#scenario-select").value = practice.scenario.id;
  const strategy = strategyFor(practice.player, practice.dealer[0], tableRules);
  setFeedback(
    "Scenario loaded",
    practice.scenario.summary,
    `Recommended beginner move: ${labelAction(strategy.action)}. ${strategy.reason}`
  );
  renderPractice();
}

function bindEvents() {
  bindRuleControls();

  document.querySelectorAll(".nav-button").forEach((button) => {
    button.addEventListener("click", () => showView(button.dataset.view));
  });

  document.querySelectorAll("[data-jump]").forEach((button) => {
    button.addEventListener("click", () => showView(button.dataset.jump));
  });

  document.querySelector("#lesson-progress").addEventListener("click", (event) => {
    const button = event.target.closest("[data-lesson]");
    if (!button) return;
    lessonIndex = Number(button.dataset.lesson);
    renderTutorial();
  });

  document.querySelector("#lesson-back").addEventListener("click", () => {
    lessonIndex = Math.max(0, lessonIndex - 1);
    renderTutorial();
  });

  document.querySelector("#lesson-next").addEventListener("click", () => {
    if (lessonIndex === lessons.length - 1) {
      setFeedback("Tutorial complete", "You finished the guided lessons. Try one illegal move and one recommended move in Practice.", "Good table confidence starts with knowing legality before strategy.");
      showView("practice");
      return;
    }
    lessonIndex += 1;
    renderTutorial();
  });

  document.querySelector("#restart-tutorial").addEventListener("click", () => {
    lessonIndex = 0;
    renderTutorial();
  });

  document.querySelector("#scenario-select").addEventListener("change", (event) => {
    const index = scenarios.findIndex((scenario) => scenario.id === event.target.value);
    loadScenario(index);
  });

  document.querySelector("#next-scenario").addEventListener("click", () => loadScenario(scenarioIndex + 1));
  document.querySelector("#reset-practice").addEventListener("click", () => loadScenario(scenarioIndex));

  document.querySelectorAll("[data-action]").forEach((button) => {
    button.addEventListener("click", () => performAction(button.dataset.action));
  });

  document.querySelectorAll(".drill-answer").forEach((button) => {
    button.addEventListener("click", () => answerDrill(button.dataset.drillAction));
  });

  document.querySelector("#next-drill").addEventListener("click", nextDrill);
  document.querySelector("#reset-drills").addEventListener("click", resetDrills);

  document.querySelectorAll(".strategy-chart").forEach((chart) => {
    chart.addEventListener("click", (event) => {
      const button = event.target.closest("[data-chart-kind]");
      if (!button) return;
      openChartDetail(button.dataset.chartKind, button.dataset.chartRow, button.dataset.chartDealer);
    });
    chart.addEventListener("mouseover", (event) => {
      const button = event.target.closest("[data-chart-kind]");
      if (!button || !chart.contains(button)) return;
      highlightChartAxes(button);
    });
    chart.addEventListener("focusin", (event) => {
      const button = event.target.closest("[data-chart-kind]");
      if (!button || !chart.contains(button)) return;
      highlightChartAxes(button);
    });
    chart.addEventListener("mouseleave", () => clearChartAxisHighlights(chart));
    chart.addEventListener("focusout", (event) => {
      if (!chart.contains(event.relatedTarget)) {
        clearChartAxisHighlights(chart);
      }
    });
  });

  document.querySelector("#chart-reset-detail").addEventListener("click", () => setChartDetail(null));

  document.querySelector("#clear-mistakes").addEventListener("click", () => {
    mistakes = [];
    saveMistakes();
    renderMistakeReview();
  });

  document.querySelector("#mistake-list").addEventListener("click", (event) => {
    const button = event.target.closest("[data-review-scenario]");
    if (!button) return;
    const index = scenarios.findIndex((scenario) => scenario.id === button.dataset.reviewScenario);
    if (index >= 0) {
      loadScenario(index);
      showView("practice");
    }
  });

  document.querySelectorAll(".panel-tab").forEach((button) => {
    button.addEventListener("click", () => {
      document.querySelectorAll(".panel-tab").forEach((tab) => tab.classList.toggle("active", tab === button));
      document.querySelectorAll(".panel-body").forEach((panel) => panel.classList.toggle("active", panel.id === `${button.dataset.panel}-panel`));
    });
  });
}

initThemeControls();
renderRuleControls();
renderStrategy();
renderTutorial();
renderPractice();
renderDrill();
renderStrategyCharts();
setChartDetail(null);
renderMistakeReview();
bindEvents();
