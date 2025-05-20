//
//  LibraryView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 20/05/25.
//

import SwiftUI

struct Book: Identifiable{
    var id = UUID() //Identificador unico necesario para SwiftUI
    var title: String
    var author: String
    var coverImage: String
    var currentPage: Int
    var totalPages: Int
    var startDate: Date?
    var finishDate: Date?
    
    //Podemos calcular el progreso de lectura
    var readingProgress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
}





struct LibraryView: View {
    // Estados que necesitamos gestionar
    @State private var books: [Book] = [] // Array vacío inicialmente
    @State private var searchText = ""    // Texto de búsqueda vacío
    @State private var showingAddBookSheet = false // Modal oculto inicialmente
    
    
    
    // Computamos los libros filtrados basados en la búsqueda
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return books
        } else {
            return books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    var body: some View {
        NavigationView{
            ZStack{
                //1. Lista de libros
                List{
                    ForEach(filteredBooks) {book in
                        BookRow(book: book)
                    }
                }
                .listStyle(PlainListStyle())
                
                //2. Boton de anadir libro
                VStack{
                    Spacer() //Empuja el contenido hacia abajo
                    HStack{
                        Spacer() //Centra Horizontalmente
                        Button(action: {
                            showingAddBookSheet = true //mustra el modal al hacer clic
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
            .navigationTitle("Mis lecturas") //Titulo en la parte superior
            .searchable(text: $searchText, prompt: "Buscar Libros") //Barra de busqueda
            .sheet(isPresented: $showingAddBookSheet){
                AddBookView(books: $books)//Vista para anadir el libro
            }

        }
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            // Imagen de portada (simplificada por ahora)
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 90)
                
                // Podemos reemplazar esto con una imagen real después
                Text(String(book.title.prefix(1)))
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            .cornerRadius(5)
            .padding(.trailing, 8)
            
            // Información del libro
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Barra de progreso
                ProgressView(value: book.readingProgress)
                    .padding(.top, 4)
                
                // Texto de progreso
                Text("\(book.currentPage) de \(book.totalPages) páginas")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss // Para cerrar el modal
    @Binding var books: [Book] // Referencia a la lista de libros
    
    @State private var title = ""
    @State private var author = ""
    @State private var totalPages = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del libro")) {
                    TextField("Título", text: $title)
                    TextField("Autor", text: $author)
                    TextField("Número de páginas", text: $totalPages)
                        .keyboardType(.numberPad)
                }
                
                // Podríamos añadir más secciones aquí para datos adicionales
            }
            .navigationTitle("Añadir nuevo libro")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    dismiss() // Cierra el modal sin guardar
                },
                trailing: Button("Guardar") {
                    // Validamos y creamos un nuevo libro
                    if let pages = Int(totalPages), !title.isEmpty, !author.isEmpty {
                        let newBook = Book(
                            title: title,
                            author: author,
                            coverImage: "default", // Usamos un valor por defecto
                            currentPage: 0,
                            totalPages: pages,
                            startDate: Date() // Fecha actual como inicio
                        )
                        books.append(newBook)
                        dismiss() // Cerramos el modal
                    }
                }
                .disabled(title.isEmpty || author.isEmpty || totalPages.isEmpty)
            )
        }
    }
}






struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
