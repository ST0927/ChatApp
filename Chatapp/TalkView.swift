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
    @State var isButtonDisabled: Bool = false
    @State var bot: Bool = false
    @State var start:Bool = false
    @State var delivery:Bool = false

    
    var body: some View {
        ZStack {
            Color(red:1.0,green:0.98,blue:0.94)
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
                                })
                                {
                                    Text("はい")
                                        .frame(width: 200)
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                }.disabled(isButtonDisabled)
                            }
                            Spacer()
                        }.padding(.top, 10)
                    } else {
                        ForEach(history.indices, id: \.self) { index in
                            let Num = index+1 //indexがIntじゃないから数字を足す
                            HStack {
                                Spacer()
                                Text(" \(history[index].text)")
                                    .font(.system(size: 14))
                                    .padding(10)
                                    .background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                                    .cornerRadius(10)
                            }.padding(.horizontal)
                            
                            HStack(alignment: .top) {
                                AvatarView(imageName: "avatar")
                                    .padding(.trailing, 8)
                                VStack(spacing: 0) {
                                    Text("問 \(Num)： 魅力的だと思う画像を選んでください ")
                                        .frame(width: 280)
                                        .font(.system(size: 14))
                                        .padding(10)
                                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    HStack(spacing: 0) {
                                        if Num/2 <= (Q.ImageName.count/4) {
                                            Image(""/*Q.ImageName[Num*2 - 2]*/)
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                                .background(Color.white)
                                            Image(""/*Q.ImageName[Num*2 - 1]*/)
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                                                .background(Color.white)
                                        }
                                    }.disabled(isButtonDisabled)
                                }
                                Spacer()
                            }.padding(.horizontal)
                        }.padding(.vertical, 5)
                    }
                }.padding(.bottom, 55)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
            //ボタン入れるならここじゃない？
            VStack {
                Spacer()
                HStack(spacing:0) {
                    TextField("　メッセージ", text: $message)
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
            if start == true {
                Logger()
                    .environmentObject(TimerCount())
            }
        }
    }
}

struct Logger : View {
    @EnvironmentObject var timerController: TimerCount
    @State var tapNum:Int = 0
    @State var LeftChoice:Int = 0
    @State var RightChoice:Int = 0
    
//    @State var svrollOffset: CGFloat = 0
    var body: some View {
        //透明なビューを設置してタップ回数のカウント
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                tapNum += 1
                timerController.count = 0
                timerController.start(0.1)
            }
        //動作確認用
        HStack {
            VStack {
                Text("タップ回数：\(tapNum)")
                Text("タップ間隔：\(timerController.count)")
                Text("左を選んだ回数：\(LeftChoice)")
                Text("右を選んだ回数：\(RightChoice)")
            }
        }
        Choice(tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice)
    }
}

struct Choice : View {
    @EnvironmentObject var timerController: TimerCount
    @Binding var tapNum:Int
    @Binding var LeftChoice:Int
    @Binding var RightChoice:Int
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text": "左の画像"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
                    
                    tapNum += 1
                    timerController.count = 0
                    timerController.start(0.1)
                    
                    LeftChoice += 1
                    
                })
                {
                    Text("左の画像")
                        .frame(width: 50)
                        .padding(10)
                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                        .cornerRadius(10)
                }
                Button(action: {
                    tapNum += 1
                    timerController.count = 0
                    timerController.start(0.1)
                    
                    RightChoice += 1
                })
                {
                    Text("右の画像")
                        .frame(width: 50)
                        .padding(10)
                        .background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                        .cornerRadius(10)
                }
            }.padding(.bottom, 55)
        }.keyboardObserving()
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


