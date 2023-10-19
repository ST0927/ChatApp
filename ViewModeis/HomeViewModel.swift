//
//  HomeViewModel.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/10/13.
//

//import Foundation
//import Firebase
//
//class HomeViewModel : ObservableObject {
//    @Published var history = [Message]()
//    @Published var message = ""
//    
//    private let db: Firestore
//    
//    init() {
//        db = Firestore.firestore()
//        listen()
//    }
//    
//    private func listen() {
//        db.collection("message").addSnapshotListener {
//            (snapshot, err) in
//            if err != nil {
//                print("error")
//            } else {
//                snapshot?.documentChanges.forEach({(diff) in
//                    if diff.type == .added {
//                        let m = Message(data:diff.document.data())
//                        self.history.append(m)
//                    }
//                })
//            }
//        }
//    }
//    
//    func sendMessage() {
//        db.collection("messages").addDocument(data: ["text":self.message]) { err in
//            if let e = err {
//                print(e)
//            } else {
//                print("sent")
//            }
//        }
//        self.message = ""
//    }
//}
//
//struct Message : Identifiable {
//    var id = UUID()
//    var text: String
//    
//    init(data: [String: Any]) {
//        self.text = data["text"] as! String
//    }
//}


//コード整理したら会話ログ的なのが消えた、どっかでミスってるから最悪前に戻して考え直す
