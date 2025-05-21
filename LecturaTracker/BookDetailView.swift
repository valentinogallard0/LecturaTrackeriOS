//
//  BookDetailView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct BookDetailView: View {
    var bookStore: BookStore
    var book: Book
    
    @State private var currentPage: Int
    @State private var hasFinished: Bool = false
    @State private var showingUpdateProgress = false
    @State private var isEditingNotes = false
    @State private var notes: String = ""
    @State private var selectedDate: Date? = Date()
    @Environment(\.dismiss) private var dismiss
    
    init(bookStore: BookStore, book: Book) {
        self.bookStore = bookStore
        self.book = book
        _currentPage = State(initialValue: book.currentPage)
        _hasFinished = State(initialValue: book.finishDate != nil)
        _notes = State(initialValue: book.notes)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cabecera con imagen y detalles principales
                HStack(alignment: .top, spacing: 15) {
                    // Portada del libro
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 180)
                        
                        if let coverImage = book.coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 180)
                                .clipped()
                        } else {
                            Text(String(book.title.prefix(1)))
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    
                    // Detalles del libro
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Spacer().frame(height: 10)
                        
                        Text("\(book.totalPages) páginas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let startDate = book.startDate {
                            Text("Iniciado: \(formatDate(startDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let finishDate = book.finishDate {
                            Text("Terminado: \(formatDate(finishDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Calendario para registro diario
                ReadingCalendarView(book: book,
                                  onEntrySelected: { date in
                                      selectedDate = date
                                  },
                                  onUpdate: { updatedBook in
                                      var newBook = updatedBook
                                      newBook.notes = notes
                                      bookStore.updateBook(newBook)
                                      // Actualizamos la página actual en la vista
                                      currentPage = newBook.currentPage
                                      hasFinished = newBook.finishDate != nil
                                  })
                
                // Historial de lectura para la fecha seleccionada
                if selectedDate != nil {
                    ReadingHistoryListView(book: book, selectedDate: selectedDate)
                        .padding(.horizontal)
                }
                
                Divider()
                
                // Progreso de lectura
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progreso de lectura")
                        .font(.headline)
                    
                    ProgressView(value: Double(currentPage) / Double(book.totalPages))
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("\(currentPage) de \(book.totalPages) páginas")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int((Double(currentPage) / Double(book.totalPages)) * 100))%")
                            .fontWeight(.bold)
                    }
                    
                    Button(action: {
                        showingUpdateProgress = true
                    }) {
                        Label("Actualizar progreso", systemImage: "book")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Notas
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Notas")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            isEditingNotes.toggle()
                        }) {
                            Image(systemName: isEditingNotes ? "checkmark.circle.fill" : "square.and.pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if isEditingNotes {
                        TextEditor(text: $notes)
                            .frame(minHeight: 150)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    } else {
                        if notes.isEmpty {
                            Text("No hay notas para este libro")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            Text(notes)
                                .padding(8)
                                .frame(minHeight: 100)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalles del libro")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingUpdateProgress) {
            UpdateProgressView(
                currentPage: $currentPage,
                totalPages: book.totalPages,
                hasFinished: $hasFinished,
                onUpdate: saveProgress
            )
        }
        .onDisappear {
            saveProgress()
        }
    }
    
    private func saveProgress() {
        var updatedBook = book
        updatedBook.currentPage = currentPage
        updatedBook.notes = notes
        
        // Si ha terminado y no tenía fecha de finalización, la agregamos
        if hasFinished && book.finishDate == nil {
            updatedBook.finishDate = Date()
        }
        // Si no ha terminado pero tenía fecha de finalización, la quitamos
        else if !hasFinished && book.finishDate != nil {
            updatedBook.finishDate = nil
        }
        
        bookStore.updateBook(updatedBook)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
