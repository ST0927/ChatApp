//
//  HomeView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/09/30.
//

import SwiftUI
import FirebaseFirestore //toDo
import KeyboardObserving

struct HomeView: View {
//    @ObservedObject private var viewModel = HomeViewModel()
    @State var message = "" //todo
    @State var history: [Message] = [] //todo
    
    var body: some View {
        VStack {
            List {
                ForEach(history, id: \.id) { m in
                    Text(m.text)
                }
//                Text("メッセージ")
//                Text("メッセージ")
//                Text("メッセージ")
//                Text("メッセージ")
//                Text("メッセージ")
            }
            HStack {
                TextField("メッセージ", text: $message).padding()
//                Button(action: viewModel.sendMessage) {
//                    Image(systemName: "paperplane.fill").padding()
//                }
                Button(action: {
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text":self.message]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
                    self.message = ""
                }) {
                    Image(systemName:"paperpane.fill").padding()
                }
            }
        }.keyboardObserving().onAppear  {
            let db = Firestore.firestore()
            db.collection("messages").addSnapshotListener {
                (snapshot, err) in
                if err != nil {
                    print("error")
                } else {
                    snapshot?.documentChanges.forEach({(diff) in
                        if diff.type == .added {
                            let m = Message(data: diff.document.data())
                            self.history.append(m)
                        }
                    })
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

//struct Message : Identifiable {
//    var id = UUID()
//    var text: String
//    
//    init(data: [String: Any]) {
//        self.text = data["text"] as! String
//    }
//}
