//
//  Question.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/11/06.
//

import Foundation
import SwiftUI

class QuestionList : ObservableObject{
    @Published var ImageName = ["りんご１","りんご２","バナナ","みかん","スイカ","メロン"]
    @Published var Qcount: Int = 0
}

