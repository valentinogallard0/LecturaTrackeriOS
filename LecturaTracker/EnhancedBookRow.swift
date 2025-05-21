//
//  EnhancedBookRow.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

struct EnhancedBookRow: View {
    // MARK: - Properties
    let book: Book
    let theme: AppTheme
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 15) {
            // Enhanced Cover Image
            coverImageView
            
            // Book Information
            bookInfoView
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(cardBackground)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    // MARK: - Cover Image View
    private var coverImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: theme.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.3)
                .frame(width: 60, height: 90)
            
            if let coverImage = book.coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 90)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Text(String(book.title.prefix(1)))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primaryColor)
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
    
    // MARK: - Book Info View
    private var bookInfoView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            Text(book.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Author
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            // Progress Bar
            ThemedProgressView(
                progress: book.readingProgress,
                theme: theme,
                height: 6
            )
            .padding(.top, 4)
            
            // Progress Info
            HStack {
                Text("\(book.currentPage) de \(book.totalPages) páginas")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(book.readingProgress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.primaryColor)
            }
            
            // Start Date (if available)
            if let startDate = book.startDate {
                Text("Iniciado: \(formatDate(startDate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview Provider
struct EnhancedBookRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EnhancedBookRow(
                book: Book(
                    title: "El nombre del viento",
                    author: "Patrick Rothfuss",
                    coverImage: nil,
                    currentPage: 250,
                    totalPages: 662,
                    startDate: Date()
                ),
                theme: .blue
            )
            
            EnhancedBookRow(
                book: Book(
                    title: "Cien años de soledad",
                    author: "Gabriel García Márquez",
                    coverImage: nil,
                    currentPage: 150,
                    totalPages: 471
                ),
                theme: .green
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
