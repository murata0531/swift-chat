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
    
    @State private var isActiveLogin = false
    @State private var isInActiveLogin = false
    @State private var rooms = [String]()
    @State private var message = ""
    @State private var enable: Bool = false
    @State private var color = Color.gray
    @State private var user_id:String = ""
    
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
                Text(item)
            }
            
            Spacer()
            
            HStack {
                TextField("RoundedBorderTextFieldStyle", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: message){ value in
                        if value == "" {
                            self.enable = false
                            self.color = Color.gray
                        } else {
                            self.enable = true
                            self.color = Color.blue
                        }
                    }
                
                Button(action: {
                    
                    let dt = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
                    let room = dateFormatter.string(from: dt)
                    let data: [String: Any] = ["uid": self.user_id, "time": room, "message": self.message]
                    
                    db.collection("chat_data").document(room_id).setData(data, merge: true){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.message = ""
                        }
                    }
                }){
                    Text("送信").foregroundColor(Color.white)
                }
                .disabled(!enable)
                .background(self.color)
            }
        }
        .onAppear {
            
            if Auth.auth().currentUser != nil {
              // User is signed in.
                let user = Auth.auth().currentUser
                if let user = user {
                    self.user_id = user.uid
                }
            } else {
              // No user is signed in.
                self.isInActiveLogin = true
            }
            
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
                    print("Current data: \(data)")
                }
        }
    }
}

