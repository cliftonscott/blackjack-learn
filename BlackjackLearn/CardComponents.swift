import SwiftUI

struct ScreenScrollView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            content
        }
        .scrollIndicators(.hidden)
    }
}

struct CardTile: View {
    let card: PlayingCard
    var size: CGFloat = 82

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(card.rank.rawValue)
                    .font(.system(size: size * 0.30, weight: .black, design: .rounded))
                Image(systemName: card.suit.symbolName)
                    .font(.system(size: size * 0.14, weight: .black))
            }
            Spacer(minLength: 0)
            Image(systemName: card.suit.symbolName)
                .font(.system(size: size * 0.30, weight: .black))
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Image(systemName: card.suit.symbolName)
                    .font(.system(size: size * 0.13, weight: .black))
                Text(card.rank.rawValue)
                    .font(.system(size: size * 0.16, weight: .black, design: .rounded))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .foregroundStyle(card.suit.tint)
        .frame(width: size, height: size * 1.32)
        .padding(size * 0.12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(card.suit.tint.opacity(0.75), lineWidth: 2)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 5)
        .accessibilityLabel(card.label)
    }
}

struct AppearanceControl: View {
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    private var selection: Binding<AppearanceMode> {
        Binding(
            get: { AppearanceMode(rawValue: appearanceModeRaw) ?? .system },
            set: { appearanceModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        InfoPanel(title: "Appearance", subtitle: "Choose how this app displays on your device.") {
            Picker("Appearance", selection: selection) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct InfoPanel<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

struct MoveButton: View {
    let action: MoveAction
    let isRecommended: Bool
    let perform: () -> Void

    var body: some View {
        Button(action: perform) {
            Label(action.label, systemImage: action.icon)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
        }
        .buttonStyle(.borderedProminent)
        .tint(isRecommended ? .green : .blue)
        .accessibilityHint(isRecommended ? "Recommended move" : "Practice this move")
    }
}

struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .frame(width: 5, height: 5)
                        .padding(.top, 8)
                    Text(item)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .font(.subheadline)
    }
}
