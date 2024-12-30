import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var chatViewModel: ChatViewModel?
    var historyData: [[Message]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        loadHistoryData()
    }
    
    func updateHistory(with newChat: [Message]) {
        historyData.append(newChat)
        saveHistoryData() 
        tableView.reloadData()
    }
    
    private func saveHistoryData() {
        do {
            let encodedData = try JSONEncoder().encode(historyData)
            UserDefaults.standard.set(encodedData, forKey: "history")
        } catch {
            print("Failed to save history data: \(error.localizedDescription)")
        }
    }
    
    private func loadHistoryData() {
        guard let savedData = UserDefaults.standard.data(forKey: "history") else { return }
        do {
            historyData = try JSONDecoder().decode([[Message]].self, from: savedData)
        } catch {
            print("Failed to load history data: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let message = historyData[indexPath.row].first {
            cell.textLabel?.text = message.text
        } else {
            cell.textLabel?.text = "No Data"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let chatViewModel = chatViewModel {
            chatViewModel.messages = historyData[indexPath.row]
            // Update the ViewController's chat with the selected history
            if let viewController = navigationController?.viewControllers.first(where: { $0 is ViewController }) as? ViewController {
                viewController.updateChat(with: historyData[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            historyData.remove(at: indexPath.row)
            saveHistoryData()
            tableView.reloadData()
        }
    }
}
