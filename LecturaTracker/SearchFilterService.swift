//
//  SearchFilterService.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import Foundation

class SearchFilterService {
    
    // MARK: - Main Filter Function
    static func filterAndSortBooks(_ books: [Book], with settings: FilterSettings) -> [Book] {
        var filteredBooks = books
        
        // Apply search text filter
        if !settings.searchText.isEmpty {
            filteredBooks = filteredBooks.filter { $0.matchesSearchText(settings.searchText) }
        }
        
        // Apply status filter
        filteredBooks = filteredBooks.filter { book in
            settings.selectedStatus.contains(book.status)
        }
        
        // Apply genre filter
        filteredBooks = filteredBooks.filter { book in
            settings.selectedGenres.contains(book.genre)
        }
        
        // Apply year filter
        if !settings.selectedYears.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                let bookYears = [book.yearAdded, book.yearStarted, book.yearCompleted].compactMap { $0 }
                return bookYears.contains { settings.selectedYears.contains($0) }
            }
        }
        
        // Apply sorting
        return sortBooks(filteredBooks, by: settings.sortOption)
    }
    
    // MARK: - Sorting Functions
    private static func sortBooks(_ books: [Book], by sortOption: SortOption) -> [Book] {
        switch sortOption {
        case .titleAZ:
            return books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            
        case .titleZA:
            return books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
            
        case .authorAZ:
            return books.sorted { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
            
        case .authorZA:
            return books.sorted { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedDescending }
            
        case .dateAddedNewest:
            return books.sorted { $0.dateAdded > $1.dateAdded }
            
        case .dateAddedOldest:
            return books.sorted { $0.dateAdded < $1.dateAdded }
            
        case .progressHigh:
            return books.sorted { $0.readingProgress > $1.readingProgress }
            
        case .progressLow:
            return books.sorted { $0.readingProgress < $1.readingProgress }
            
        case .pagesHigh:
            return books.sorted { $0.totalPages > $1.totalPages }
            
        case .pagesLow:
            return books.sorted { $0.totalPages < $1.totalPages }
            
        case .recentlyRead:
            return books.sorted { book1, book2 in
                let date1 = book1.lastReadDate ?? Date.distantPast
                let date2 = book2.lastReadDate ?? Date.distantPast
                return date1 > date2
            }
        }
    }
    
    // MARK: - Utility Functions
    
    // Get unique years from books
    static func getAvailableYears(from books: [Book]) -> [Int] {
        var years: Set<Int> = []
        
        for book in books {
            years.insert(book.yearAdded)
            
            if let yearStarted = book.yearStarted {
                years.insert(yearStarted)
            }
            
            if let yearCompleted = book.yearCompleted {
                years.insert(yearCompleted)
            }
        }
        
        return Array(years).sorted(by: >)
    }
    
    // Get genre distribution
    static func getGenreDistribution(from books: [Book]) -> [BookGenre: Int] {
        var distribution: [BookGenre: Int] = [:]
        
        for book in books {
            distribution[book.genre, default: 0] += 1
        }
        
        return distribution
    }
    
    // Get status distribution
    static func getStatusDistribution(from books: [Book]) -> [BookStatus: Int] {
        var distribution: [BookStatus: Int] = [:]
        
        for book in books {
            distribution[book.status, default: 0] += 1
        }
        
        return distribution
    }
    
    // Get books count for each status
    static func getBooksCount(for status: BookStatus, in books: [Book]) -> Int {
        return books.filter { $0.status == status }.count
    }
    
    // Get books count for each genre
    static func getBooksCount(for genre: BookGenre, in books: [Book]) -> Int {
        return books.filter { $0.genre == genre }.count
    }
    
    // Quick filter presets
    static func getQuickFilterPresets() -> [QuickFilter] {
        return [
            QuickFilter(
                name: "Leyendo ahora",
                icon: "book.open",
                filter: { settings in
                    settings.selectedStatus = [.reading]
                    settings.selectedGenres = Set(BookGenre.allCases)
                }
            ),
            QuickFilter(
                name: "Terminados este año",
                icon: "checkmark.circle",
                filter: { settings in
                    settings.selectedStatus = [.completed]
                    settings.selectedYears = [Calendar.current.component(.year, from: Date())]
                }
            ),
            QuickFilter(
                name: "Pendientes",
                icon: "clock",
                filter: { settings in
                    settings.selectedStatus = [.pending]
                    settings.selectedGenres = Set(BookGenre.allCases)
                }
            ),
            QuickFilter(
                name: "Ficción",
                icon: "wand.and.stars",
                filter: { settings in
                    settings.selectedGenres = [.fiction, .fantasy, .scienceFiction, .mystery, .romance]
                    settings.selectedStatus = Set(BookStatus.allCases)
                }
            ),
            QuickFilter(
                name: "No ficción",
                icon: "lightbulb",
                filter: { settings in
                    settings.selectedGenres = [.nonFiction, .biography, .history, .selfHelp, .business, .science]
                    settings.selectedStatus = Set(BookStatus.allCases)
                }
            )
        ]
    }
}

// MARK: - Quick Filter Model
struct QuickFilter {
    let name: String
    let icon: String
    let filter: (inout FilterSettings) -> Void
}
