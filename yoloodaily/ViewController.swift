//
//  ViewController.swift
//  yoloodaily
//
//  Created by Maulana Ahmad Zahiri on 14/02/25.
//
//
//  Modified with enhanced UI, functionality, and efficiency
//
//  ContentView.swift
import SwiftUI

// MARK: - Data Model
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - Data Manager
class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
    
    init() {
        loadTasks()
    }
    
    func addTask(title: String) {
        let newTask = Task(title: title)
        tasks.append(newTask)
        saveTasks()
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
    }
}

// MARK: - Main View
struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Input Field
                HStack {
                    TextField("Add new task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(8)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding()
                
                // Task List
                List {
                    ForEach(taskStore.tasks) { task in
                        TaskRowView(task: task)
                            .onTapGesture {
                                taskStore.toggleTaskCompletion(task: task)
                            }
                    }
                    .onDelete(perform: taskStore.deleteTask)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("YolooDaily")
        }
    }
    
    private func addTask() {
        taskStore.addTask(title: newTaskTitle)
        newTaskTitle = ""
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .gray)
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .primary)
            Spacer()
        }
        .font(.system(size: 17))
        .padding(.vertical, 8)
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskStore())
    }
}

// MARK: - App Entry
@main
struct YolooDailyApp: App {
    @StateObject var taskStore = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskStore)
        }
    }
}
