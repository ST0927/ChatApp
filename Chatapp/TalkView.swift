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
    @EnvironmentObject var Q: QuestionList
    @State private var isButtonDisabled: Bool = false
    @State private var bot: Bool = false
    @State var start:Bool = false
    
    var body: some View {
        ZStack {
            Color(red:0.4549,green:0.5804,blue:0.7529,opacity:1.0)
                .ignoresSafeArea(edges: [.bottom])
            VStack(alignment: .leading) {
                ScrollView {
                    if start == false {
                        HStack(alignment: .top) {
                            AvatarView(imageName: "avatar")
                                .padding(.trailing, 8)
                            VStack(spacing: 0) {
                                Text("アンケートを始めますか？")
                                    .frame(width: 200)
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                Button(action: {
                                    start = true
                                    self.button = "アンケートを始める"
                                    let db = Firestore.firestore()
                                    db.collection("messages").addDocument(data: ["text": self.button]) { err in
                                        if let e = err {
                                            print(e)
                                        } else {
                                            print("sent")
                                        }
                                    }
                                })
                                {
                                    Text("はい")
                                        .frame(width: 200)
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                }.disabled(isButtonDisabled)
                            }
                            Spacer()
                        }
                    } else {
                        ForEach(history.indices, id: \.self) { index in
                            let Num = index+1 //indexがIntじゃないから数字を足す
                            
                            HStack {
                                Spacer()
                                Text("\(Num): \(history[index].text)")
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                                    .cornerRadius(10)
                            }.padding(.horizontal)
                            
                            HStack(alignment: .top) {
                                
                                AvatarView(imageName: "avatar")
                                    .padding(.trailing, 8)

                                VStack(spacing: 0) {
                                    
                                    Text(" A or B ")
                                        .frame(width: 280)
                                        .font(.system(size: 14))
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    HStack(spacing: 0) {
                                        if Num/2 <= (Q.ImageName.count/4) {
                                            Image(Q.ImageName[Num*2 - 2])
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                            Image(Q.ImageName[Num*2 - 1])
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                        }
                                    }
//                                    HStack(spacing: 0) {
//                                        Button(action: {
//                                            self.button = "A" //ボタンテキストの中身引っ張りたい
//                                            let db = Firestore.firestore()
//                                            db.collection("messages").addDocument(data: ["text": self.button]) { err in
//                                                if let e = err {
//                                                    print(e)
//                                                } else {
//                                                    print("sent")
//                                                }
//                                            }
//                                        })
//                                        {
//                                            Text("A")
//                                                .frame(width: 150)
//                                                .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                                        }.disabled(isButtonDisabled)
//                                        Button(action: {
//                                            self.button = "B"
//                                            let db = Firestore.firestore()
//                                            db.collection("messages").addDocument(data: ["text": self.button]) { err in
//                                                if let e = err {
//                                                    print(e)
//                                                } else {
//                                                    print("sent")
//                                                }
//                                            }
//                                        }){
//                                            Text("B")
//                                                .frame(width: 150)
//                                                .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
//                                        }
//                                    }
                                    .disabled(isButtonDisabled)
                                }
                                Spacer()
                            }.padding(.horizontal)
                            
                        }.padding(.vertical, 5)
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
            VStack {
                Spacer()
                HStack(spacing:0) {
                    TextField("メッセージ", text: $message)
                        .frame(height: 55)
                        .background(Color.white)
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
                        Image(systemName:"paperplane.fill")
                            .frame(width: 55,height: 55)
                            .background(Color.white)
                    }
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

#Preview {
    Talk()
        .environmentObject(QuestionList())
}


