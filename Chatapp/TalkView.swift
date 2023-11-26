//
//  TalkView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/25.
//

import SwiftUI
import FirebaseFirestore
import KeyboardObserving

struct Talk: View {
    @State var message = ""
    @State var history: [Message] = []
    @State var button =  ""
    @State var answer: [Answer] = []
    @EnvironmentObject var Q: QuestionList
    @State private var isButtonDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                //ForEachでanswer配列追加できそう
                ForEach(history.indices, id: \.self) { index in
                    let Num = index+1 //indexがIntじゃないから数字を足す
                    HStack {
                        //ユーザー
                        if isButtonDisabled == true {
                            Spacer()
                            Text("\(Num): \(answer[index].text)")
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                                .cornerRadius(10)
                        }
                        if Num % 2 == 1 {
                            Spacer()
                            Text("\(Num): \(history[index].text)")
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                                .cornerRadius(10)
                        } else {
                            //チャットボット
                            AvatarView(imageName: "avatar")
                                .padding(.trailing, 8)
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    if Num/2 <= (Q.ImageName.count/2) {
                                        Image(Q.ImageName[Num - 2])
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                        Image(Q.ImageName[Num - 1])
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                    }
                                }
                                Text(" A or B ")
                                    .frame(width: 100)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                Button(action: {
                                    isButtonDisabled = true
                                    self.button = "A"
                                    if Num % 2 == 0 {
                                        let db = Firestore.firestore()
                                        db.collection("answers").addDocument(data: ["Q": self.button]) { err in
                                            if let e = err {
                                                print(e)
                                            } else {
                                                print("sent")
                                            }
                                        }
                                        self.button = ""
                                    }
                                    isButtonDisabled = false
                                })
                                {
                                    Text("A")
                                        .frame(width: 100)
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                }.disabled(isButtonDisabled)
                                Button(action: {

                                }){
                                    Text("B")
                                        .frame(width: 100)
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                }
                            }
                            Spacer()
                        }
                    }.padding(.horizontal)
                }.padding(.vertical, 5)
            }
            HStack {
                TextField("メッセージ", text: $message).padding()
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
                    Image(systemName:"paperplane.fill").padding()
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
            db.collection("answers").addSnapshotListener {
                (snapshot, err) in
                if err != nil {
                    print("error")
                } else {
                    snapshot?.documentChanges.forEach({(diff) in
                        if diff.type == .added {
                            let a = Answer(data: diff.document.data())
                            self.answer.append(a)                        }
                    })
                }
            }
        }
    }
}

struct Message : Identifiable {
    var id = UUID()
    var text: String
    
    init(data: [String: Any]) {
        self.text = data["text"] as! String
    }
}

struct Answer : Identifiable {
    var id = UUID()
    var text: String
    
    init(data: [String: Any]) {
        self.text = data["Q"] as! String
    }
}

#Preview {
    Talk()
        .environmentObject(QuestionList())
}
