//
//  ViewController.swift
//  yoloodaily
//
//  Created by Maulana Ahmad Zahiri on 14/02/25.
//

import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] {
        didSet {
            saveTasks()
        }
    }
    
    init() {
        self.tasks = UserDefaults.standard.loadTasks() ?? []
    }
    
    func addTask(title: String) {
        let newTask = Task(title: title, isCompleted: false)
        tasks.append(newTask)
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func removeTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    private func saveTasks() {
        UserDefaults.standard.saveTasks(tasks)
    }
}

extension UserDefaults {
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            set(encoded, forKey: "tasks")
        }
    }
    
    func loadTasks() -> [Task]? {
        if let savedData = data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
            return decodedTasks
        }
        return nil
    }
}

struct ContentView: View {
    @StateObject var taskViewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if !newTaskTitle.isEmpty {
                            taskViewModel.addTask(title: newTaskTitle)
                            newTaskTitle = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                }
                .padding()
                
                List {
                    ForEach(taskViewModel.tasks) { task in
                        HStack {
                            Text(task.title)
                                .strikethrough(task.isCompleted, color: .black)
                            Spacer()
                            Button(action: {
                                taskViewModel.toggleTaskCompletion(task: task)
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    }
                    .onDelete(perform: taskViewModel.removeTask)
                }
            }
            .navigationTitle("YolooDaily")
        }
    }
}

@main
struct YolooDailyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

