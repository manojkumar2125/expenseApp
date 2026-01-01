//
//  EditExpenseView.swift
//  myBudjet
//
//  Created by Tejaswi Yalla on 2025-10-24.
//


import SwiftUI
internal import CoreData

struct EditExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var expense: ExpenseEntity

    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: String
    @State private var note: String = ""
    @State private var selectedDate: Date

    let categories = ["Food", "Bills", "Shopping", "Entertainment", "Other","Needs","Household","Groceries"]

    init(expense: ExpenseEntity) {
        self.expense = expense
        _title = State(initialValue: expense.title ?? "")
        _amount = State(initialValue: "\(expense.amount)")
        _selectedCategory = State(initialValue: expense.category ?? "Other")
        _selectedDate = State(initialValue: expense.date ?? Date())
        _note = State(initialValue: expense.note ?? "")
    }

    var body: some View {
        VStack {
            Form {
                TextField("Expense Title", text: $title)
                    .foregroundColor(Color(UIColor.label))
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .foregroundColor(Color(UIColor.label))

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                

                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                TextField("Add Note", text: $note)
                    .foregroundColor(Color(UIColor.label))
            }
            .scrollContentBackground(.hidden)
            .background(Color(UIColor.systemBackground))

            VStack(spacing: 15) {
                Button("Update") {
                    if let amt = Double(amount), !title.isEmpty {
                        expense.title = title
                        expense.amount = amt
                        expense.category = selectedCategory
                        expense.date = selectedDate
                        expense.note = note

                        do {
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error updating expense: \(error)")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(Color(UIColor.systemBackground))
                .cornerRadius(10)

                Button("Delete Expense") {
                    viewContext.delete(expense)
                    do {
                        try viewContext.save()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Error deleting expense: \(error)")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(Color(UIColor.systemBackground))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Edit Expense")
    }
}
