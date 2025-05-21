//
//  ReadingCalendarView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// Vista del calendario para registrar la lectura diaria
struct ReadingCalendarView: View {
    var book: Book
    var onEntrySelected: (Date) -> Void
    var onUpdate: (Book) -> Void
    
    @State private var calendarOffset = 0
    @State private var selectedDate = Date()
    @State private var showingEntrySheet = false
    @State private var pagesReadToday = ""
    
    // Obtener los días a mostrar en el calendario (5 días)
    private var daysToShow: [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        return (-2 + calendarOffset...2 + calendarOffset).map { offset in
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Registro de lectura diaria")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Botones de navegación del calendario
            HStack {
                Button(action: {
                    calendarOffset -= 5
                }) {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                if calendarOffset != 0 {
                    Button(action: {
                        calendarOffset = 0
                    }) {
                        Text("Hoy")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    calendarOffset += 5
                }) {
                    Image(systemName: "chevron.right")
                        .padding(10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Calendario visual (5 días)
            HStack(spacing: 12) {
                ForEach(daysToShow, id: \.self) { date in
                    VStack {
                        // Nombre del día (Lu, Ma, etc)
                        Text(dayName(from: date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Botón de día
                        Button(action: {
                            selectedDate = date
                            onEntrySelected(date)
                            
                            // Si es hoy y no hay entrada, permitir agregarla
                            if Calendar.current.isDateInToday(date) && book.getReadingEntry(for: date) == nil {
                                showingEntrySheet = true
                            }
                        }) {
                            VStack {
                                // Número del día
                                Text(dayNumber(from: date))
                                    .font(.headline)
                                
                                // Si hay una entrada para este día, mostramos un indicador
                                if let entry = book.getReadingEntry(for: date) {
                                    Text("\(entry.pagesRead)p")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .background(Color.blue)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(width: 45, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected(date) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected(date) ? Color.blue : Color.clear, lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Añadir lectura para hoy
            if Calendar.current.isDateInToday(selectedDate) && book.getReadingEntry(for: selectedDate) == nil {
                Button(action: {
                    showingEntrySheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Registrar lectura de hoy")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
        .sheet(isPresented: $showingEntrySheet) {
            AddReadingEntryView(book: book, date: selectedDate, onSave: onUpdate)
        }
    }
    
    // Verificar si una fecha está seleccionada
    private func isSelected(_ date: Date) -> Bool {
        return Calendar.current.isDate(selectedDate, inSameDayAs: date)
    }
    
    // Obtener el nombre abreviado del día (Lun, Mar, etc)
    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // Obtener el número del día
    private func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
