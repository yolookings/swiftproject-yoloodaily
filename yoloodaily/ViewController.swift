//
//  ViewController.swift
//  yoloodaily
//
//  Created by Maulana Ahmad Zahiri on 14/02/25.
//
//
//  Modified with enhanced UI, functionality, and efficiency
//

import SwiftUI

// MARK: - Model
struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var createdAt: Date = Date()
}

// MARK: - View Model
class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [Task] = [] {
        didSet { saveTasks() }
    }
    
    init() {
        self.tasks = UserDefaults.standard.loadTasks() ?? []
    }
    
    // Filtered and sorted tasks
    var activeTasks: [Task] {
        tasks.filter { !$0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func addTask(title: String) {
        guard !title.isEmpty else { return }
        tasks.insert(Task(title: title, isCompleted: false), at: 0)
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            HapticFeedbackManager.selection()
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        HapticFeedbackManager.notification(.success)
    }
    
    private func saveTasks() {
        UserDefaults.standard.saveTasks(tasks)
    }
}

// MARK: - Views
struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var searchText = ""
    
    private var filteredTasks: [Task] {
        guard !searchText.isEmpty else { return viewModel.tasks }
        return viewModel.tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if filteredTasks.isEmpty {
                    EmptyStateView()
                        .transition(.opacity)
                } else {
                    TaskListView(
                        tasks: filteredTasks,
                        viewModel: viewModel,
                        searchText: searchText
                    )
                }
                
                InputTaskView(
                    newTaskTitle: $newTaskTitle,
                    onAdd: { viewModel.addTask(title: newTaskTitle) }
                )
            }
            .navigationTitle("YolooDaily")
            .animation(.easeInOut, value: filteredTasks)
        }
    }
}

struct TaskListView: View {
    let tasks: [Task]
    let viewModel: TaskViewModel
    let searchText: String
    
    var body: some View {
        List {
            if !searchText.isEmpty {
                SearchResultsSection(tasks: tasks, viewModel: viewModel)
            } else {
                ActiveTasksSection(tasks: viewModel.activeTasks, viewModel: viewModel)
                CompletedTasksSection(tasks: viewModel.completedTasks, viewModel: viewModel)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct TaskRowView: View {
    @Binding var task: Task
    var onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            if !task.isCompleted {
                Text(task.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    onToggle()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Components
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search tasks...", text: $text)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct InputTaskView: View {
    @Binding var newTaskTitle: String
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            TextField("New task...", text: $newTaskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onAdd)
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .disabled(newTaskTitle.isEmpty)
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tasks found")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Sections
struct SearchResultsSection: View {
    let tasks: [Task]
    let viewModel: TaskViewModel
    
    var body: some View {
        Section {
            ForEach(tasks) { task in
                TaskRowView(task: .constant(task)) {
                    viewModel.toggleTaskCompletion(task: task)
                }
            }
        } header: {
            Text("Search Results (\(tasks.count))")
        }
    }
}

struct ActiveTasksSection: View {
    let tasks: [Task]
    let viewModel: TaskViewModel
    
    var body: some View {
        Section {
            ForEach(tasks) { task in
                TaskRowView(task: .constant(task)) {
                    viewModel.toggleTaskCompletion(task: task)
                }
            }
            .onDelete { viewModel.deleteTask(at: $0) }
        } header: {
            Text("Active Tasks (\(tasks.count))")
        }
    }
}

struct CompletedTasksSection: View {
    let tasks: [Task]
    let viewModel: TaskViewModel
    
    var body: some View {
        Section {
            ForEach(tasks) { task in
                TaskRowView(task: .constant(task)) {
                    viewModel.toggleTaskCompletion(task: task)
                }
            }
            .onDelete { viewModel.deleteTask(at: $0) }
        } header: {
            Text("Completed Tasks (\(tasks.count))")
        }
    }
}

// MARK: - Helpers
struct HapticFeedbackManager {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

// MARK: - Persistence Extension
extension UserDefaults {
    private enum Keys {
        static let tasks = "tasks"
    }
    
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            set(encoded, forKey: Keys.tasks)
        }
    }
    
    func loadTasks() -> [Task]? {
        guard let data = data(forKey: Keys.tasks) else { return nil }
        return try? JSONDecoder().decode([Task].self, from: data)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
