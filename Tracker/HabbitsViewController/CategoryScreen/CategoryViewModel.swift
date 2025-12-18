import UIKit

final class CategoryViewModel {
    
    private let trackerCategoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    
    var onCategoriesUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onCategoryEditing: ((String) ->Void)?
    
    private var selectedCategory: String?
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    func loadCategories() {
        print("🔄 ViewModel: Загрузка категорий...")
        
        do {
            let categoryTitles = try trackerCategoryStore.fetchAllCategories()
            print("✅ ViewModel: Получено категорий: \(categoryTitles.count)")
            
            categories = categoryTitles.map { TrackerCategory(title: $0, trackers: []) }
            onCategoriesUpdated?()
        } catch {
            print("❌ ViewModel: Ошибка загрузки категорий: \(error)")
            onErrorOccurred?("Не удалось загрузить категории")
        }
    }
    
    func createCategory(with title: String) {
        print("🔄 ViewModel: Создание категории '\(title)'...")
        
        do {
            try trackerCategoryStore.createCategory(with: title)
            loadCategories()
        } catch {
            print("❌ ViewModel: Ошибка создания категории: \(error)")
            onErrorOccurred?("Не удалось создать категорию")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index >= 0 && index < categories.count else { return }
        
        let categoryTitle = categories[index].title
        selectedCategory = categoryTitle
        onCategorySelected?(categoryTitle)
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        guard index >= 0 && index < categories.count else { return false }
        return categories[index].title == selectedCategory
    }
    
    func getCategoryTitle(at index: Int) -> String? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index].title
    }
    
    func getNumberOfCategories() -> Int {
        return categories.count
    }
    
    func setInitiallySelectedCategory(_ category: String?) {
        selectedCategory = category
    }
    
    var hasCategories: Bool {
        return !categories.isEmpty
    }
    
    func editCategory(at indexPath: IndexPath) {
        guard indexPath.row < categories.count else { return }
        let oldCategoryTitle = categories[indexPath.row].title
        onCategoryEditing?(oldCategoryTitle)
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        
        do {
            try trackerCategoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
            loadCategories()
        } catch {
            print("Error to update category \(error)")
        }
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let categoryToDelete = categories[indexPath.row].title
        do {
            try self.trackerCategoryStore.deleteCategory(categoryToDelete)
            loadCategories()
        } catch {
            print("Failed to delete category \(error)")
        }
        
    }
}
