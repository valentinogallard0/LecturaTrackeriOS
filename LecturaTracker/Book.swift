//
//  Book.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct Book: Identifiable, Codable, Equatable {
    var id = UUID() //Identificador único necesario para SwiftUI
    var title: String
    var author: String
    var coverImageData: Data? // Almacenamos la imagen como Data para poder codificarla
    var currentPage: Int
    var totalPages: Int
    var startDate: Date?
    var finishDate: Date?
    var readingHistory: [ReadingEntry] = [] // Historial de lectura diario
    var genre: BookGenre = .other // Género del libro
    var dateAdded: Date = Date() // Fecha en que se añadió el libro
    
    // MARK: - Computed Properties
    
    // Estado del libro basado en su progreso
    var status: BookStatus {
        if let _ = finishDate {
            return .completed
        } else if currentPage > 0 {
            return .reading
        } else {
            return .pending
        }
    }
    
    // Año en que se añadió el libro
    var yearAdded: Int {
        Calendar.current.component(.year, from: dateAdded)
    }
    
    // Año en que se empezó a leer
    var yearStarted: Int? {
        guard let startDate = startDate else { return nil }
        return Calendar.current.component(.year, from: startDate)
    }
    
    // Año en que se terminó
    var yearCompleted: Int? {
        guard let finishDate = finishDate else { return nil }
        return Calendar.current.component(.year, from: finishDate)
    }
    
    // Fecha de última lectura
    var lastReadDate: Date? {
        return readingHistory.first?.date
    }
    
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
    
    // Obtener páginas restantes
    var pagesRemaining: Int {
        return totalPages - currentPage
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.author == rhs.author &&
               lhs.coverImageData == rhs.coverImageData &&
               lhs.currentPage == rhs.currentPage &&
               lhs.totalPages == rhs.totalPages &&
               lhs.startDate == rhs.startDate &&
               lhs.finishDate == rhs.finishDate &&
               lhs.readingHistory == rhs.readingHistory &&
               lhs.genre == rhs.genre &&
               lhs.dateAdded == rhs.dateAdded
    }
    
    // MARK: - Initializers
    
    // Inicializador para crear un libro con UIImage
    init(id: UUID = UUID(), title: String, author: String, coverImage: UIImage?, currentPage: Int, totalPages: Int, startDate: Date? = nil, finishDate: Date? = nil, readingHistory: [ReadingEntry] = [], genre: BookGenre = .other, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageData = coverImage?.jpegData(compressionQuality: 0.7)
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.startDate = startDate
        self.finishDate = finishDate
        self.readingHistory = readingHistory
        self.genre = genre
        self.dateAdded = dateAdded
    }
    
    // MARK: - Methods
    
    // Función para registrar una entrada de lectura
    mutating func addReadingEntry(date: Date, pagesRead: Int, currentPage: Int) {
        // Si ya existe una entrada para esta fecha, la actualizamos sumando las páginas
        if let index = readingHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            let updatedPagesRead = readingHistory[index].pagesRead + pagesRead
            readingHistory[index].pagesRead = updatedPagesRead
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
    
    // Verificar si coincide con el texto de búsqueda
    func matchesSearchText(_ searchText: String) -> Bool {
        if searchText.isEmpty { return true }
        
        let lowercasedSearch = searchText.lowercased()
        return title.lowercased().contains(lowercasedSearch) ||
               author.lowercased().contains(lowercasedSearch) ||
               genre.displayName.lowercased().contains(lowercasedSearch)
    }
}
