import SwiftUI
internal import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: ExpenseEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: true)]
    ) var expenses: FetchedResults<ExpenseEntity>

    @State private var showingAddExpense = false
    @State private var expandedTitles: Set<String> = []
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    private let months = [
        (1, "January"), (2, "February"), (3, "March"), (4, "April"),
        (5, "May"), (6, "June"), (7, "July"), (8, "August"),
        (9, "September"), (10, "October"), (11, "November"), (12, "December")
    ]
    private let years = Array(2022...Calendar.current.component(.year, from: Date()))

    // Filter expenses for selected month/year
    var filteredExpenses: [ExpenseEntity] {
        let calendar = Calendar.current
        return expenses.filter {
            guard let date = $0.date else { return false }
            return calendar.component(.month, from: date) == selectedMonth &&
                   calendar.component(.year, from: date) == selectedYear
        }
    }

    // Group expenses by title
    var groupedByTitle: [String: [ExpenseEntity]] {
        Dictionary(grouping: filteredExpenses, by: { $0.category ?? "Unknown" })
    }

    // Total amount for the month
    var totalMonthlyAmount: Double {
        filteredExpenses.map { $0.amount }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Month-Year Picker
                HStack {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.0) { value, name in
                            Text(name).tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.top, 10)

                // Pie Chart by Title
                ZStack {
                    
                    Chart {
                        ForEach(groupedByTitle.map { ($0.key, $0.value.map { $0.amount }.reduce(0,+)) }, id: \.0) { title, total in
                            SectorMark(
                                angle: .value("Amount", total),
                                innerRadius: .ratio(0.5),
                                angularInset: 1
                            )
                            .foregroundStyle(by: .value("Title", title))
                        }
                    }
                    .frame(height: 300)

                    Text("$\(totalMonthlyAmount, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.label))
                }
                .padding()

                // Expense List grouped by title
                List {
                    ForEach(groupedByTitle.keys.sorted(), id: \.self) { title in
                        let total = groupedByTitle[title]?.map { $0.amount }.reduce(0, +) ?? 0

                        Section(header:
                           
                            HStack {
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.label))
                                Spacer()
                                Text("$\(total, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(Color.blue)

                                Image(systemName: expandedTitles.contains(title) ? "chevron.down" : "chevron.right")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            .contentShape(Rectangle()) // Important: makes entire HStack tappable
                            .onTapGesture {
                                withAnimation {
                                    if expandedTitles.contains(title) {
                                        expandedTitles.remove(title)
                                    } else {
                                        expandedTitles.insert(title)
                                    }
                                }
                            }
                        ) {
                            if expandedTitles.contains(title) {
                                ForEach(groupedByTitle[title] ?? []) { expense in
                                    NavigationLink(destination: EditExpenseView(expense: expense)) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(expense.title ?? "Other")
                                                    .foregroundColor(Color(UIColor.label))
                                                if let date = expense.date {
                                                    Text(date, style: .date)
                                                        .font(.caption2)
                                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                                }
                                            }
                                            Spacer()
                                            Text("$\(expense.amount, specifier: "%.2f")")
                                                .foregroundColor(Color(UIColor.label))
                                        }
                                        .padding(.vertical, 5)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteExpense(at: indexSet, forTitle: title)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemBackground))

                // Add Expense Button
                Button("Add Expense") {
                    showingAddExpense = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Expenses")
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
    }

    // Delete expenses for a specific title
    private func deleteExpense(at offsets: IndexSet, forTitle title: String) {
        withAnimation {
            if let expensesForTitle = groupedByTitle[title] {
                offsets.map { expensesForTitle[$0] }.forEach(viewContext.delete)
                do {
                    try viewContext.save()
                } catch {
                    print("Error deleting expense: \(error)")
                }
            }
        }
    }
}
