//
//  EditBookView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 22/05/25.
//

import SwiftUI

struct EditBookView: View {
    @Environment(\.dismiss) private var dismiss
    var bookStore: BookStore
    @State private var book: Book
    @EnvironmentObject var themeManager: ThemeManager
    
    // Estados del formulario
    @State private var title: String
    @State private var author: String
    @State private var totalPages: String
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSource: AddBookView.ImageSource = .photoLibrary
    @State private var showingImageSourceDialog = false
    @State private var startDate: Date
    @State private var hasStartedReading: Bool
    @State private var selectedGenre: BookGenre
    @State private var currentPage: String
    
    // Estados para validación y errores
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var titleError: String?
    @State private var authorError: String?
    @State private var pagesError: String?
    @State private var currentPageError: String?
    @State private var showingDeleteConfirmation = false
    

    
    // MARK: - Initializer
    init(bookStore: BookStore, book: Book) {
        self.bookStore = bookStore
        self._book = State(initialValue: book)
        
        // Inicializar estados del formulario
        self._title = State(initialValue: book.title)
        self._author = State(initialValue: book.author)
        self._totalPages = State(initialValue: "\(book.totalPages)")
        self._selectedImage = State(initialValue: book.coverImage)
        self._startDate = State(initialValue: book.startDate ?? Date())
        self._hasStartedReading = State(initialValue: book.startDate != nil)
        self._selectedGenre = State(initialValue: book.genre)
        self._currentPage = State(initialValue: "\(book.currentPage)")
    }
    
    // MARK: - Computed Properties para Validación
    
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var trimmedAuthor: String {
        author.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isFormValid: Bool {
        return isTitleValid && isAuthorValid && isPagesValid && isCurrentPageValid
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
    
    private var isCurrentPageValid: Bool {
        guard let current = Int(currentPage), let total = Int(totalPages) else { return false }
        return current >= 0 && current <= total
    }
    
    private var hasChanges: Bool {
        let titleChanged = trimmedTitle != book.title
        let authorChanged = trimmedAuthor != book.author
        let pagesChanged = totalPages != "\(book.totalPages)"
        let imageChanged = selectedImage != book.coverImage
        let genreChanged = selectedGenre != book.genre
        let currentPageChanged = currentPage != "\(book.currentPage)"
        let startDateToggleChanged = hasStartedReading != (book.startDate != nil)
        let startDateValueChanged = hasStartedReading && startDate != (book.startDate ?? Date())
        
        if titleChanged { return true }
        if authorChanged { return true }
        if pagesChanged { return true }
        if imageChanged { return true }
        if genreChanged { return true }
        if currentPageChanged { return true }
        if startDateToggleChanged { return true }
        if startDateValueChanged { return true }
        
        return false
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
                // Validar página actual cuando cambian las páginas totales
                validateCurrentPage()
            }
        }
    }
    
    private func validateCurrentPage() {
        if currentPage.isEmpty {
            currentPageError = "La página actual es obligatoria"
        } else if Int(currentPage) == nil {
            currentPageError = "Debe ser un número válido"
        } else if let current = Int(currentPage), let total = Int(totalPages) {
            if current < 0 {
                currentPageError = "La página actual no puede ser negativa"
            } else if current > total {
                currentPageError = "La página actual no puede ser mayor al total"
            } else {
                currentPageError = nil
            }
        }
    }
    
    private func validateForm() -> String? {
        validateTitle()
        validateAuthor()
        validatePages()
        validateCurrentPage()
        
        if let titleError = titleError { return titleError }
        if let authorError = authorError { return authorError }
        if let pagesError = pagesError { return pagesError }
        if let currentPageError = currentPageError { return currentPageError }
        
        // Validación de fecha
        if hasStartedReading && startDate > Date() {
            return "La fecha de inicio no puede ser en el futuro"
        }
        
        return nil
    }
    
    var body: some View {
        NavigationView {
            formContent
        }
        .accentColor(themeManager.currentTheme.primaryColor)
    }
    
    // MARK: - Form Content
    private var formContent: some View {
        Form {
            basicInfoSection
            progressSection
            coverImageSection
            startDateSection
            warningSection
            dangerZoneSection
        }
        .navigationTitle("Editar libro")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: cancelButton,
            trailing: saveButton
        )
        .confirmationDialog("Seleccionar fuente de imagen", isPresented: $showingImageSourceDialog) {
            imageSourceButtons
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
        .alert("¿Eliminar libro?", isPresented: $showingDeleteConfirmation) {
            Button("Eliminar", role: .destructive) {
                deleteBook()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Esta acción eliminará permanentemente \"\(book.title)\" y todo su historial de lectura. No se puede deshacer.")
        }
    }
    
