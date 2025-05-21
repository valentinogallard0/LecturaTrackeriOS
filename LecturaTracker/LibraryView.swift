//
//  LibraryView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 20/05/25.
//

// Implementamos la vista detallada de libro

import SwiftUI

struct LibraryView: View {
    // Usamos el BookStore para la persistencia de datos
    @StateObject private var bookStore = BookStore()
    @State private var searchText = ""    // Texto de búsqueda vacío
    @State private var showingAddBookSheet = false // Modal oculto inicialmente
    
    // Computamos los libros filtrados basados en la búsqueda
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
    
    var body: some View {
        NavigationView {
            ZStack {
                //1. Lista de libros
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink(destination: BookDetailView(bookStore: bookStore, book: book)) {
                            BookRow(book: book)
                        }
                    }
                    .onDelete(perform: deleteBooks)
                }
                .listStyle(PlainListStyle())
                
                //2. Botón de añadir libro
                VStack {
                    Spacer() //Empuja el contenido hacia abajo
                    HStack {
                        Spacer() //Centra Horizontalmente
                        Button(action: {
                            showingAddBookSheet = true //muestra el modal al hacer clic
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 3)
                                .padding(.bottom, 16)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Mis lecturas") //Título en la parte superior
            .searchable(text: $searchText, prompt: "Buscar Libros") //Barra de búsqueda
            .sheet(isPresented: $showingAddBookSheet) {
                AddBookView(bookStore: bookStore) //Vista para añadir el libro
            }
        }
    }
    
    // Función para eliminar libros
    private func deleteBooks(at offsets: IndexSet) {
        bookStore.deleteBook(at: offsets)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
