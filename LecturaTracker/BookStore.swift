//
//  BookStore.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// Clase para gestionar el almacenamiento de datos
class BookStore: ObservableObject {
    @Published var books: [Book] = []
    
    private let booksKey = "savedBooks"
    
    init() {
        loadBooks()
    }
    
    func saveBooks() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(books)
            UserDefaults.standard.set(data, forKey: booksKey)
        } catch {
            print("Error al guardar los libros: \(error.localizedDescription)")
        }
    }
    
    func loadBooks() {
        guard let data = UserDefaults.standard.data(forKey: booksKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            books = try decoder.decode([Book].self, from: data)
        } catch {
            print("Error al cargar los libros: \(error.localizedDescription)")
        }
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    func deleteBook(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
        saveBooks()
    }
}
