//
//  ReadingHistoryListView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// Componente para mostrar el historial de lectura
struct ReadingHistoryListView: View {
    var book: Book
    var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let selectedDate = selectedDate, let entry = book.getReadingEntry(for: selectedDate) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Lectura del \(entry.formattedDate)")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Páginas leídas:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(entry.pagesRead)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Página alcanzada:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(entry.currentPage)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else if let selectedDate = selectedDate {
                Text("No hay registros de lectura para el \(formatDate(selectedDate))")
                    .italic()
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            if !book.readingHistory.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Historial de lectura")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ForEach(book.readingHistory) { entry in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.formattedDate)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("\(entry.pagesRead) páginas leídas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("Página \(entry.currentPage)")
                                .font(.callout)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 8)
                        
                        if entry.id != book.readingHistory.last?.id {
                            Divider()
                        }
                    }
                }
            } else {
                Text("No hay registros de lectura todavía")
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
