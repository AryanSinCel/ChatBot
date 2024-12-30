
import Foundation

class ChatViewModel {
    var messages: [Message] = []
    var chatData: [[Message]] = []
    
    var reloadTableView: (() -> Void)?

    func addMessage(_ text: String, isUser: Bool) {
        messages.append(Message(text: text, isUser: isUser))
        reloadTableView?()
    }
    
    func saveChatData(){
        chatData.append(messages)
    }
    
    func clearData(){
        print(chatData)
        messages.removeAll()
        reloadTableView?()
    }

    func fetchResponse(for query: String) {
//        let headers = [
//            "x-rapidapi-key": "800e15615amshe0277d164f315b7p133ea3jsn601a7fd1b919",
//            "x-rapidapi-host": "chatgpt-42.p.rapidapi.com",
//            "Content-Type": "application/json"
//        ]
        
        let headers = [
            "x-rapidapi-key": "8e7a5cbf1emshdb6f2ad7af248d1p13802ejsn20866a3167c6",
            "x-rapidapi-host": "chatgpt-42.p.rapidapi.com",
            "Content-Type": "application/json"
        ]
        

        let parameters = [
            "messages": [
                ["role": "user", "content": query]
            ],
            "web_access": false
        ] as [String: Any]

        guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else { return }

        var request = URLRequest(url: URL(string: "https://chatgpt-42.p.rapidapi.com/chatgpt")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard error == nil, let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let result = json["result"] as? String,
                  json["status"] as? Bool == true else {
                print("Error: Failed to fetch or parse response")
                return
            }

            DispatchQueue.main.async {
                self?.addMessage(result, isUser: false)
               
            }
        }.resume()
    }
}
