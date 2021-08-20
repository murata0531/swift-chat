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
    
    let room_id:String
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            NavigationLink(
                destination: ContentView(),
                isActive: $isInActiveLogin){
                EmptyView()
            }
//            Label("スレッド　：　\(room_name)", systemImage: "")
//                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            List(messages, id: \.self) { item in
//                Text(item)
//            }
            List(messages) { item in
                Text(item.message)
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
                    
//                    db.collection("chat_data").document(room_id).setData(data, merge: true){ err in
//                        if let err = err {
//                            print("Error writing document: \(err)")
//                        } else {
//                            self.message = ""
//                        }
//                    }
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
            let docRef = db.collection("chat_data").document(room_id).collection(room_id)

            docRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let message_data = document.data()
                        messages.append(Message(uid: message_data["uid"] as? String ?? "",
                                          message: message_data["message"] as? String ?? "",
                                          time: message_data["time"] as? String ?? ""))
                    }
                }
            }
            
//            db.collection("chat_data").document(room_id).collection(room_id).document()
//                .addSnapshotListener { documentSnapshot, error in
//                    guard let document = documentSnapshot else {
//                        print("Error fetching document: \(error!)")
//                        return
//                    }
//                    guard let data = document.data() else {
//                        print("Document data was empty.")
//                        return
//                    }
//                    let value = data["message"] as? String ?? ""
//                    rooms.append(value)
//                    print("Current data: \(document)")
//                }
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let uid: String
    let message: String
    let time: String
}
