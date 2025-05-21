//
//  LibraryView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 20/05/25.
//

import SwiftUI
import PhotosUI

// 1. Modificamos la estructura Book para gestionar imágenes reales
struct Book: Identifiable {
    var id = UUID() //Identificador único necesario para SwiftUI
    var title: String
    var author: String
    var coverImage: UIImage? // Ahora usamos UIImage en lugar de String
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

// 2. Implementamos la vista principal
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
        NavigationView {
            ZStack {
                //1. Lista de libros
                List {
                    ForEach(filteredBooks) { book in
                        BookRow(book: book)
                    }
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
                AddBookView(books: $books) //Vista para añadir el libro
            }
        }
    }
}

// 3. Modificamos BookRow para mostrar las imágenes reales
struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            // Imagen de portada (ahora muestra imágenes reales)
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 90)
                
                if let coverImage = book.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 90)
                        .clipped()
                } else {
                    // Fallback si no hay imagen
                    Text(String(book.title.prefix(1)))
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
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
                
                // Fecha de inicio de lectura (si existe)
                if let startDate = book.startDate {
                    Text("Iniciado: \(formatDate(startDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // Función para formatear la fecha
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// 4. Modificamos AddBookView para permitir seleccionar imágenes
struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss // Para cerrar el modal
    @Binding var books: [Book] // Referencia a la lista de libros
    
    @State private var title = ""
    @State private var author = ""
    @State private var totalPages = ""
    @State private var selectedImage: UIImage? // Para almacenar la imagen seleccionada
    @State private var showingImagePicker = false // Para mostrar el selector de imágenes
    @State private var imageSource: ImageSource = .photoLibrary // Fuente de la imagen
    @State private var showingImageSourceDialog = false // Para mostrar el diálogo de selección
    @State private var startDate = Date() // Fecha de inicio de lectura
    @State private var hasStartedReading = false // Si ya ha comenzado a leer
    
    enum ImageSource {
        case photoLibrary, camera
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del libro")) {
                    TextField("Título", text: $title)
                    TextField("Autor", text: $author)
                    TextField("Número de páginas", text: $totalPages)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Portada del libro")) {
                    Button(action: {
                        showingImageSourceDialog = true
                    }) {
                        HStack {
                            Text("Seleccionar imagen")
                            Spacer()
                            if selectedImage != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    if let image = selectedImage {
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Fecha de lectura")) {
                    Toggle("He comenzado a leer este libro", isOn: $hasStartedReading)
                    
                    if hasStartedReading {
                        DatePicker(
                            "Fecha de inicio",
                            selection: $startDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(DefaultDatePickerStyle())
                    }
                }
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
                            coverImage: selectedImage, // Usamos la imagen seleccionada
                            currentPage: 0,
                            totalPages: pages,
                            startDate: hasStartedReading ? startDate : nil // Usamos la fecha seleccionada o nil
                        )
                        books.append(newBook)
                        dismiss() // Cerramos el modal
                    }
                }
                .disabled(title.isEmpty || author.isEmpty || totalPages.isEmpty)
            )
            .confirmationDialog("Seleccionar fuente de imagen", isPresented: $showingImageSourceDialog) {
                Button("Cámara") {
                    imageSource = .camera
                    showingImagePicker = true
                }
                Button("Galería") {
                    imageSource = .photoLibrary
                    showingImagePicker = true
                }
                Button("Cancelar", role: .cancel) { }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, source: imageSource)
            }
        }
    }
}

// 5. Implementamos un componente ImagePicker para seleccionar imágenes
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var source: AddBookView.ImageSource
    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = source == .camera ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
