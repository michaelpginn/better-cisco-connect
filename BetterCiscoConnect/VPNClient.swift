//
//  VPNClient.swift
//  BetterCiscoConnect
//
//  Created by Michael Ginn on 3/28/23.
//

import Foundation
import KeychainAccess

class VPNClient: ObservableObject {
    enum VPNState {
        case connected, disconnected, error, loading, needsCredentials
    }

    @Published var state: VPNState = .loading

    var username: String? = nil
    var password: String? = nil

    private let keychain = Keychain(service: "com.michaelginn.BetterCiscoConnect")

    init() {
        self.reloadState()
    }

    private static func getState() -> VPNState {
        do {
            let result = try safeShell("/opt/cisco/secureclient/bin/vpn state")
            print(result)
            return result.contains("Connected") ? .connected : .disconnected
        } catch {
            print("\(error)")
        }
        return .error
    }

    /// Sets the appropriate state, based on whether credentials are present and whether the user is connected to the VPN
    func reloadState() {
        self.state = .loading

        if let username = keychain["username"],
           let password = keychain["password"] {
            self.username = username
            self.password = password
            self.state = VPNClient.getState()
        } else {
            print("Need credentials")
            // Need to get credentials
            self.state = .needsCredentials
        }
    }

    func storeCredentials(username: String, password: String) {
        keychain["password"] = password
        keychain["username"] = username

        self.username = username
        self.password = password

        reloadState()
    }

    func disconnectVPN() {
        do {
            try safeShell("/opt/cisco/secureclient/bin/vpn disconnect")
            reloadState()
        } catch {
            state = .error
            print("\(error)")
        }
    }

    func connectVPN() {
        guard let username, let password else {
            print("No credentials! How did you even get here?")
            state = .needsCredentials
            return
        }

        do {
            try safeShell("/opt/cisco/secureclient/bin/vpn connect vpn.colorado.edu -s <<< $'\(username)\n\(password)\n'")
            reloadState()
        } catch {
            state = .error
            print("\(error)")
        }
    }
}
