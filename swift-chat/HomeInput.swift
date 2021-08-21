//
//  HomeInput.swift
//  swift-chat
//
//  Created by 村田尚輝 on 2021/08/21.
//

import SwiftUI

struct HomeInput: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var name: String
    
    var body: some View {
        VStack{
            Spacer()
            Text("スレッド名を入力")
            TextField("スレッド名", text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.name = ""
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("キャンセル")
                }
                Spacer()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
                .disabled(name.count == 0)
                Spacer()
            }
        }
        .padding()
    }
}
