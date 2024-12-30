import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var historyView: UIView!
    
    private let viewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.historyView.isHidden = true
        historyView.layer.borderWidth = 1
        historyView.layer.borderColor = UIColor.black.cgColor
        historyView.layer.cornerRadius = 10
        
        setupTableView()
        setupBindings()
        
        if let historyVC = children.compactMap({ $0 as? HistoryViewController }).first {
            historyVC.chatViewModel = self.viewModel 
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

    private func setupBindings() {
        viewModel.reloadTableView = { [weak self] in
            self?.tableView.reloadData()
            if let count = self?.viewModel.messages.count, count > 0 {
                self?.tableView.scrollToRow(at: IndexPath(row: count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func showHistory(_ sender: UIBarButtonItem) {
        if self.historyView.isHidden {
            self.historyView.isHidden = false
            self.historyView.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.historyView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.historyView.alpha = 0.0
            }) { _ in
                self.historyView.isHidden = true
            }
        }
    }

    @IBAction func createNewChat(_ sender: UIBarButtonItem) {
        viewModel.saveChatData()

        if let historyVC = children.compactMap({ $0 as? HistoryViewController }).first {
            historyVC.updateHistory(with: viewModel.messages)
        }

        viewModel.clearData()
    }

    func updateChat(with chat:[Message]){
        viewModel.messages = chat
        tableView.reloadData()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        viewModel.addMessage(text, isUser: true)
        messageTextField.text = ""
        viewModel.fetchResponse(for: text)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let message = viewModel.messages[indexPath.row]

        cell.textLabel?.text = message.text
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = message.isUser ? .right : .left
        cell.textLabel?.textColor = .black
        cell.textLabel?.layer.cornerRadius = 10
        cell.textLabel?.clipsToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
