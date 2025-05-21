//
//  ThemeManager.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .blue
    @Published var colorScheme: ColorScheme? = nil // nil = system default
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    private let colorSchemeKey = "selectedColorScheme"
    
    init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme()
    }
    
    func setColorScheme(_ scheme: ColorScheme?) {
        colorScheme = scheme
        saveColorScheme()
    }
    
    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    private func saveColorScheme() {
        if let scheme = colorScheme {
            userDefaults.set(scheme == .dark ? "dark" : "light", forKey: colorSchemeKey)
        } else {
            userDefaults.removeObject(forKey: colorSchemeKey)
        }
    }
    
    private func loadTheme() {
        if let themeRaw = userDefaults.object(forKey: themeKey) as? String,
           let theme = AppTheme(rawValue: themeRaw) {
            currentTheme = theme
        }
        
        if let schemeRaw = userDefaults.object(forKey: colorSchemeKey) as? String {
            colorScheme = schemeRaw == "dark" ? .dark : .light
        }
    }
}

// MARK: - App Themes
enum AppTheme: String, CaseIterable {
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"
    case teal = "teal"
    case indigo = "indigo"
    case mint = "mint"
    
    var displayName: String {
        switch self {
        case .blue: return "Azul"
        case .green: return "Verde"
        case .purple: return "Morado"
        case .orange: return "Naranja"
        case .pink: return "Rosa"
        case .teal: return "Teal"
        case .indigo: return "Índigo"
        case .mint: return "Menta"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        case .pink: return .pink
        case .teal: return .teal
        case .indigo: return .indigo
        case .mint: return Color.mint
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .blue: return Color.blue.opacity(0.7)
        case .green: return Color.green.opacity(0.7)
        case .purple: return Color.purple.opacity(0.7)
        case .orange: return Color.orange.opacity(0.7)
        case .pink: return Color.pink.opacity(0.7)
        case .teal: return Color.teal.opacity(0.7)
        case .indigo: return Color.indigo.opacity(0.7)
        case .mint: return Color.mint.opacity(0.7)
        }
    }
    
    var accentColor: Color {
        return primaryColor
    }
    
    var gradientColors: [Color] {
        switch self {
        case .blue: return [Color.blue, Color.cyan]
        case .green: return [Color.green, Color.mint]
        case .purple: return [Color.purple, Color.pink]
        case .orange: return [Color.orange, Color.yellow]
        case .pink: return [Color.pink, Color.purple]
        case .teal: return [Color.teal, Color.blue]
        case .indigo: return [Color.indigo, Color.purple]
        case .mint: return [Color.mint, Color.green]
        }
    }
    
    var cardBackgroundColor: Color {
        return Color(.systemBackground)
    }
    
    var secondaryBackgroundColor: Color {
        return Color(.secondarySystemBackground)
    }
}

// MARK: - Button Styles (Outside of View extension)
struct BouncyButtonStyle: ButtonStyle {
    let theme: AppTheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Custom Button Style Enum
enum ThemedButtonStyle {
    case filled, outlined, ghost
}

// MARK: - Theme Extensions
extension View {
    func themedBackground(_ theme: AppTheme) -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: theme.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.1)
        )
    }
    
    func themedCard(_ theme: AppTheme) -> some View {
        self
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func themedButton(_ theme: AppTheme, style: ThemedButtonStyle = .filled) -> some View {
        switch style {
        case .filled:
            return AnyView(
                self
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: theme.gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            )
        case .outlined:
            return AnyView(
                self
                    .background(Color.clear)
                    .foregroundColor(theme.primaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.primaryColor, lineWidth: 2)
                    )
            )
        case .ghost:
            return AnyView(
                self
                    .background(theme.primaryColor.opacity(0.1))
                    .foregroundColor(theme.primaryColor)
                    .cornerRadius(10)
            )
        }
    }
    
    func bouncyButton(theme: AppTheme) -> some View {
        self.buttonStyle(BouncyButtonStyle(theme: theme))
    }
}

// MARK: - Animated View Modifiers
struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : 50)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Animation Extensions
extension View {
    func slideIn(delay: Double = 0) -> some View {
        self.modifier(SlideInModifier(delay: delay))
    }
    
    func scaleIn(delay: Double = 0) -> some View {
        self.modifier(ScaleInModifier(delay: delay))
    }
    
    func fadeIn(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }
}

// MARK: - Custom Progress View
struct ThemedProgressView: View {
    let progress: Double
    let theme: AppTheme
    let height: CGFloat
    
    init(progress: Double, theme: AppTheme, height: CGFloat = 8) {
        self.progress = progress
        self.theme = theme
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .cornerRadius(height / 2)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: theme.gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: height)
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: height)
    }
}
