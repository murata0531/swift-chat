//
//  ContentView.swift
//  swift-chat
//
//  Created by it01 on 2021/06/09.
//

import SwiftUI
import FirebaseAuth

//ログイン画面
struct ContentView: View {
    
    @State var isActiveHome = false
    
    @State private var isSignIn = false
    @State private var isSignOut = false
    @State private var mail = ""
    @State private var pass = ""
    @State private var pass_confirm = ""
    @State private var isShowAlert = false
    @State private var isError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
        HStack {
            Spacer().frame(width:50)
            
            VStack {
                
                TextField("メールアドレス",text:$mail).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("パスワード",text:$pass).textFieldStyle(RoundedBorderTextFieldStyle())
                
                NavigationLink(
                    destination: Home(),
                    isActive: $isActiveHome){
                    EmptyView()
                }
                
                Button(action: {
                    self.errorMessage = ""
                    if self.mail.isEmpty {
                        self.errorMessage = "メールアドレスが入力されてません"
                        self.isError = true
                        self.isShowAlert = true
                    }else if self.pass.isEmpty {
                        self.errorMessage = "パスワードが入力されていません"
                        self.isError = true
                        self.isShowAlert = true
                    }else {
                        self.signIn()
                        
                        if self.isError == false {
                            self.isActiveHome = true
                        }
                    }
                    
                }){
                    Text("ログイン")
                }
//                .alert(isPresented: $isShowAlert){
//                    if self.isError {
//                        return Alert(title:Text(""),message:Text(self.errorMessage),dismissButton: .destructive(Text("OK")))
//                    }else {
//                        return Alert(title:Text(""),message: Text("ログイン"),dismissButton: .default(Text("ok")))
//                    }
//
//                }
                
                    NavigationLink(destination: Register()) {
                        Text("アカウント登録")
                    }
                }
            }
        }
    }
    
    private func signIn(){
        Auth.auth().signIn(withEmail: self.mail, password: self.pass){ authResult,error in
            
            if authResult?.user != nil {
                self.isSignIn = true
                self.isShowAlert = true
                self.isError = false
            }else {
                self.isSignIn = false
                self.isShowAlert = true
                self.isError = true
                if let error = error as NSError?,let errorCode = AuthErrorCode(rawValue: error.code){
                    
                    switch errorCode {
                    case .invalidEmail:
                        self.errorMessage = "メールアドレスの形式が正しくありません"
                    case .userNotFound, .wrongPassword:
                        self.errorMessage = "メールアドレスまたはパスワードが違います"
                    case .userDisabled:
                        self.errorMessage = "無効なアカウントです"
                    default:
                        self.errorMessage = error.domain
                    }
                    
                    self.isError = true
                    self.isShowAlert = true
                }
            }
        }
    }
}

//アカウント登録画面
struct Register: View {
    
    @State private var mail = ""
    @State private var pass = ""
    @State private var pass_confirm = ""
    @State private var isShowAlert = false
    @State private var isError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
        HStack {
            Spacer().frame(width:50)
            VStack {
                TextField("メールアドレス",text:$mail).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("パスワード",text:$pass).textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("パスワード確認",text:$pass_confirm).textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    self.errorMessage = ""
                    if self.mail.isEmpty {
                        self.errorMessage = "メールアドレスが入力されていません"
                        self.isError = true
                        self.isShowAlert = true
                    }else if self.pass.isEmpty {
                        self.errorMessage = "パスワードが入力されていません"
                        self.isError = true
                        self.isShowAlert = true
                    }else if self.pass_confirm.isEmpty {
                        self.errorMessage = "確認パスワードが入力されていません"
                        self.isError = true
                        self.isShowAlert = true
                    }else if self.pass.compare(self.pass_confirm) != .orderedSame {
                        self.errorMessage = "パスワードが一致しません"
                        self.isError = true
                        self.isShowAlert = true
                    }else {
                        self.signup()
                    }
                    
        
                }){
                    Text("ユーザ登録")
                }
                .alert(isPresented: $isShowAlert){
                    if self.isError {
                        return Alert(title:Text(""),message: Text(self.errorMessage),dismissButton: .destructive(Text("OK")))
                    }else {
                        return Alert(title:Text(""),message: Text("登録されました"),dismissButton: .default(Text("OK")))
                    }
                }
                Spacer()
                HStack{
                    NavigationLink(destination: ContentView()) {
                        Text("ログイン画面へ")
                    }
                }
            }
            
            
            Spacer().frame(width:50)
        }
        }
    }
    
    private func signup(){
        Auth.auth().createUser(withEmail: self.mail, password: self.pass){ authResult,error in
            
            if let error = error as NSError?,let errorCode = AuthErrorCode(rawValue: error.code){
                
                switch errorCode {
                case .invalidEmail:
                    self.errorMessage = "メールアドレスの形式が正しくありません"
                case .emailAlreadyInUse:
                    self.errorMessage = "不正なメールアドレスです"
                case .weakPassword:
                    self.errorMessage = "パスワードは6文字以上で入力してください"
                default:
                    self.errorMessage = error.domain
                }
                
                self.isError = true
                self.isShowAlert = true
            }
            
            if let _ = authResult?.user {
                self.isError = false
                self.isShowAlert = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
