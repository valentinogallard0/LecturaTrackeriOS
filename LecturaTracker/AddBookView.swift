//
//  AddBookView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
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
                            startDate: hasStartedReading ? startDate : nil, // Usamos la fecha seleccionada o nil
                            finishDate: nil,
                            readingHistory: [],
                            genre: selectedGenre, // Incluimos el género seleccionado
                            dateAdded: Date() // Fecha actual como fecha de adición
                        )
                        bookStore.addBook(newBook)
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
        .accentColor(themeManager.currentTheme.primaryColor)
    }
}
