//
//  LibraryView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 20/05/25.
//

// Implementamos la vista detallada de libro

import SwiftUI

struct LibraryView: View {
    // MARK: - Properties
    @StateObject private var bookStore = BookStore()
    @State private var searchText = ""
    @State private var showingAddBookSheet = false
    
    // MARK: - Computed Properties
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return bookStore.books
        } else {
            return bookStore.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        TabView {
            
            // MARK: - Library Tab
            NavigationView {
                ZStack {
                    
                    // Books List
                    booksList
                    
                    // Floating Add Button
                    floatingAddButton
                }
                .navigationTitle("Mis lecturas")
                .searchable(text: $searchText, prompt: "Buscar Libros")
                .sheet(isPresented: $showingAddBookSheet) {
                    AddBookView(bookStore: bookStore)
                }
            }
            .tabItem {
                Image(systemName: "books.vertical")
                Text("Biblioteca")
            }
            
            // MARK: - Statistics Tab
            StatisticsView(bookStore: bookStore)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Estadísticas")
                }
        }
    }
    
    // MARK: - Books List View
    private var booksList: some View {
        Group {
            if filteredBooks.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink(destination: BookDetailView(bookStore: bookStore, book: book)) {
                            BookRow(book: book)
                        }
                    }
                    .onDelete(perform: deleteBooks)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Tu biblioteca está vacía")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Añade tu primer libro para comenzar a hacer seguimiento de tu lectura")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddBookSheet = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Añadir primer libro")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Floating Add Button
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingAddBookSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.bottom, 16)
                .padding(.trailing, 16)
                
                Spacer()
            }
        }
        .opacity(filteredBooks.isEmpty ? 0 : 1) // Hide when empty state is shown
        .animation(.easeInOut(duration: 0.3), value: filteredBooks.isEmpty)
    }
    
    // MARK: - Helper Methods
    private func deleteBooks(at offsets: IndexSet) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Delete books
        bookStore.deleteBook(at: offsets)
    }
}

// MARK: - Preview Provider
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .preferredColorScheme(.light)
        
        LibraryView()
            .preferredColorScheme(.dark)
    }
}
