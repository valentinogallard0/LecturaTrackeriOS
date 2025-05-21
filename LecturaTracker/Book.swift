//
//  Book.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct Book: Identifiable, Codable {
    var id = UUID() //Identificador único necesario para SwiftUI
    var title: String
    var author: String
    var coverImageData: Data? // Almacenamos la imagen como Data para poder codificarla
    var currentPage: Int
    var totalPages: Int
    var startDate: Date?
    var finishDate: Date?
    var notes: String = "" // Añadimos un campo para notas
    var readingHistory: [ReadingEntry] = [] // Historial de lectura diario
    
    // Propiedades computadas (no se codifican)
    var readingProgress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    
    // Propiedad computada para acceder a la imagen
    var coverImage: UIImage? {
        guard let imageData = coverImageData else { return nil }
        return UIImage(data: imageData)
    }
    
    // Inicializador para crear un libro con UIImage
    init(id: UUID = UUID(), title: String, author: String, coverImage: UIImage?, currentPage: Int, totalPages: Int, startDate: Date? = nil, finishDate: Date? = nil, notes: String = "", readingHistory: [ReadingEntry] = []) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageData = coverImage?.jpegData(compressionQuality: 0.7)
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.startDate = startDate
        self.finishDate = finishDate
        self.notes = notes
        self.readingHistory = readingHistory
    }
    
    // Función para registrar una entrada de lectura
    mutating func addReadingEntry(date: Date, pagesRead: Int, currentPage: Int) {
        // Si ya existe una entrada para esta fecha, la actualizamos
        if let index = readingHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            readingHistory[index].pagesRead = pagesRead
            readingHistory[index].currentPage = currentPage
        } else {
            // Si no existe, creamos una nueva
            let entry = ReadingEntry(date: date, pagesRead: pagesRead, currentPage: currentPage)
            readingHistory.append(entry)
        }
        
        // Ordenamos el historial por fecha (más reciente primero)
        readingHistory.sort { $0.date > $1.date }
    }
    
    // Función para obtener la entrada de un día específico
    func getReadingEntry(for date: Date) -> ReadingEntry? {
        return readingHistory.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
