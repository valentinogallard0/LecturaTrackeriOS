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
    
    // Para elegir entre métodos de actualización
    @State private var updateMethod = UpdateMethod.currentPage
    @State private var currentPageInput = ""
    @State private var pagesReadInput = ""
    @Environment(\.dismiss) private var dismiss
    
    // Tipos de actualización para la lectura
    enum UpdateMethod {
        case currentPage
        case pagesRead
    }
    
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
                    
                    LabeledContent("Páginas restantes", value: "\(book.pagesRemaining)")
                    
                    Picker("Método de actualización", selection: $updateMethod) {
                        Text("Indicar página actual").tag(UpdateMethod.currentPage)
                        Text("Indicar páginas leídas").tag(UpdateMethod.pagesRead)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 8)
                    
                    if updateMethod == .currentPage {
                        HStack {
                            Text("Llegué hasta la página:")
                            Spacer()
                            TextField("Página", text: $currentPageInput)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    } else {
                        HStack {
                            Text("Leí hoy:")
                            Spacer()
                            TextField("Páginas", text: $pagesReadInput)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("páginas")
                        }
                    }
                }
                
                Section(footer: Text("Tus lecturas se guardarán en el historial diario.")) {
                    Button(action: saveEntry) {
                        HStack {
                            Spacer()
                            Text("Guardar progreso de lectura")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(!isInputValid)
                }
                
                // Mostrar el historial del día si ya existe
                if let entry = book.getReadingEntry(for: date) {
                    Section(header: Text("Ya has leído hoy")) {
                        LabeledContent("Total de páginas leídas hoy", value: "\(entry.pagesRead)")
                        LabeledContent("Llegaste hasta la página", value: "\(entry.currentPage)")
                    }
                }
            }
            .navigationTitle("Registrar lectura")
            .navigationBarItems(
                trailing: Button("Cancelar") {
                    dismiss()
                }
            )
            .onAppear {
                // Inicializar con la página actual
                currentPageInput = "\(book.currentPage)"
            }
        }
    }
    
    // Validación de entrada
    private var isInputValid: Bool {
        if updateMethod == .currentPage {
            guard let pageNum = Int(currentPageInput) else { return false }
            return pageNum > book.currentPage && pageNum <= book.totalPages
        } else {
            guard let pagesRead = Int(pagesReadInput) else { return false }
            return pagesRead > 0 && (book.currentPage + pagesRead) <= book.totalPages
        }
    }
    
    private func saveEntry() {
        var updatedBook = book
        var pagesRead = 0
        var newCurrentPage = book.currentPage
        
        // Calcular las páginas leídas y la página actual
        if updateMethod == .currentPage {
            guard let pageNum = Int(currentPageInput), pageNum > book.currentPage, pageNum <= book.totalPages else { return }
            pagesRead = pageNum - book.currentPage
            newCurrentPage = pageNum
        } else {
            guard let numPages = Int(pagesReadInput), numPages > 0 else { return }
            pagesRead = numPages
            newCurrentPage = min(book.currentPage + numPages, book.totalPages)
        }
        
        // Actualizar la página actual
        updatedBook.currentPage = newCurrentPage
        
        // Registrar la entrada en el historial
        updatedBook.addReadingEntry(date: date, pagesRead: pagesRead, currentPage: newCurrentPage)
        
        // Si llegamos al final del libro, marcar como terminado
        if newCurrentPage == book.totalPages && updatedBook.finishDate == nil {
            updatedBook.finishDate = date
        }
        
        onSave(updatedBook)
        dismiss()
    }
}
