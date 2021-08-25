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
    
    @State private var showInputModal = false
    
    @State private var cuurent_room = ""
    @State private var isActiveRoom = false
    @State private var isInActiveLogin = false
    @State private var newCreate = ""
    @State private var message = ""
    @State private var messageCount = 0
//    @State var rooms:Dictionary<String,String> = [:]
    @State private var rooms:[Room] = []
    let db = Firestore.firestore()

    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(
                destination: ChatRoom(room_id: String(self.cuurent_room)),
                isActive: $isActiveRoom){
                EmptyView()
            }
            NavigationLink(
                destination: ContentView(),
                isActive: $isInActiveLogin){
                EmptyView()
            }
            List(rooms) { item in
                NavigationLink(destination: ChatRoom(room_id: item.rid)){
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(item.time)").kerning(1)
                        }
                        Spacer().frame(height: 20)
                        HStack {
                            Text("【\(item.name)】").kerning(3).lineSpacing(5)
                        }
                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationBarTitle("スレッド一覧")
            .sheet(isPresented: $showInputModal, onDismiss: {
                if (self.newCreate != "") {
                    let dt = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: "ja_JP"))
                    let room = dateFormatter.string(from: dt)
                    
                    let newCreateRoom = newCreate + room
                    let data: [String: Any] = ["name":newCreate, "time": room]
                    db.collection("chat_rooms").document(newCreateRoom).setData(data, merge: true){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        }
                    }
                    
                    self.cuurent_room = String(newCreateRoom)
                    self.isActiveRoom = true
                    self.newCreate = ""
                }
            }) {
                HomeInput(name: self.$newCreate)
            }
            Button(action: {
                self.showInputModal.toggle()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
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
            db.collection("chat_rooms").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        //print("\(document.documentID) => \(document.data())")
                        let room_data = document.data()
                        //rooms.append(document.documentID)
                        rooms.append(Room(rid: document.documentID,
                                          name: room_data["name"] as? String ?? "",
                                          time: room_data["time"] as? String ?? ""))
                    }
                }
            }
        }
    }
}

struct Room: Identifiable {
    let id = UUID()
    let rid: String
    let name: String
    let time: String
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
