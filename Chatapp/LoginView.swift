//
//  LoginView.swift
//  Hello world
//
//  Created by Shigeyuki TAIRA on 2023/09/18.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @State var showingError = false
    @State var error : Error?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore : UserStore
    
    var body: some View {
        VStack {
            Text("メールアドレス")
            TextField("メールアドレス",text: $email)
            Divider()
            .padding(.all,10)

            
            Text("パスワード")
            SecureField("パスワード",text: $password)
            Divider()
            .padding()

            
            Button("ログイン"){
                Auth.auth().signIn(withEmail: self.email, password: self.password) { (result, error) in
                    if let e = error {
                        self.showingError = true
                        self.error = e
                        return
                    }
//                    self.userStore.isAuthenticated = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            }.alert(isPresented: $showingError) {
                Alert.init(title: Text("エラー"),message: Text(self.error!.localizedDescription),dismissButton: .default(Text("OK")))
            }
            .padding()
            
            NavigationLink(destination:PasswordResetView()){
                Text("パスワードを忘れた場合")
            }
            .padding()

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
