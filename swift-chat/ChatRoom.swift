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

    let room_id:String
    @State private var isInActiveLogin = false

    var body: some View {
        
        VStack {
            NavigationLink(
                destination: ContentView(),
                isActive: $isInActiveLogin){
                EmptyView()
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
        }
    }
}

