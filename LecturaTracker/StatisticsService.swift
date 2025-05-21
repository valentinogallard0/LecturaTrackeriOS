//
//  StatisticsService.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import Foundation

class StatisticsService {
    
    // MARK: - Main Statistics Calculation
    static func calculateStatistics(for books: [Book]) -> ReadingStatistics {
        let completedBooks = books.filter { $0.finishDate != nil }
        let currentlyReadingBooks = books.filter { $0.finishDate == nil && $0.currentPage > 0 }
        
        return ReadingStatistics(
            totalBooksRead: completedBooks.count,
            totalPagesRead: calculateTotalPagesRead(books: books),
            currentlyReading: currentlyReadingBooks.count,
            averagePagesPerDay: calculateAveragePagesPerDay(books: books),
            readingStreak: calculateCurrentReadingStreak(books: books),
            totalReadingDays: calculateTotalReadingDays(books: books),
            averageBookCompletionTime: calculateAverageCompletionTime(books: completedBooks),
            weeklyProgress: calculateWeeklyProgress(books: books),
            monthlyProgress: calculateMonthlyProgress(books: books),
            genreDistribution: [:], // Por ahora vacío, se puede implementar después
            estimatedTimeToFinishCurrent: calculateTimeEstimates(books: currentlyReadingBooks)
        )
    }
    
    // MARK: - Individual Calculations
    
    private static func calculateTotalPagesRead(books: [Book]) -> Int {
        return books.reduce(0) { total, book in
            total + book.currentPage
        }
    }
    
    private static func calculateAveragePagesPerDay(books: [Book]) -> Double {
        let allEntries = books.flatMap { $0.readingHistory }
        guard !allEntries.isEmpty else { return 0.0 }
        
        let totalPages = allEntries.reduce(0) { $0 + $1.pagesRead }
        return Double(totalPages) / Double(allEntries.count)
    }
    
    private static func calculateCurrentReadingStreak(books: [Book]) -> Int {
        let allEntries = books.flatMap { $0.readingHistory }
        let sortedDates = Set(allEntries.map { Calendar.current.startOfDay(for: $0.date) })
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Verificar si se leyó hoy o ayer para mantener la racha
        if sortedDates.contains(today) {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        } else if sortedDates.contains(calendar.date(byAdding: .day, value: -1, to: today)!) {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -2, to: today)!
        } else {
            return 0
        }
        
        // Contar días consecutivos hacia atrás
        while sortedDates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    private static func calculateTotalReadingDays(books: [Book]) -> Int {
        let allEntries = books.flatMap { $0.readingHistory }
        let uniqueDates = Set(allEntries.map { Calendar.current.startOfDay(for: $0.date) })
        return uniqueDates.count
    }
    
    private static func calculateAverageCompletionTime(books: [Book]) -> Double {
        let completedWithStartDate = books.filter { book in
            book.finishDate != nil && book.startDate != nil
        }
        
        guard !completedWithStartDate.isEmpty else { return 0.0 }
        
        let totalDays = completedWithStartDate.reduce(0.0) { total, book in
            guard let startDate = book.startDate,
                  let finishDate = book.finishDate else { return total }
            
            let days = Calendar.current.dateComponents([.day], from: startDate, to: finishDate).day ?? 0
            return total + Double(days)
        }
        
        return totalDays / Double(completedWithStartDate.count)
    }
    
    private static func calculateWeeklyProgress(books: [Book]) -> [WeeklyData] {
        let calendar = Calendar.current
        let allEntries = books.flatMap { $0.readingHistory }
        
        // Obtener las últimas 8 semanas
        var weeklyData: [WeeklyData] = []
        
        for weekOffset in 0..<8 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekStartOfWeek = calendar.dateInterval(of: .weekOfYear, for: weekStart)!.start
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStartOfWeek)!
            
            let weekEntries = allEntries.filter { entry in
                entry.date >= weekStartOfWeek && entry.date <= weekEnd
            }
            
            let pagesRead = weekEntries.reduce(0) { $0 + $1.pagesRead }
            
