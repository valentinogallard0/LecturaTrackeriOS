//
//  StatisticsView.swift
//  LecturaTracker
//
//  Created by Valentino De Paola Gallardo on 21/05/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    // MARK: - Properties
    @ObservedObject var bookStore: BookStore
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var statistics: ReadingStatistics?
    
    enum TimeFrame: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    if let stats = statistics {
                        // MARK: - Overview Cards
                        overviewSection(stats: stats)
                        
                        // MARK: - Reading Streak
                        readingStreakSection(stats: stats)
                        
                        // MARK: - Time Frame Picker
                        timeFramePicker
                        
                        // MARK: - Charts Section
                        chartsSection(stats: stats)
                        
                        // MARK: - Time Estimates
                        timeEstimatesSection(stats: stats)
                        
                        // MARK: - Daily Progress (Last 7 days)
                        recentProgressSection(stats: stats)
                        
                    } else {
                        // Loading or no data state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Comienza a leer para ver tus estadísticas")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
            .onAppear {
                calculateStatistics()
            }
            .onChange(of: bookStore.books) { _ in
                calculateStatistics()
            }
        }
    }
    
    // MARK: - Overview Section
    private func overviewSection(stats: ReadingStatistics) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: "Libros leídos",
                value: "\(stats.totalBooksRead)",
                icon: "books.vertical",
                color: .blue
            )
            
            StatCard(
                title: "Páginas leídas",
                value: "\(stats.totalPagesRead)",
                icon: "doc.text",
                color: .green
            )
            
            StatCard(
                title: "Leyendo actualmente",
                value: "\(stats.currentlyReading)",
                icon: "book.open",
                color: .orange
            )
            
            StatCard(
                title: "Promedio por día",
                value: String(format: "%.1f", stats.averagePagesPerDay),
                icon: "calendar",
                color: .purple
            )
        }
    }
    
    // MARK: - Reading Streak Section
    private func readingStreakSection(stats: ReadingStatistics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Racha de lectura")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(stats.readingStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("días consecutivos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Time Frame Picker
    private var timeFramePicker: some View {
        Picker("Período", selection: $selectedTimeFrame) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Text(timeFrame.rawValue).tag(timeFrame)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: - Charts Section
    private func chartsSection(stats: ReadingStatistics) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Progreso de lectura")
                .font(.headline)
            
            if selectedTimeFrame == .week {
                weeklyChart(data: stats.weeklyProgress)
            } else if selectedTimeFrame == .month {
                monthlyChart(data: stats.monthlyProgress)
            }
        }
    }
    
    // MARK: - Weekly Chart
    private func weeklyChart(data: [WeeklyData]) -> some View {
        VStack(alignment: .leading) {
            Text("Páginas por semana")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if #available(iOS 16.0, *) {
                Chart(data) { week in
                    BarMark(
                        x: .value("Semana", week.weekLabel),
                        y: .value("Páginas", week.pagesRead)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Fallback para versiones anteriores
                SimpleBarChart(data: data.map { ($0.weekLabel, Double($0.pagesRead)) })
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Monthly Chart
    private func monthlyChart(data: [MonthlyData]) -> some View {
        VStack(alignment: .leading) {
            Text("Páginas por mes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if #available(iOS 16.0, *) {
                Chart(data) { month in
                    LineMark(
                        x: .value("Mes", month.monthLabel),
                        y: .value("Páginas", month.pagesRead)
                    )
                    .foregroundStyle(.green)
                    .symbol(Circle())
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // Fallback para versiones anteriores
                SimpleLineChart(data: data.map { ($0.monthLabel, Double($0.pagesRead)) })
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Time Estimates Section
    private func timeEstimatesSection(stats: ReadingStatistics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tiempo estimado para terminar")
                .font(.headline)
            
            if stats.estimatedTimeToFinishCurrent.isEmpty {
                Text("No hay libros en progreso")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(stats.estimatedTimeToFinishCurrent) { estimate in
                    TimeEstimateRow(estimate: estimate)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Recent Progress Section
    private func recentProgressSection(stats: ReadingStatistics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Actividad reciente (últimos 7 días)")
                .font(.headline)
            
            let recentData = StatisticsService.getRecentReadingData(books: bookStore.books, days: 7)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(recentData) { day in
                    VStack(spacing: 4) {
                        Text(day.dayOfWeek)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(day.pagesRead > 0 ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(day.pagesRead)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(day.pagesRead > 0 ? .white : .secondary)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    private func calculateStatistics() {
        guard !bookStore.books.isEmpty else {
            statistics = nil
            return
        }
        
        statistics = StatisticsService.calculateStatistics(for: bookStore.books)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TimeEstimateRow: View {
    let estimate: BookTimeEstimate
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(estimate.book.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(estimate.pagesRemaining) páginas restantes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(estimate.estimatedDaysToFinish) días")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(estimate.estimatedFinishDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Fallback Charts for iOS < 16

struct SimpleBarChart: View {
    let data: [(String, Double)]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            let maxValue = data.map { $0.1 }.max() ?? 1
            
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                VStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 30, height: CGFloat(item.1 / maxValue) * 150)
                    
                    Text(item.0)
                        .font(.caption2)
                        .rotationEffect(.degrees(-45))
                }
            }
        }
    }
}

struct SimpleLineChart: View {
    let data: [(String, Double)]
    
    var body: some View {
        Text("Gráfico de líneas - Requiere iOS 16+")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(bookStore: BookStore())
    }
}
