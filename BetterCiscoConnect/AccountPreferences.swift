//
//  AccountPreferences.swift
//  BetterCiscoConnect
//
//  Created by Michael Ginn on 8/15/23.
//

import SwiftUI

struct AccountPreferences: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var client: VPNClient
    @State var username: String
    @State var password: String

    var body: some View {
        Form {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Save") {
                client.storeCredentials(username: username, password: password)
                dismiss()
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

struct AccountPreferences_Previews: PreviewProvider {
    static var previews: some View {
        AccountPreferences(client: VPNClient(), username: "", password: "")
    }
}
