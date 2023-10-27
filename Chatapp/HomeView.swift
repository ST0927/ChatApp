//
//  HomeView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/09/30.
//

import SwiftUI
import OpenAIKit

// チャット表示用のメインビュー
struct Chat: View {

    // 現在のチャットが完了しているかどうかを示す変数
    @State private var isCompleting: Bool = false
    
    // ユーザーが入力するテキストを保存する変数
    @State private var text: String = ""
    
    // チャットメッセージの配列
    @State private var chat: [ChatMessage] = [
        ChatMessage(role: .system, content: "あなたは、ユーザーの質問や会話に回答するロボットです。"),
        ChatMessage(role: .system, content:"こんにちは。何かお困りのことがあればおっしゃってください。")
    ]
    
    // チャット画面のビューレイアウト
    var body: some View {
        VStack {
            // スクロール可能なメッセージリストの表示
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chat.indices, id: \.self) { index in
                        // 最初のメッセージ以外を表示
                        if index > 1 {
                            MessageView(message: chat[index])
                        }
                    }
                }
            }
            .padding(.top)
            // 画面をタップしたときにキーボードを閉じる
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            // テキスト入力フィールドと送信ボタンの表示
            HStack {
                // テキスト入力フィールド
                TextField("メッセージを入力", text: $text)
                    .disabled(isCompleting) // チャットが完了するまで入力を無効化
                    .font(.system(size: 15)) // フォントサイズを調整
                    .padding(8)
                    .padding(.horizontal, 10)
                    .background(Color.white) // 入力フィールドの背景色を白に設定
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)

                    )
                
                // 送信ボタン
                Button(action: {
                    isCompleting = true
                    // ユーザーのメッセージをチャットに追加
                    chat.append(ChatMessage(role: .user, content: text))
                    text = "" // テキストフィールドをクリア
                    
                    Task {
                        do {
                            // OpenAIの設定
                            let config = Configuration(
                                organizationId: "org-eWKJ3cXychFNfqig8QpaymWY",
                                apiKey: "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"
                            )
                            let openAI = OpenAI(config)
                            let chatParameters = ChatParameters(model: "gpt-3.5-turbo", messages: chat)
                            
                            // チャットの生成
                            let chatCompletion = try await openAI.generateChatCompletion(
                                parameters: chatParameters
                            )
                            
                            isCompleting = false
                            // AIのレスポンスをチャットに追加
                            chat.append(ChatMessage(role: .assistant, content: chatCompletion.choices[0].message.content))
                        } catch {
                            print("ERROR DETAILS - \(error)")
                        }
                    }
                }) {
                    // 送信ボタンのデザイン
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(self.text == "" ? Color(#colorLiteral(red: 0.75, green: 0.95, blue: 0.8, alpha: 1)) : Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)))
                }
                // テキストが空またはチャットが完了していない場合はボタンを無効化
                .disabled(self.text == "" || isCompleting)
            }
            .padding(.horizontal)
            .padding(.bottom, 8) // 下部のパディングを調整
        }
    }
}

// メッセージのビュー
struct MessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role.rawValue == "user" {
                Spacer()
            } else {
                // ユーザーでない場合はアバターを表示
                AvatarView(imageName: "avatar")
                    .padding(.trailing, 8)
            }
            VStack(alignment: .leading, spacing: 4) {
                // メッセージのテキストを表示
                Text(message.content)
                    .font(.system(size: 14)) // フォントサイズを調整
                    .foregroundColor(message.role.rawValue == "user" ? .white : .black)
                    .padding(10)
                    // ユーザーとAIのメッセージで背景色を変更
                    .background(message.role.rawValue == "user" ? Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                    .cornerRadius(20) // 角を丸くする
            }
            .padding(.vertical, 5)
            // ユーザーのメッセージの場合は右側にスペースを追加
            if message.role.rawValue != "user" {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// アバタービュー
struct AvatarView: View {
    var imageName: String
    
    var body: some View {
        VStack {
            // アバター画像を円形に表示
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            // AIの名前を表示
            Text("AI")
                .font(.caption) // フォントサイズを小さくするためのオプションです。
                .foregroundColor(.black) // テキストの色を黒に設定します。
        }
    }
}

// プレビュー
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Chat()
    }
}

//import SwiftUI
//import FirebaseFirestore
//import KeyboardObserving
//import OpenAIKit
//
//struct HomeView: View {
//    @State var message = ""
//    @State var history: [Message] = []
//
//    var body: some View {
//        VStack {
//            List {
//                ForEach(history, id: \.id) { m in
//                    Text(m.text)
//                }
//            }
//            HStack {
//                TextField("メッセージ", text: $message).padding()
//                Button(action: {
//                    let db = Firestore.firestore()
//                    db.collection("messages").addDocument(data: ["text":self.message]) { err in
//                        if let e = err {
//                            print(e)
//                        } else {
//                            print("sent")
//                        }
//                    }
//                    self.message = ""
//                }) {
//                    Image(systemName:"paperplane.fill").padding()
//                }
//            }
//        }.keyboardObserving().onAppear  {
//            let db = Firestore.firestore()
//            db.collection("messages").addSnapshotListener {
//                (snapshot, err) in
//                if err != nil {
//                    print("error")
//                } else {
//                    snapshot?.documentChanges.forEach({(diff) in
//                        if diff.type == .added {
//                            let m = Message(data: diff.document.data())
//                            self.history.append(m)
//                        }
//                    })
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
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
