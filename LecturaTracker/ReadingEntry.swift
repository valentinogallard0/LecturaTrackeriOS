//
//  ReadingEntry.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import Foundation

// Estructura para cada entrada de lectura diaria
struct ReadingEntry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var pagesRead: Int
    var currentPage: Int
    
    // Formateadores para fechas
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // Fecha formateada para mostrar
    var formattedDate: String {
        ReadingEntry.dateFormatter.string(from: date)
    }
    
    // Nombre corto del día (ej: "Lun")
    var dayName: String {
        ReadingEntry.dayFormatter.string(from: date)
    }
    
    // Número del día (ej: "15")
    var dayNumber: String {
        ReadingEntry.dayNumberFormatter.string(from: date)
    }
}
