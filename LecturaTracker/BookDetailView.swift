//
//  BookDetailView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//


import SwiftUI

struct BookDetailView: View {
    // MARK: - Properties
    var bookStore: BookStore
    var book: Book
    
    @State private var currentPage: Int
    @State private var hasFinished: Bool = false
    @State private var showingUpdateProgress = false
    @State private var showingEditBook = false // Nuevo estado para mostrar el editor
    @State private var selectedDate: Date? = Date()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Initialization
    init(bookStore: BookStore, book: Book) {
        self.bookStore = bookStore
        self.book = book
        _currentPage = State(initialValue: book.currentPage)
        _hasFinished = State(initialValue: book.finishDate != nil)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Book Header Section
                bookHeaderSection
                
                Divider()
                
                // MARK: - Reading Calendar Section
                ReadingCalendarView(
                    book: book,
                    onEntrySelected: { date in
                        selectedDate = date
                    },
                    onUpdate: { updatedBook in
                        bookStore.updateBook(updatedBook)
                        currentPage = updatedBook.currentPage
                        hasFinished = updatedBook.finishDate != nil
                    }
                )
                
                // MARK: - Reading History Section
                if let selectedDate = selectedDate {
                    ReadingHistoryListView(book: book, selectedDate: selectedDate)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Detalles del libro")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditBook = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingUpdateProgress) {
            UpdateProgressView(
                currentPage: $currentPage,
                totalPages: book.totalPages,
                hasFinished: $hasFinished,
                onUpdate: saveProgress
            )
        }
        .sheet(isPresented: $showingEditBook) {
            EditBookView(bookStore: bookStore, book: book)
                .environmentObject(themeManager)
        }
        .onDisappear {
            saveProgress()
        }
    }
    
    // MARK: - Book Header View
    private var bookHeaderSection: some View {
        HStack(alignment: .top, spacing: 15) {
            
            // Book Cover Image
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
                    // Fallback: First letter of title
                    Text(String(book.title.prefix(1)))
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .cornerRadius(8)
            .shadow(radius: 3)
            
            // Book Information
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(book.author)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Género del libro
                HStack {
                    Image(systemName: book.genre.iconName)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text(book.genre.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                    .frame(height: 10)
                
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
                
                // Botón de edición rápida
                Button(action: {
                    showingEditBook = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Editar libro")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .cornerRadius(8)
                }
                .padding(.top, 5)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    private func saveProgress() {
        var updatedBook = book
        updatedBook.currentPage = currentPage
        
        // Update finish date if completed
        if hasFinished && book.finishDate == nil {
            updatedBook.finishDate = Date()
        } else if !hasFinished && book.finishDate != nil {
            // Remove finish date if marked as not finished
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

// MARK: - Preview Provider
struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookDetailView(
                bookStore: BookStore(),
                book: Book(
                    title: "El nombre del viento",
                    author: "Patrick Rothfuss",
                    coverImage: nil,
                    currentPage: 250,
                    totalPages: 662,
                    startDate: Date()
                )
            )
        }
        .environmentObject(ThemeManager())
    }
}
