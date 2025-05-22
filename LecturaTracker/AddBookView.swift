//
//  AddBookView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

//


import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss // Para cerrar el modal
    var bookStore: BookStore // Referencia al almacén de libros
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var author = ""
    @State private var totalPages = ""
    @State private var selectedImage: UIImage? // Para almacenar la imagen seleccionada
    @State private var showingImagePicker = false // Para mostrar el selector de imágenes
    @State private var imageSource: ImageSource = .photoLibrary // Fuente de la imagen
    @State private var showingImageSourceDialog = false // Para mostrar el diálogo de selección
    @State private var startDate = Date() // Fecha de inicio de lectura
    @State private var hasStartedReading = false // Si ya ha comenzado a leer
    @State private var selectedGenre: BookGenre = .other // Género seleccionado
    
    // Estados para validación y errores
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var titleError: String?
    @State private var authorError: String?
    @State private var pagesError: String?
    
    enum ImageSource {
        case photoLibrary, camera
    }
    
    // MARK: - Computed Properties para Validación
    
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var trimmedAuthor: String {
        author.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isFormValid: Bool {
        return isTitleValid && isAuthorValid && isPagesValid
    }
    
    private var isTitleValid: Bool {
        !trimmedTitle.isEmpty && trimmedTitle.count >= 2
    }
    
    private var isAuthorValid: Bool {
        !trimmedAuthor.isEmpty && trimmedAuthor.count >= 2
    }
    
    private var isPagesValid: Bool {
        guard let pages = Int(totalPages) else { return false }
        return pages > 0 && pages <= 10000
    }
    
    // MARK: - Validation Methods
    
    private func validateTitle() {
        if trimmedTitle.isEmpty {
            titleError = "El título es obligatorio"
        } else if trimmedTitle.count < 2 {
            titleError = "El título debe tener al menos 2 caracteres"
        } else if trimmedTitle.count > 200 {
            titleError = "El título es demasiado largo (máximo 200 caracteres)"
        } else {
            titleError = nil
        }
    }
    
    private func validateAuthor() {
        if trimmedAuthor.isEmpty {
            authorError = "El autor es obligatorio"
        } else if trimmedAuthor.count < 2 {
            authorError = "El nombre del autor debe tener al menos 2 caracteres"
        } else if trimmedAuthor.count > 100 {
            authorError = "El nombre del autor es demasiado largo (máximo 100 caracteres)"
        } else {
            authorError = nil
        }
    }
    
    private func validatePages() {
        if totalPages.isEmpty {
            pagesError = "El número de páginas es obligatorio"
        } else if Int(totalPages) == nil {
            pagesError = "Debe ser un número válido"
        } else if let pages = Int(totalPages) {
            if pages <= 0 {
                pagesError = "El número de páginas debe ser mayor a 0"
            } else if pages > 10000 {
                pagesError = "Número de páginas demasiado alto (máximo 10,000)"
            } else {
                pagesError = nil
            }
        }
    }
    
    private func validateForm() -> String? {
        validateTitle()
        validateAuthor()
        validatePages()
        
        if let titleError = titleError {
            return titleError
        }
        if let authorError = authorError {
            return authorError
        }
        if let pagesError = pagesError {
            return pagesError
        }
        
        // Validación de fecha
        if hasStartedReading && startDate > Date() {
            return "La fecha de inicio no puede ser en el futuro"
        }
        
        return nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del libro")) {
                    // Campo Título
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Título", text: $title)
                            .onChange(of: title) { _ in
                                validateTitle()
                            }
                        
                        if let titleError = titleError {
                            Text(titleError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Campo Autor
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Autor", text: $author)
                            .onChange(of: author) { _ in
                                validateAuthor()
                            }
                        
                        if let authorError = authorError {
                            Text(authorError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Campo Páginas
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Número de páginas", text: $totalPages)
                            .keyboardType(.numberPad)
                            .onChange(of: totalPages) { _ in
                                validatePages()
                            }
                        
                        if let pagesError = pagesError {
                            Text(pagesError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Genre Picker
                    Picker("Género", selection: $selectedGenre) {
                        ForEach(BookGenre.allCases, id: \.self) { genre in
                            HStack {
                                Image(systemName: genre.iconName)
                                Text(genre.displayName)
                            }
                            .tag(genre)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
                            in: ...Date(), // No permitir fechas futuras
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(DefaultDatePickerStyle())
                    }
                }
                
                // Genre Info Section
                if selectedGenre != .other {
                    Section(header: Text("Género seleccionado")) {
                        HStack {
                            Image(systemName: selectedGenre.iconName)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 25)
                            
                            Text(selectedGenre.displayName)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Sección de ayuda/información
                Section(footer: Text("Asegúrate de revisar toda la información antes de guardar. Los datos se pueden editar después.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Añadir nuevo libro")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    dismiss() // Cierra el modal sin guardar
                },
                trailing: Button("Guardar") {
                    saveBook()
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
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
            .alert("Error al guardar", isPresented: $showingError) {
                Button("OK") {
                    errorMessage = nil
                    showingError = false
                }
            } message: {
                Text(errorMessage ?? "Ha ocurrido un error desconocido")
            }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
    }
    
    // MARK: - Save Book Method
    
    private func saveBook() {
        // Validar formulario una vez más antes de guardar
        if let validationError = validateForm() {
            errorMessage = validationError
            showingError = true
            return
        }
        
        // Verificar si ya existe un libro con el mismo título y autor
        let bookExists = bookStore.books.contains { book in
            book.title.lowercased() == trimmedTitle.lowercased() &&
            book.author.lowercased() == trimmedAuthor.lowercased()
        }
        
        if bookExists {
            errorMessage = "Ya tienes un libro con este título y autor en tu biblioteca"
            showingError = true
            return
        }
        
        // Si todo está bien, crear el libro
        guard let pages = Int(totalPages) else {
            errorMessage = "Error al procesar el número de páginas"
            showingError = true
            return
        }
        
        let newBook = Book(
            title: trimmedTitle,
            author: trimmedAuthor,
            coverImage: selectedImage,
            currentPage: 0,
            totalPages: pages,
            startDate: hasStartedReading ? startDate : nil,
            finishDate: nil,
            readingHistory: [],
            genre: selectedGenre,
            dateAdded: Date()
        )
        
        // Guardar el libro
        bookStore.addBook(newBook)
        
        // Feedback háptico de éxito
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        dismiss() // Cerramos el modal
    }
}
