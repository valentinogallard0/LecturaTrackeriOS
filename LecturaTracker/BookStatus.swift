//
//  BookStatus.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import Foundation

// MARK: - Book Status
enum BookStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case reading = "reading"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .reading: return "Leyendo"
        case .completed: return "Terminado"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .reading: return "book.open"
        case .completed: return "checkmark.circle"
        }
    }
}

// MARK: - Book Genre
enum BookGenre: String, CaseIterable, Codable {
    case fiction = "fiction"
    case nonFiction = "nonFiction"
    case mystery = "mystery"
    case romance = "romance"
    case scienceFiction = "scienceFiction"
    case fantasy = "fantasy"
    case biography = "biography"
    case history = "history"
    case selfHelp = "selfHelp"
    case business = "business"
    case health = "health"
    case travel = "travel"
    case cooking = "cooking"
    case art = "art"
    case poetry = "poetry"
    case drama = "drama"
    case comedy = "comedy"
    case horror = "horror"
    case adventure = "adventure"
    case philosophy = "philosophy"
    case religion = "religion"
    case science = "science"
    case technology = "technology"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .fiction: return "Ficción"
        case .nonFiction: return "No ficción"
        case .mystery: return "Misterio"
        case .romance: return "Romance"
        case .scienceFiction: return "Ciencia ficción"
        case .fantasy: return "Fantasía"
        case .biography: return "Biografía"
        case .history: return "Historia"
        case .selfHelp: return "Autoayuda"
        case .business: return "Negocios"
        case .health: return "Salud"
        case .travel: return "Viajes"
        case .cooking: return "Cocina"
        case .art: return "Arte"
        case .poetry: return "Poesía"
        case .drama: return "Drama"
        case .comedy: return "Comedia"
        case .horror: return "Terror"
        case .adventure: return "Aventura"
        case .philosophy: return "Filosofía"
        case .religion: return "Religión"
        case .science: return "Ciencia"
        case .technology: return "Tecnología"
        case .other: return "Otro"
        }
    }
    
    var iconName: String {
        switch self {
        case .fiction, .nonFiction: return "book"
        case .mystery: return "magnifyingglass"
        case .romance: return "heart"
        case .scienceFiction: return "globe"
        case .fantasy: return "wand.and.stars"
        case .biography: return "person"
        case .history: return "clock.arrow.circlepath"
        case .selfHelp: return "lightbulb"
        case .business: return "briefcase"
        case .health: return "cross"
        case .travel: return "airplane"
        case .cooking: return "fork.knife"
        case .art: return "paintbrush"
        case .poetry: return "quote.bubble"
        case .drama: return "theatermasks"
        case .comedy: return "face.smiling"
        case .horror: return "moon.zzz"
        case .adventure: return "mountain.2"
        case .philosophy: return "brain"
        case .religion: return "book.closed"
        case .science: return "atom"
        case .technology: return "laptopcomputer"
        case .other: return "ellipsis"
        }
    }
}

// MARK: - Sort Options
enum SortOption: String, CaseIterable {
    case titleAZ = "titleAZ"
    case titleZA = "titleZA"
    case authorAZ = "authorAZ"
    case authorZA = "authorZA"
    case dateAddedNewest = "dateAddedNewest"
    case dateAddedOldest = "dateAddedOldest"
    case progressHigh = "progressHigh"
    case progressLow = "progressLow"
    case pagesHigh = "pagesHigh"
    case pagesLow = "pagesLow"
    case recentlyRead = "recentlyRead"
    
    var displayName: String {
        switch self {
        case .titleAZ: return "Título (A-Z)"
        case .titleZA: return "Título (Z-A)"
        case .authorAZ: return "Autor (A-Z)"
        case .authorZA: return "Autor (Z-A)"
        case .dateAddedNewest: return "Más recientes"
        case .dateAddedOldest: return "Más antiguos"
        case .progressHigh: return "Mayor progreso"
        case .progressLow: return "Menor progreso"
        case .pagesHigh: return "Más páginas"
        case .pagesLow: return "Menos páginas"
        case .recentlyRead: return "Leído recientemente"
        }
    }
    
    var iconName: String {
        switch self {
        case .titleAZ, .titleZA: return "textformat"
        case .authorAZ, .authorZA: return "person"
        case .dateAddedNewest, .dateAddedOldest: return "calendar"
        case .progressHigh, .progressLow: return "chart.bar"
        case .pagesHigh, .pagesLow: return "doc"
        case .recentlyRead: return "clock"
        }
    }
}

// MARK: - Filter Settings
struct FilterSettings {
    var selectedStatus: Set<BookStatus> = Set(BookStatus.allCases)
    var selectedGenres: Set<BookGenre> = Set(BookGenre.allCases)
    var selectedYears: Set<Int> = []
    var sortOption: SortOption = .dateAddedNewest
    var searchText: String = ""
    
    var hasActiveFilters: Bool {
        return selectedStatus.count != BookStatus.allCases.count ||
               selectedGenres.count != BookGenre.allCases.count ||
               !selectedYears.isEmpty ||
               !searchText.isEmpty
    }
    
    mutating func reset() {
        selectedStatus = Set(BookStatus.allCases)
        selectedGenres = Set(BookGenre.allCases)
        selectedYears = []
        searchText = ""
    }
}
