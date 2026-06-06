import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case learn
    case practice
    case strategy
    case rules

    var id: String { rawValue }

    var title: String {
        switch self {
        case .learn: "Learn"
        case .practice: "Practice"
        case .strategy: "Strategy"
        case .rules: "Rules"
        }
    }

    var icon: String {
        switch self {
        case .learn: "graduationcap"
        case .practice: "gamecontroller"
        case .strategy: "tablecells"
        case .rules: "book.pages"
        }
    }
}

struct AppRootView: View {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @State private var selectedTab: AppTab = .learn
    @State private var rules = TableRules()

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                LearnView()
            }
            .tabItem { Label(AppTab.learn.title, systemImage: AppTab.learn.icon) }
            .tag(AppTab.learn)

            NavigationStack {
                PracticeTrainerView(rules: $rules)
            }
            .tabItem { Label(AppTab.practice.title, systemImage: AppTab.practice.icon) }
            .tag(AppTab.practice)

            NavigationStack {
                StrategyView(rules: $rules)
            }
            .tabItem { Label(AppTab.strategy.title, systemImage: AppTab.strategy.icon) }
            .tag(AppTab.strategy)

            NavigationStack {
                RulesReferenceView()
            }
            .tabItem { Label(AppTab.rules.title, systemImage: AppTab.rules.icon) }
            .tag(AppTab.rules)
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }
}
