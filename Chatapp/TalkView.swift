//
//  TalkView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/25.
//

import SwiftUI
import FirebaseFirestore
import KeyboardObserving
import Combine
import UIKit
import Combine

//class DataViewModel: ObservableObject {
//    @Published var responseData: String = ""
//
//    func sendData() {
//        let url = URL(string: "Your_API_Endpoint_URL_Here")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let sendData = ["key": "t9eX8tyr7G_ZQk-2",
//                        "meta": ["area": 1927,
//                                 "type": 1927,
//                                 "sensor_id": UserDefaults.standard.string(forKey: "username") ?? "",
//                                 "data_time": 1/1000],
//                        "body": []] as [String: Any]
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sendData)
//            request.httpBody = jsonData
//        } catch {
//            print("Error: \(error)")
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let responseString = String(data: data, encoding: .utf8) {
//                    DispatchQueue.main.async {
//                        self.responseData = responseString
//                    }
//                }
//            } else if let error = error {
//                print("Error: \(error)")
//            }
//        }.resume()
//    }
//}

struct Talk: View {
    @State var message = ""
    @State var key_message: [String] = []
    @State var key_history:[String] = []
    @State var history: [Message] = []
    @EnvironmentObject var Q: QuestionList
    @State var isButtonDisabled: Bool = false
    @State var start:Bool = true //アンケートを開始するかを決める変数
    @State var offsetY: CGFloat = 0
    @State var initOffsetY: CGFloat = 0
    @State var pre: CGFloat = 0
    @State var current: CGFloat = 0
    @State var scroll: Bool = false
    @State var Time: AnyCancellable?
    @State var startposition: CGFloat = 0
    @State var endposition: CGFloat = 0
    @State var ScrollTime: AnyCancellable?
    @State var ScrollTimeCount:Double = 0
    @State var ScrollingTime:Double = 0
    @State var ScrollSpeed:Double = 0
    @State var unScrollTime: AnyCancellable?
    @State var unScrollTimeCount:Double = 0
    @State var UnScrollTimeCount:Double = 0
    @State var Delete: Int = 0
    
    //質問内容の枠
    func Q_frame(s: String) -> some View {
        HStack(alignment: .top) {
            AvatarView(imageName: "avatar")
            Text(s).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1))).cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(.horizontal, 10)
    }
    //回答の枠/右端に回答内容を表示
    func A_frame(s: String) -> some View {
        HStack {
            Spacer()
            Text(s).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.2078431373, green: 0.7647058824, blue: 0.3450980392, alpha: 1))).cornerRadius(10)
        }.padding(.horizontal, 10)
    }
    //画像の枠
    func I_frame(i: String) -> some View {
            Image(i)
                .resizable()
                .frame(width: 200, height: 200)
                .border(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)), width: 1)
                .background(Color.white)
    }
    
    var body: some View {
        ZStack {
            Color(red:1.0,green:0.98,blue:0.94).ignoresSafeArea(edges: [.bottom])
            VStack(alignment: .leading) {
                ScrollViewReader { proxy in
                    ScrollView {
                        if start == false {
                            HStack(alignment: .top) {
                                AvatarView(imageName: "avatar").padding(10)
                                VStack(spacing: 0) {
                                    Text("アンケートを始めますか？").frame(width: 200).font(.system(size: 14)).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    Button(action: {
                                        start = true
                                        let db = Firestore.firestore()
                                        db.collection("messages").addDocument(data: ["text": "始める"]) { err in
                                            if let e = err {
                                                print(e)
                                            } else {
                                                print("sent")
                                            }
                                        }
                                    })
                                    {
                                        Text("はい").frame(width: 200).padding(10).background(Color(#colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9176470588, alpha: 1)))
                                    }.disabled(isButtonDisabled)
                                }
                                Spacer()
                            }.padding(.top, 10)
                        } else {
                            ForEach(history.indices, id: \.self) { index in
                                let Num = index+1 //indexがIntじゃないから数字を足す
                                A_frame(s:" \(history[index].text)")
                                HStack(alignment: .top) {
                                    VStack(spacing: 0) {
                                        Q_frame(s:"問 \(Num)： 魅力的だと思う画像を選んでください")
                                        HStack(spacing: 0) {
                                            if Num/2 <= (Q.ImageName.count/4) {
                                                I_frame(i:Q.ImageName[Num*2 - 2])
                                                I_frame(i:Q.ImageName[Num*2 - 1])
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                            }.padding(.vertical, 5)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(
                                                key: ScrollOffsetYPreferenceKey.self,
                                                value: [geometry.frame(in: .global).minY]
                                            ).onAppear {
                                                initOffsetY = geometry.frame(in: .global).minY
                                            }
                                    }
                                )
                        }
                        Spacer(minLength: 50).id("footer")
                    }.padding(.bottom, 55)
                        .onChange(of: history.indices) {
                                    withAnimation {
                                        proxy.scrollTo("footer")
                                    }
                                }
                        .onPreferenceChange(ScrollOffsetYPreferenceKey.self) { value in
                            offsetY = value[0]
                            if scroll == false {
                                print("start")
                                startposition = offsetY - initOffsetY
                                UnScrollTimeCount = unScrollTimeCount
                                if let _timer = ScrollTime{
                                    _timer.cancel()
                                }
                                ScrollTime = Timer.publish(every: 0.1, on: .main, in: .common)
                                    .autoconnect()
                                    .receive(on: DispatchQueue.main)
                                    .sink { _ in
                                        ScrollTimeCount += 0.1
                                    }
                            }
                            scroll = true
                            current = offsetY - initOffsetY
                            print(offsetY - initOffsetY)
                            if let _timer = Time{
                                _timer.cancel()
                            }
                            Time = Timer.publish(every: 0.1, on: .main, in: .common)
                                .autoconnect()
                                .receive(on: DispatchQueue.main)
                                .sink { _ in
                                    if scroll == true {
                                        if pre == current {
                                            print("end")
                                            endposition = offsetY - initOffsetY
                                            ScrollingTime = ScrollTimeCount
                                            ScrollSpeed = (endposition - startposition)/ScrollingTime
                                            ScrollTimeCount = 0
                                            scroll = false
                                        } else {
                                            print("スクロール中")
                                        }
                                    }
                                    else if pre == current {
                                        unScrollTimeCount = 0
                                        if let _timer = unScrollTime{
                                            _timer.cancel()
                                        }
                                        unScrollTime = Timer.publish(every: 0.1, on: .main, in: .common)
                                            .autoconnect()
                                            .receive(on: DispatchQueue.main)
                                            .sink { _ in
                                                unScrollTimeCount += 0.1
                                            }
                                    }
                                }
                            pre = offsetY - initOffsetY
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
            if start == true {
                Logger(offsetY: $offsetY, initOffsetY: $initOffsetY, pre: $pre, current: $current, scroll: $scroll, startposition: $startposition, endposition: $endposition, ScrollingTime: $ScrollingTime, ScrollSpeed: $ScrollSpeed, UnScrollTimeCount: $UnScrollTimeCount,key_message: $key_message,key_history: $key_history,Delete: $Delete)
                    .environmentObject(TimerCount())
            }
            VStack {
                Spacer()
                HStack(spacing:0) {
                    TextField("　メッセージ", text: $message)
                        .frame(height: 55)
                        .background(Color.white)
                        .onChange(of: message) {
                                key_message.append("\(message)")
                                key_history.append("\(message.replacingOccurrences(of:" ",with: "[空白]"))")
                            if key_message.count > 1 {
                                if key_message[key_message.count-1].count < key_message[key_message.count-2].count {
                                    key_history.append("\(key_message[key_message.count - 1])[削除]")
                                    Delete += 1
                                }
                            }
                        }
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
                        //キーボードを閉じる
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

struct ScrollOffsetYPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = [0]
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct Logger : View {
    @EnvironmentObject var timerController: TimerCount
    @State var tapNum:Int = 0
    @State var LeftChoice:Int = 0
    @State var RightChoice:Int = 0
    @State var TimeCount:Double = 0
    @State var time: AnyCancellable?
    
    @Binding var offsetY:CGFloat
    @Binding var initOffsetY:CGFloat
    @Binding var pre: CGFloat
    @Binding var current: CGFloat
    @Binding var scroll: Bool
    @Binding var startposition: CGFloat
    @Binding var endposition: CGFloat
    @Binding var ScrollingTime:Double
    @Binding var ScrollSpeed:Double
    @Binding var UnScrollTimeCount:Double
    @Binding var key_message:[String]
    @Binding var key_history:[String]
    @Binding var Delete:Int

    var body: some View {
        //透明なビューを設置してタップ回数のカウント
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                tapNum += 1
                TimeCount = 0
                if let _timer = time{
                    _timer.cancel()
                }
                time = Timer.publish(every: 0.1, on: .main, in: .common)
                    .autoconnect()
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        TimeCount += 0.1
                    }
                //キーボードを閉じる
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        //動作確認用
        HStack {
            VStack {
                
                if !key_message.isEmpty {
//                    Text("キーボード入力：\(key_message[key_message.count - 1])")
//                    Text("キーボード入力：\(key_message.joined(separator: ", "))")
                }
                if !key_history.isEmpty {
//                    Text("キーボード入力：\(key_history[key_history.count - 1])")
//                    Text("キーボード入力：\(key_history.joined(separator: ", "))")
                }
                Text("タップ回数：\(tapNum)")
                Text("タップ間隔：\(TimeCount)")
                Text("左を選んだ回数：\(LeftChoice)")
                Text("右を選んだ回数：\(RightChoice)")
                Text("画面位置：\(abs(offsetY - initOffsetY))")
                Text("スクロール長さ：\(abs(endposition - startposition))")
                Text("スクロール時間：\(ScrollingTime)")
                Text("スクロール速度：\(abs(ScrollSpeed))")
                Text("テキスト削除回数：\(Delete)")
//                Text("スクロール間隔：\(UnScrollTimeCount)")
            }
        }
//        Choice(tapNum: $tapNum, LeftChoice: $LeftChoice, RightChoice: $RightChoice,TimeCount: $TimeCount,time: $time)
    }
}

struct Choice : View {
    @EnvironmentObject var timerController: TimerCount
    @Binding var tapNum:Int
    @Binding var LeftChoice:Int
    @Binding var RightChoice:Int
    @Binding var TimeCount:Double
    @Binding var time: AnyCancellable?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    tapNum += 1
                    LeftChoice += 1
                    //以下、環境変数の中身移植したら正常に動作した部分
                    TimeCount = 0
                    if let _timer = time{
                        _timer.cancel()
                    }
                    time = Timer.publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            TimeCount += 0.1
                        }
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text": "左の画像"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
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
                    RightChoice += 1
                    TimeCount = 0
                    if let _timer = time{
                        _timer.cancel()
                    }
                    time = Timer.publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            TimeCount += 0.1
                        }
                    
                    let db = Firestore.firestore()
                    db.collection("messages").addDocument(data: ["text": "右の画像"]) { err in
                        if let e = err {
                            print(e)
                        } else {
                            print("sent")
                        }
                    }
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


