//
//  MainAppView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct MainAppView: View {
    // MARK: - Properties
    @StateObject private var bookStore = BookStore()
    @StateObject private var themeManager = ThemeManager()
    @State private var searchText = ""
    @State private var showingAddBookSheet = false
    @State private var showingSettings = false
    
    // MARK: - Computed Properties
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return bookStore.books
        } else {
            return bookStore.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        TabView {
            
            // MARK: - Library Tab
            NavigationView {
                ZStack {
                    
                    // Background Theme
                    themeManager.currentTheme.secondaryBackgroundColor
                        .ignoresSafeArea()
                    
                    // Books List
                    booksList
                    
                    // Floating Add Button
                    floatingAddButton
                }
                .navigationTitle("Mis lecturas")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        settingsButton
                    }
                }
                .searchable(text: $searchText, prompt: "Buscar Libros")
                .sheet(isPresented: $showingAddBookSheet) {
                    AddBookView(bookStore: bookStore)
                        .environmentObject(themeManager)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(themeManager)
                }
            }
            .tabItem {
                Image(systemName: "books.vertical")
                Text("Biblioteca")
            }
            
            // MARK: - Statistics Tab
            StatisticsView(bookStore: bookStore)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Estadísticas")
                }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
        .preferredColorScheme(themeManager.colorScheme)
        .environmentObject(themeManager)
    }
    
    // MARK: - Settings Button
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
        .bouncyButton(theme: themeManager.currentTheme)
    }
    
    // MARK: - Books List View
    private var booksList: some View {
        Group {
            if filteredBooks.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(Array(filteredBooks.enumerated()), id: \.element.id) { index, book in
                        NavigationLink(destination: BookDetailView(bookStore: bookStore, book: book)
                            .environmentObject(themeManager)) {
                            EnhancedBookRow(book: book, theme: themeManager.currentTheme)
                        }
                        .listRowBackground(Color.clear)
                        .slideIn(delay: Double(index) * 0.1)
                    }
                    .onDelete(perform: deleteBooks)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 25) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: themeManager.currentTheme.gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .opacity(0.2)
                
                Image(systemName: "books.vertical")
                    .font(.system(size: 50))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .scaleIn(delay: 0.2)
            
            VStack(spacing: 12) {
                Text("Tu biblioteca está vacía")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .fadeIn(delay: 0.4)
                
                Text("Añade tu primer libro para comenzar a hacer seguimiento de tu lectura")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fadeIn(delay: 0.6)
            }
            
            Button(action: {
                showingAddBookSheet = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Añadir primer libro")
                }
                .font(.headline)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
            }
            .themedButton(themeManager.currentTheme)
            .bouncyButton(theme: themeManager.currentTheme)
            .scaleIn(delay: 0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .themedBackground(themeManager.currentTheme)
    }
    
    // MARK: - Floating Add Button
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingAddBookSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: themeManager.currentTheme.gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 15, x: 0, y: 5)
                }
                .scaleEffect(filteredBooks.isEmpty ? 0 : 1)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredBooks.isEmpty)
                .bouncyButton(theme: themeManager.currentTheme)
                .padding(.bottom, 20)
                .padding(.trailing, 20)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func deleteBooks(at offsets: IndexSet) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Animate deletion
        withAnimation(.easeInOut(duration: 0.3)) {
            bookStore.deleteBook(at: offsets)
        }
    }
}

// MARK: - Preview Provider
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .preferredColorScheme(.light)
        
        MainAppView()
            .preferredColorScheme(.dark)
    }
}
