//
//  SearchFilterView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct SearchFilterView: View {
    // MARK: - Properties
    @Binding var filterSettings: FilterSettings
    @ObservedObject var bookStore: BookStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Local State
    @State private var selectedSection: FilterSection = .status
    
    enum FilterSection: String, CaseIterable {
        case status = "Estado"
        case genre = "Género"
        case year = "Año"
        case sort = "Ordenar"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // MARK: - Quick Filters
                quickFiltersSection
                
                Divider()
                
                // MARK: - Filter Sections
                HStack(spacing: 0) {
                    // Section Tabs
                    sectionTabs
                    
                    Divider()
                    
                    // Content Area
                    filterContentArea
                }
            }
            .navigationTitle("Filtros y Búsqueda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        withAnimation(.easeInOut) {
                            filterSettings.reset()
                        }
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
    
    // MARK: - Quick Filters Section
    private var quickFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtros rápidos")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(SearchFilterService.getQuickFilterPresets(), id: \.name) { preset in
                        QuickFilterButton(
                            preset: preset,
                            filterSettings: $filterSettings,
                            theme: themeManager.currentTheme
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Section Tabs
    private var sectionTabs: some View {
        VStack(spacing: 0) {
            ForEach(FilterSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSection = section
                    }
                }) {
                    HStack {
                        Text(section.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedSection == section ? .semibold : .regular)
                        
                        Spacer()
                        
                        if section == .status || section == .genre {
                            // Show count badge
                            let count = getActiveFilterCount(for: section)
                            if count < getTotalCount(for: section) {
                                Text("\(count)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(themeManager.currentTheme.primaryColor)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        selectedSection == section ?
                        themeManager.currentTheme.primaryColor.opacity(0.1) :
                        Color.clear
                    )
                    .overlay(
                        Rectangle()
                            .fill(themeManager.currentTheme.primaryColor)
                            .frame(width: selectedSection == section ? 3 : 0)
                            .animation(.easeInOut, value: selectedSection),
                        alignment: .trailing
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(width: 120)
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    // MARK: - Filter Content Area
    private var filterContentArea: some View {
        Group {
            switch selectedSection {
            case .status:
                statusFilterView
            case .genre:
                genreFilterView
            case .year:
                yearFilterView
            case .sort:
                sortFilterView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Status Filter View
    private var statusFilterView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(BookStatus.allCases, id: \.self) { status in
                    FilterRow(
                        title: status.displayName,
                        icon: status.iconName,
                        count: SearchFilterService.getBooksCount(for: status, in: bookStore.books),
                        isSelected: filterSettings.selectedStatus.contains(status),
                        theme: themeManager.currentTheme
                    ) {
                        withAnimation(.easeInOut) {
                            if filterSettings.selectedStatus.contains(status) {
                                filterSettings.selectedStatus.remove(status)
                            } else {
                                filterSettings.selectedStatus.insert(status)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Genre Filter View
    private var genreFilterView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(BookGenre.allCases, id: \.self) { genre in
                    FilterRow(
                        title: genre.displayName,
                        icon: genre.iconName,
                        count: SearchFilterService.getBooksCount(for: genre, in: bookStore.books),
                        isSelected: filterSettings.selectedGenres.contains(genre),
                        theme: themeManager.currentTheme
                    ) {
                        withAnimation(.easeInOut) {
                            if filterSettings.selectedGenres.contains(genre) {
                                filterSettings.selectedGenres.remove(genre)
                            } else {
                                filterSettings.selectedGenres.insert(genre)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Year Filter View
    private var yearFilterView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                let availableYears = SearchFilterService.getAvailableYears(from: bookStore.books)
                
                if availableYears.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No hay años disponibles")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Los años aparecerán aquí cuando añadas libros con fechas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ForEach(availableYears, id: \.self) { year in
                        FilterRow(
                            title: "\(year)",
                            icon: "calendar",
                            count: getBooksCountForYear(year),
                            isSelected: filterSettings.selectedYears.contains(year),
                            theme: themeManager.currentTheme
                        ) {
                            withAnimation(.easeInOut) {
                                if filterSettings.selectedYears.contains(year) {
                                    filterSettings.selectedYears.remove(year)
                                } else {
                                    filterSettings.selectedYears.insert(year)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Sort Filter View
    private var sortFilterView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(SortOption.allCases, id: \.self) { sortOption in
                    FilterRow(
                        title: sortOption.displayName,
                        icon: sortOption.iconName,
                        count: nil,
                        isSelected: filterSettings.sortOption == sortOption,
                        theme: themeManager.currentTheme
                    ) {
                        withAnimation(.easeInOut) {
                            filterSettings.sortOption = sortOption
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Methods
    private func getActiveFilterCount(for section: FilterSection) -> Int {
        switch section {
        case .status:
            return filterSettings.selectedStatus.count
        case .genre:
            return filterSettings.selectedGenres.count
        case .year:
            return filterSettings.selectedYears.count
        case .sort:
            return 1
        }
    }
    
    private func getTotalCount(for section: FilterSection) -> Int {
        switch section {
        case .status:
            return BookStatus.allCases.count
        case .genre:
            return BookGenre.allCases.count
        case .year:
            return SearchFilterService.getAvailableYears(from: bookStore.books).count
        case .sort:
            return SortOption.allCases.count
        }
    }
    
    private func getBooksCountForYear(_ year: Int) -> Int {
        return bookStore.books.filter { book in
            book.yearAdded == year || book.yearStarted == year || book.yearCompleted == year
        }.count
    }
}

// MARK: - Quick Filter Button
struct QuickFilterButton: View {
    let preset: QuickFilter
    @Binding var filterSettings: FilterSettings
    let theme: AppTheme
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                preset.filter(&filterSettings)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.caption)
                
                Text(preset.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.primaryColor.opacity(0.1))
            .foregroundColor(theme.primaryColor)
            .cornerRadius(16)
        }
        .bouncyButton(theme: theme)
    }
}

// MARK: - Filter Row
struct FilterRow: View {
    let title: String
    let icon: String
    let count: Int?
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? theme.primaryColor : .secondary)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let count = count {
                    Text("(\(count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? theme.primaryColor : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.primaryColor.opacity(0.1) : Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct SearchFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFilterView(
            filterSettings: .constant(FilterSettings()),
            bookStore: BookStore()
        )
        .environmentObject(ThemeManager())
    }
}
