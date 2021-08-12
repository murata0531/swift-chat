//
//  ChatRoom.swift
//  swift-chat
//
//  Created by 村田尚輝 on 2021/07/29.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct ChatRoom: View {
    
    @State var isActiveLogin = false
    @State private var isInActiveLogin = false
    @State var rooms = [String]()
    @State private var message = ""
    
    let room_id:String
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            NavigationLink(
                destination: ContentView(),
                isActive: $isInActiveLogin){
                EmptyView()
            }
            
            List(rooms, id: \.self) { item in
                NavigationLink(destination: ChatRoom(room_id: String(item))) {
                    Text(item)
                }
            }
            
            Spacer()
            
            HStack {
                TextField("RoundedBorderTextFieldStyle", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    print("a")
                }){
                    Text("送信")
                }
            }
        }
        .onAppear {
            
            if Auth.auth().currentUser != nil {
              // User is signed in.
              // ...
            } else {
              // No user is signed in.
              // ...
                self.isInActiveLogin = true
            }
            
            rooms.removeAll()
            db.collection("chat_data").document(room_id)
                .addSnapshotListener { documentSnapshot, error in
                  guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
                  guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                  }
                    rooms.append(String(data.count))
                }
        }
    }
}

