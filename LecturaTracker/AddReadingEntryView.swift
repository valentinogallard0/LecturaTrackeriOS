//
//  AddReadingEntryView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// Vista para añadir una entrada de lectura
struct AddReadingEntryView: View {
    let book: Book
    let date: Date
    let onSave: (Book) -> Void
    
    @State private var pagesRead = ""
    @Environment(\.dismiss) private var dismiss
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Registro de lectura")) {
                    LabeledContent("Día", value: formattedDate)
                    
                    LabeledContent("Página actual", value: "\(book.currentPage)")
                    
                    TextField("Páginas leídas hoy", text: $pagesRead)
                        .keyboardType(.numberPad)
                }
                
                Section(footer: Text("Este registro actualizará tu progreso actual de lectura.")) {
                    Button("Guardar registro") {
                        saveEntry()
                    }
                    .disabled(pagesRead.isEmpty || Int(pagesRead) == 0)
                }
            }
            .navigationTitle("Registrar lectura")
            .navigationBarItems(
                trailing: Button("Cancelar") {
                    dismiss()
                }
            )
        }
    }
    
    private func saveEntry() {
        guard let pagesReadInt = Int(pagesRead), pagesReadInt > 0 else { return }
        
        var updatedBook = book
        let newCurrentPage = min(book.currentPage + pagesReadInt, book.totalPages)
        updatedBook.currentPage = newCurrentPage
        
        // Registrar la entrada en el historial
        updatedBook.addReadingEntry(date: date, pagesRead: pagesReadInt, currentPage: newCurrentPage)
        
        // Si llegamos al final del libro, marcar como terminado
        if newCurrentPage == book.totalPages && updatedBook.finishDate == nil {
            updatedBook.finishDate = date
        }
        
        onSave(updatedBook)
        dismiss()
    }
}
