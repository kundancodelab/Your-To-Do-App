import RealmSwift
import Foundation
// MARK: - Updated DatabaseManager (Global Singleton)
class DatabaseManager {
    static let shared = DatabaseManager()
    private var realm: Realm?
    
    private init() {
        setupRealm()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
            print("Realm path: \(realm?.configuration.fileURL?.path ?? "")")
        } catch {
            print("Realm init error: \(error)")
        }
    }
    
    // MARK: - Generic CRUD Operations
    func create<T: Object>(_ object: T) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write { realm.add(object) }
            return true
        } catch { return false }
    }
    
    func read<T: Object>(_ objectType: T.Type) -> Results<T>? {
        return realm?.objects(objectType)
    }
    
    func update(_ block: () -> Void) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write(block)
            return true
        } catch { return false }
    }
    
    func delete<T: Object>(_ object: T) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write { realm.delete(object) }
            return true
        } catch { return false }
    }
    
    // MARK: - Task Specific Methods
    func getAllTasks() -> Results<TodoTask>? {
        return read(TodoTask.self)?.sorted(byKeyPath: "createdAt", ascending: false)
    }
}
