//
//  UpdateProgressView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI

// Vista para actualizar el progreso
struct UpdateProgressView: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @Binding var hasFinished: Bool
    let onUpdate: () -> Void
    
    @State private var pageInput: String = ""
    @Environment(\.dismiss) private var dismiss
    
    init(currentPage: Binding<Int>, totalPages: Int, hasFinished: Binding<Bool>, onUpdate: @escaping () -> Void) {
        self._currentPage = currentPage
        self.totalPages = totalPages
        self._hasFinished = hasFinished
        self.onUpdate = onUpdate
        self._pageInput = State(initialValue: "\(currentPage.wrappedValue)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Actualizar progreso")) {
                    HStack {
                        Text("Página actual:")
                        Spacer()
                        TextField("Página", text: $pageInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    Text("Total de páginas: \(totalPages)")
                    
                    Toggle("He terminado el libro", isOn: $hasFinished)
                }
            }
            .navigationTitle("Actualizar progreso")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    dismiss()
                },
                trailing: Button("Guardar") {
                    if let page = Int(pageInput), page >= 0, page <= totalPages {
                        currentPage = page
                        
                        // Si marca como terminado, aseguramos que esté en la última página
                        if hasFinished {
                            currentPage = totalPages
                        }
                        
                        onUpdate()
                        dismiss()
                    }
                }
            )
        }
    }
}
