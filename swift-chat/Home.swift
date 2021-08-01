//
//  Home.swift
//  swift-chat
//
//  Created by it01 on 2021/06/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase


struct Home: View {
    

    
    @State var isActiveLogin = false
    @State var newCreate = ""
    @State var message = ""
    @State var messageCount = 0
//    @State var rooms:Dictionary<String,String> = [:]
    @State var rooms = [String]()
    let db = Firestore.firestore()

    var body: some View {

        if let user = Auth.auth().currentUser {
            //ログインしている
            
            let uid = String(user.uid)
            let uemail = String(user.email!)
            let photoURL = user.photoURL
            
            VStack {
                
                Label("タイトル", systemImage: "")
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Label("新規スレッド作成", systemImage: "")
                TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $newCreate)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Button(action: {
                    
                    if self.newCreate != "" {
                        
                        let dt = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
                        let room = dateFormatter.string(from: dt)
                        
                        let newCreateRoom = newCreate + room
//                        ref.child("chat_rooms").child(newCreateRoom).setValue(["id": newCreateRoom,"room_name": newCreate])
                        let data: [String: Any] = ["name":newCreate, "time": room]
                        db.collection("chat_rooms").document(newCreateRoom).setData(data, merge: true)
                    }
                    self.newCreate = ""
                }) {
                    Text("作成する")
                }
                
                Spacer()
                
                List(rooms, id: \.self) { item in
                    Text(item)
                }
                
                
            }
            .onAppear {
                
            }
            
            
        } else {
            //ログインしていない
            NavigationLink(
                destination: ContentView(),
                isActive: $isActiveLogin){
                EmptyView()
            }
        }
    }
}

struct Rooms: Identifiable {
    let id = UUID()
    let name: String
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