    // MARK: - Form Sections
    private var basicInfoSection: some View {
        Section(header: Text("Información básica")) {
            titleField
            authorField
            genrePicker
        }
    }
    
    private var progressSection: some View {
        Section(header: Text("Progreso de lectura")) {
            totalPagesField
            currentPageField
            progressView
        }
    }
    
    private var coverImageSection: some View {
        Section(header: Text("Portada del libro")) {
            changeImageButton
            imagePreview
            removeImageButton
        }
    }
    
    private var startDateSection: some View {
        Section(header: Text("Fecha de inicio")) {
            Toggle("He comenzado a leer este libro", isOn: $hasStartedReading)
            
            if hasStartedReading {
                DatePicker(
                    "Fecha de inicio",
                    selection: $startDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(DefaultDatePickerStyle())
            }
        }
    }
    
    private var warningSection: some View {
        Section(footer: Text("⚠️ Cambiar el número total de páginas puede afectar tu progreso y estadísticas.")) {
            EmptyView()
        }
    }
    
    private var dangerZoneSection: some View {
        Section(header: Text("Zona peligrosa").foregroundColor(.red)) {
            Button("Eliminar libro") {
                showingDeleteConfirmation = true
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Individual Components
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Título", text: $title)
                .onChange(of: title) { _ in validateTitle() }
            
            if let titleError = titleError {
                Text(titleError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var authorField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Autor", text: $author)
                .onChange(of: author) { _ in validateAuthor() }
            
            if let authorError = authorError {
                Text(authorError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var genrePicker: some View {
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
    
    private var totalPagesField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Número total de páginas", text: $totalPages)
                .keyboardType(.numberPad)
                .onChange(of: totalPages) { _ in validatePages() }
            
            if let pagesError = pagesError {
                Text(pagesError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var currentPageField: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Página actual", text: $currentPage)
                .keyboardType(.numberPad)
                .onChange(of: currentPage) { _ in validateCurrentPage() }
            
            if let currentPageError = currentPageError {
                Text(currentPageError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private var progressView: some View {
        if let current = Int(currentPage), let total = Int(totalPages), total > 0 {
            let progress = Double(current) / Double(total)
            HStack {
                Text("Progreso:")
                Spacer()
                Text("\(Int(progress * 100))%")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeManager.currentTheme.primaryColor))
        }
    }
    
    private var changeImageButton: some View {
        Button(action: {
            showingImageSourceDialog = true
        }) {
            HStack {
                Text("Cambiar imagen")
                Spacer()
                if selectedImage != nil {
                    Image(systemName: "photo")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
    
    @ViewBuilder
    private var imagePreview: some View {
        if let image = selectedImage {
            HStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(8)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var removeImageButton: some View {
        if selectedImage != nil {
            Button("Eliminar imagen") {
                withAnimation(.easeInOut) {
                    selectedImage = nil
                }
            }
            .foregroundColor(.red)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancelar") {
            if hasChanges {
                // Aquí podrías mostrar una confirmación de cancelar cambios
            }
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Guardar") {
            saveChanges()
        }
        .disabled(!isFormValid || !hasChanges)
        .opacity(isFormValid && hasChanges ? 1.0 : 0.6)
    }
    
    @ViewBuilder
    private var imageSourceButtons: some View {
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
    
    // MARK: - Save Changes Method
    
    private func saveChanges() {
        // Validar formulario
        if let validationError = validateForm() {
            errorMessage = validationError
            showingError = true
            return
        }
        
        guard let pages = Int(totalPages), let current = Int(currentPage) else {
            errorMessage = "Error al procesar los números de página"
            showingError = true
            return
        }
        
        // Crear libro actualizado
        var updatedBook = book
        updatedBook.title = trimmedTitle
        updatedBook.author = trimmedAuthor
        updatedBook.totalPages = pages
        updatedBook.currentPage = current
        updatedBook.coverImageData = selectedImage?.jpegData(compressionQuality: 0.7)
        updatedBook.genre = selectedGenre
        updatedBook.startDate = hasStartedReading ? startDate : nil
        
        // Si el libro se completó (página actual = páginas totales) y no tenía fecha de finalización
        if current == pages && book.finishDate == nil {
            updatedBook.finishDate = Date()
        }
        // Si ya no está completo, quitar fecha de finalización
        else if current < pages && book.finishDate != nil {
            updatedBook.finishDate = nil
        }
        
        // Actualizar en el store
        bookStore.updateBook(updatedBook)
        
        // Feedback háptico de éxito
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
    
    // MARK: - Delete Book Method
    
    private func deleteBook() {
        // Encontrar el índice del libro en el array
        if let index = bookStore.books.firstIndex(where: { $0.id == book.id }) {
            bookStore.deleteBook(at: IndexSet(integer: index))
            
            // Feedback háptico
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            dismiss()
        }
    }
}
