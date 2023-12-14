//
//  QuestionListView.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/12/14.
//

import SwiftUI

struct QuestionListView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: Talk()){
                Text("アンケート画面へ")
                .padding()
            }
        }
    }
}

#Preview {
    QuestionListView()
}
