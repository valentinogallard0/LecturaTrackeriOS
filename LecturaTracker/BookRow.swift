//
//  BookRow.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

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
