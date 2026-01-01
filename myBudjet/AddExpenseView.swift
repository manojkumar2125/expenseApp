//
//  AddExpenseView.swift
//  myBudjet
//
//  Created by Tejaswi Yalla on 2025-10-24.
//


import SwiftUI
internal import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = "Food"
    @State private var otherCategory: String = ""
    @State private var addNote :String = ""
    @State private var selectedDate = Date()

    let categories = ["Food", "Bills", "Shopping", "Entertainment", "Other","Needs","Household","Groceries"]

    var body: some View {
        NavigationView {
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
                    TextField("Add Note", text: $addNote)
                        .foregroundColor(Color(UIColor.label))
                }
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemBackground))

                VStack(spacing: 15) {
                    Button("Save") {
                        if let amt = Double(amount), !title.isEmpty {
                            let newExpense = ExpenseEntity(context: viewContext)
                            newExpense.id = UUID()
                            newExpense.title = title
                            newExpense.amount = amt
                            newExpense.category = selectedCategory
                            newExpense.date = selectedDate
                            newExpense.note = addNote

                            do {
                                try viewContext.save()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Error saving expense: \(error)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .cornerRadius(10)

                    Button("Back to Main Page") {
                        presentationMode.wrappedValue.dismiss()
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
            .navigationTitle("Add Expense")
        }
    }
}
