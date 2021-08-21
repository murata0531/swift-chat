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
    @State private var message = ""
    @State private var enable: Bool = false
    @State private var color = Color.gray
    @State private var user_id:String = ""
    @State private var room_name:String = ""
    @State private var messages:[Message] = []
    @State private var count = 0
    
    let room_id:String
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            NavigationLink(
                destination: ContentView(),
                isActive: $isInActiveLogin){
                EmptyView()
            }

            List(messages) { item in
                Text(item.counter + ". " + item.message)
            }
            .navigationBarTitle("スレッド　：　\(room_name)")
            
            Spacer()
            
            HStack {
                TextField("メッセージを入力", text: $message)
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
                    
                    db.collection("chat_data")
                        .document(room_id)
                        .collection(room_id)
                        .document(room)
                        .setData(data, merge: true){ err in
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
            
            let room_docRef = db.collection("chat_rooms").document(room_id)
            room_docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    self.room_name = data["name"] as? String ?? ""
                } else {
                    print("Document does not exist")
                }
            }
            
            db.collection("chat_data").document(room_id).collection(room_id)
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            self.count += 1
                            let message_data = diff.document.data()
                            messages.append(Message(counter: String(self.count),
                                            uid: message_data["uid"] as? String ?? "",
                                            message: message_data["message"] as? String ?? "",
                                            time: message_data["time"] as? String ?? ""))
                        }
                        if (diff.type == .modified) {
                            print("Modified: \(diff.document.data())")
                        }
                        if (diff.type == .removed) {
                            print("Removed: \(diff.document.data())")
                        }
                    }
                }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let counter: String
    let uid: String
    let message: String
    let time: String
}
