//
//  SettingsView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingThemeSelector = false
    @State private var showingColorSchemeSelector = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                // MARK: - Appearance Section
                Section(header: sectionHeader("Apariencia")) {
                    // Theme Selection
                    Button(action: {
                        showingThemeSelector = true
                    }) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading) {
                                Text("Tema")
                                    .foregroundColor(.primary)
                                Text(themeManager.currentTheme.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(themeManager.currentTheme.primaryColor)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .scaleIn(delay: 0.1)
                    
                    // Color Scheme Selection
                    Button(action: {
                        showingColorSchemeSelector = true
                    }) {
                        HStack {
                            Image(systemName: colorSchemeIcon)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 25)
                            
                            VStack(alignment: .leading) {
                                Text("Modo de color")
                                    .foregroundColor(.primary)
                                Text(colorSchemeDisplayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    .scaleIn(delay: 0.2)
                }
                
                // MARK: - About Section
                Section(header: sectionHeader("Acerca de")) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .frame(width: 25)
                        
                        VStack(alignment: .leading) {
                            Text("Versión")
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .fadeIn(delay: 0.3)
                    
                    Button(action: {
                        // Add feedback action
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 25)
                            
                            Text("Enviar comentarios")
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                    .fadeIn(delay: 0.4)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarItems(trailing: Button("Listo") {
                dismiss()
            })
            .sheet(isPresented: $showingThemeSelector) {
                ThemeSelectorView()
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingColorSchemeSelector) {
                ColorSchemeSelectorView()
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(themeManager.currentTheme.primaryColor)
    }
    
    // MARK: - Computed Properties
    private var colorSchemeIcon: String {
        switch themeManager.colorScheme {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .none: return "circle.lefthalf.filled"
        }
    }
    
    private var colorSchemeDisplayName: String {
        switch themeManager.colorScheme {
        case .dark: return "Oscuro"
        case .light: return "Claro"
        case .none: return "Sistema"
        }
    }
}

// MARK: - Theme Selector View
struct ThemeSelectorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme == themeManager.currentTheme
                        ) {
                            withAnimation(.spring()) {
                                themeManager.setTheme(theme)
                            }
                            
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                        .scaleIn(delay: Double(AppTheme.allCases.firstIndex(of: theme) ?? 0) * 0.1)
                    }
                }
                .padding()
            }
            .navigationTitle("Elegir tema")
            .navigationBarItems(trailing: Button("Listo") {
                dismiss()
            })
        }
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Color Preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: theme.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 30, height: 30)
                            )
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(theme.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .bouncyButton(theme: theme)
    }
}

// MARK: - Color Scheme Selector View
struct ColorSchemeSelectorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ColorSchemeOption(
                    title: "Sistema",
                    subtitle: "Sigue la configuración del dispositivo",
                    icon: "circle.lefthalf.filled",
                    isSelected: themeManager.colorScheme == nil
                ) {
                    withAnimation(.easeInOut) {
                        themeManager.setColorScheme(nil)
                    }
                }
                .fadeIn(delay: 0.1)
                
                ColorSchemeOption(
                    title: "Claro",
                    subtitle: "Siempre usar modo claro",
                    icon: "sun.max.fill",
                    isSelected: themeManager.colorScheme == .light
                ) {
                    withAnimation(.easeInOut) {
                        themeManager.setColorScheme(.light)
                    }
                }
                .fadeIn(delay: 0.2)
                
                ColorSchemeOption(
                    title: "Oscuro",
                    subtitle: "Siempre usar modo oscuro",
                    icon: "moon.fill",
                    isSelected: themeManager.colorScheme == .dark
                ) {
                    withAnimation(.easeInOut) {
                        themeManager.setColorScheme(.dark)
                    }
                }
                .fadeIn(delay: 0.3)
            }
            .navigationTitle("Modo de color")
            .navigationBarItems(trailing: Button("Listo") {
                dismiss()
            })
        }
    }
}

// MARK: - Color Scheme Option
struct ColorSchemeOption: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            action()
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 25)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .secondary)
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}
