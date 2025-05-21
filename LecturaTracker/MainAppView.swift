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
    @State private var filterSettings = FilterSettings()
    @State private var showingAddBookSheet = false
    @State private var showingSettings = false
    @State private var showingFilters = false
    
    // MARK: - Computed Properties
    var filteredBooks: [Book] {
        return SearchFilterService.filterAndSortBooks(bookStore.books, with: filterSettings)
    }
    
    var hasActiveFilters: Bool {
        return filterSettings.hasActiveFilters
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        filterButton
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            sortButton
                            settingsButton
                        }
                    }
                }
                .searchable(text: $filterSettings.searchText, prompt: "Buscar por título, autor o género")
                .sheet(isPresented: $showingAddBookSheet) {
                    AddBookView(bookStore: bookStore)
                        .environmentObject(themeManager)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(themeManager)
                }
                .sheet(isPresented: $showingFilters) {
                    SearchFilterView(filterSettings: $filterSettings, bookStore: bookStore)
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
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: {
            showingFilters = true
        }) {
            HStack(spacing: 4) {
                Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                
                if hasActiveFilters {
                    Text("\(getActiveFilterCount())")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeManager.currentTheme.primaryColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(themeManager.currentTheme.primaryColor)
        }
        .bouncyButton(theme: themeManager.currentTheme)
    }
    
    // MARK: - Sort Button
    private var sortButton: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut) {
                        filterSettings.sortOption = option
                    }
                }) {
                    HStack {
                        Text(option.displayName)
                        
                        if filterSettings.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
        .bouncyButton(theme: themeManager.currentTheme)
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
        VStack {
            // Active Filters Summary
            if hasActiveFilters {
                activeFiltersSummary
            }
            
            // Books List
            Group {
                if filteredBooks.isEmpty {
                    if bookStore.books.isEmpty {
                        emptyLibraryView
                    } else {
                        emptyFilterResultsView
                    }
                } else {
                    List {
                        ForEach(Array(filteredBooks.enumerated()), id: \.element.id) { index, book in
                            NavigationLink(destination: BookDetailView(bookStore: bookStore, book: book)
                                .environmentObject(themeManager)) {
                                EnhancedBookRow(book: book, theme: themeManager.currentTheme)
                            }
                            .listRowBackground(Color.clear)
                            .slideIn(delay: Double(index) * 0.05)
                        }
                        .onDelete(perform: deleteBooks)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
        }
    }
    
    // MARK: - Active Filters Summary
    private var activeFiltersSummary: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Clear all filters button
                Button("Limpiar filtros") {
                    withAnimation(.easeInOut) {
                        filterSettings.reset()
                    }
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
                
                // Show active filters
                if filterSettings.selectedStatus.count < BookStatus.allCases.count {
                    Text("Estado: \(filterSettings.selectedStatus.count) seleccionados")
                        .filterChip(theme: themeManager.currentTheme)
                }
                
                if filterSettings.selectedGenres.count < BookGenre.allCases.count {
                    Text("Género: \(filterSettings.selectedGenres.count) seleccionados")
                        .filterChip(theme: themeManager.currentTheme)
                }
                
                if !filterSettings.selectedYears.isEmpty {
                    Text("Años: \(filterSettings.selectedYears.count) seleccionados")
                        .filterChip(theme: themeManager.currentTheme)
                }
                
                Text("Ordenado: \(filterSettings.sortOption.displayName)")
                    .filterChip(theme: themeManager.currentTheme)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Empty Library View
    private var emptyLibraryView: some View {
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
    
    // MARK: - Empty Filter Results View
    private var emptyFilterResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No se encontraron libros")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Intenta ajustar tus filtros de búsqueda")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Limpiar filtros") {
                withAnimation(.easeInOut) {
                    filterSettings.reset()
                }
            }
            .themedButton(themeManager.currentTheme, style: .outlined)
            .bouncyButton(theme: themeManager.currentTheme)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .scaleEffect(filteredBooks.isEmpty && bookStore.books.isEmpty ? 0 : 1)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredBooks.isEmpty && bookStore.books.isEmpty)
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
        
        // Get the actual books to delete from filtered list
        let booksToDelete = offsets.map { filteredBooks[$0] }
        
        // Find indices in the original books array
        let originalIndices = IndexSet(booksToDelete.compactMap { bookToDelete in
            bookStore.books.firstIndex { $0.id == bookToDelete.id }
        })
        
        // Animate deletion
        withAnimation(.easeInOut(duration: 0.3)) {
            bookStore.deleteBook(at: originalIndices)
        }
    }
    
    private func getActiveFilterCount() -> Int {
        var count = 0
        
        if filterSettings.selectedStatus.count < BookStatus.allCases.count {
            count += 1
        }
        
        if filterSettings.selectedGenres.count < BookGenre.allCases.count {
            count += 1
        }
        
        if !filterSettings.selectedYears.isEmpty {
            count += 1
        }
        
        if !filterSettings.searchText.isEmpty {
            count += 1
        }
        
        return count
    }
}

// MARK: - Extension for Filter Chip
extension Text {
    func filterChip(theme: AppTheme) -> some View {
        self
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.primaryColor.opacity(0.1))
            .foregroundColor(theme.primaryColor)
            .cornerRadius(12)
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
