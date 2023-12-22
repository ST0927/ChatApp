//
//  TimeCount.swift
//  Chatapp
//
//  Created by Shigeyuki TAIRA on 2023/10/27.
//

import Foundation
import Combine

class TimerCount: ObservableObject{
    @Published var count: Double = 0
    @Published var timer: AnyCancellable!
    func start(_ interval: Double = 1.0){
        if let _timer = timer{
            _timer.cancel()
        }

        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({_ in
                self.count += 0.1
            }))
    }
    func stop(){
        print("stop timer!")
        timer?.cancel()
        timer = nil
    }
}