            // Calcular libros completados en esta semana
            let booksCompleted = books.filter { book in
                guard let finishDate = book.finishDate else { return false }
                return finishDate >= weekStartOfWeek && finishDate <= weekEnd
            }.count
            
            weeklyData.append(WeeklyData(
                weekStart: weekStartOfWeek,
                pagesRead: pagesRead,
                booksCompleted: booksCompleted
            ))
        }
        
        return weeklyData.reversed() // Mostrar desde la más antigua a la más reciente
    }
    
    private static func calculateMonthlyProgress(books: [Book]) -> [MonthlyData] {
        let calendar = Calendar.current
        let allEntries = books.flatMap { $0.readingHistory }
        
        // Obtener los últimos 6 meses
        var monthlyData: [MonthlyData] = []
        
        for monthOffset in 0..<6 {
            let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: Date())!
            let monthStartOfMonth = calendar.dateInterval(of: .month, for: monthStart)!.start
            let monthEnd = calendar.dateInterval(of: .month, for: monthStart)!.end
            
            let monthEntries = allEntries.filter { entry in
                entry.date >= monthStartOfMonth && entry.date < monthEnd
            }
            
            let pagesRead = monthEntries.reduce(0) { $0 + $1.pagesRead }
            
            // Calcular libros completados en este mes
            let booksCompleted = books.filter { book in
                guard let finishDate = book.finishDate else { return false }
                return finishDate >= monthStartOfMonth && finishDate < monthEnd
            }.count
            
            monthlyData.append(MonthlyData(
                month: monthStartOfMonth,
                pagesRead: pagesRead,
                booksCompleted: booksCompleted
            ))
        }
        
        return monthlyData.reversed() // Mostrar desde el más antiguo al más reciente
    }
    
    private static func calculateTimeEstimates(books: [Book]) -> [BookTimeEstimate] {
        return books.compactMap { book in
            guard book.pagesRemaining > 0 else { return nil }
            
            // Calcular promedio de páginas por día para este libro específico
            let bookEntries = book.readingHistory
            guard !bookEntries.isEmpty else {
                // Si no hay historial, usar estimación general
                let estimatedDays = Int(Double(book.pagesRemaining) / 20.0) // 20 páginas por día por defecto
                let finishDate = Calendar.current.date(byAdding: .day, value: estimatedDays, to: Date()) ?? Date()
                return BookTimeEstimate(
                    book: book,
                    estimatedDaysToFinish: estimatedDays,
                    estimatedFinishDate: finishDate
                )
            }
            
            let totalPagesRead = bookEntries.reduce(0) { $0 + $1.pagesRead }
            let readingDays = bookEntries.count
            let averagePagesPerDay = Double(totalPagesRead) / Double(readingDays)
            
            let estimatedDays = Int(ceil(Double(book.pagesRemaining) / max(averagePagesPerDay, 1.0)))
            let finishDate = Calendar.current.date(byAdding: .day, value: estimatedDays, to: Date()) ?? Date()
            
            return BookTimeEstimate(
                book: book,
                estimatedDaysToFinish: estimatedDays,
                estimatedFinishDate: finishDate
            )
        }
    }
    
    // MARK: - Utility Methods
    
    static func getRecentReadingData(books: [Book], days: Int = 30) -> [DailyReadingData] {
        let calendar = Calendar.current
        let allEntries = books.flatMap { $0.readingHistory }
        
        var dailyData: [DailyReadingData] = []
        
        for dayOffset in 0..<days {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            
            let dayEntries = allEntries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: dayStart)
            }
            
            let pagesRead = dayEntries.reduce(0) { $0 + $1.pagesRead }
            let booksActive = Set(dayEntries.map { entry in
                books.first { book in
                    book.readingHistory.contains { $0.id == entry.id }
                }?.id
            }).count
            
            dailyData.append(DailyReadingData(
                date: dayStart,
                pagesRead: pagesRead,
                booksActive: booksActive
            ))
        }
        
        return dailyData.reversed()
    }
}
