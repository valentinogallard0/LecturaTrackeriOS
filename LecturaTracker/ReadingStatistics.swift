//
//  ReadingStatistics.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import Foundation

// Modelo para las estadísticas de lectura
struct ReadingStatistics {
    let totalBooksRead: Int
    let totalPagesRead: Int
    let currentlyReading: Int
    let averagePagesPerDay: Double
    let readingStreak: Int
    let totalReadingDays: Int
    let averageBookCompletionTime: Double // días
    let weeklyProgress: [WeeklyData]
    let monthlyProgress: [MonthlyData]
    let genreDistribution: [String: Int]
    let estimatedTimeToFinishCurrent: [BookTimeEstimate]
}

// Datos para gráficos semanales
struct WeeklyData: Identifiable, Codable {
    let id = UUID()
    let weekStart: Date
    let pagesRead: Int
    let booksCompleted: Int
    
    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: weekStart)
    }
}

// Datos para gráficos mensuales
struct MonthlyData: Identifiable, Codable {
    let id = UUID()
    let month: Date
    let pagesRead: Int
    let booksCompleted: Int
    
    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: month)
    }
}

// Estimación de tiempo para terminar libros actuales
struct BookTimeEstimate: Identifiable {
    let id = UUID()
    let book: Book
    let estimatedDaysToFinish: Int
    let estimatedFinishDate: Date
    
    var pagesRemaining: Int {
        return book.pagesRemaining
    }
}

// Datos para la racha de lectura
struct ReadingStreakData {
    let currentStreak: Int
    let longestStreak: Int
    let lastReadingDate: Date?
    let streakDates: [Date]
}

// Datos para el progreso diario
struct DailyReadingData: Identifiable {
    let id = UUID()
    let date: Date
    let pagesRead: Int
    let booksActive: Int
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}
