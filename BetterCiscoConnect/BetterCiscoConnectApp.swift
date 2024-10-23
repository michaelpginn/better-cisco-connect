//
//  BetterCiscoConnectApp.swift
//  BetterCiscoConnect
//
//  Created by Michael Ginn on 3/28/23.
//

import SwiftUI

extension VPNClient.VPNState {
    var systemImage: String {
        switch self {
        case .disconnected: return "shield.lefthalf.filled.slash"
        case .connected: return "shield.lefthalf.filled"
        case .error: return "exclamationmark.shield.fill"
        case .loading: return "rays"
        case .needsCredentials: return "lock.shield"
        }
    }
}

@main
struct BetterCiscoConnectApp: App {
    @StateObject var client = VPNClient()
    @Environment(\.openSettings) private var openSettings

    var body: some Scene {
        MenuBarExtra("VPN", systemImage: client.state.systemImage) {
            VStack(alignment: .leading) {
                Text("Better Cisco Connect")
                switch client.state {
                case .disconnected:
                    Text("VPN Disconnected")
                    Button {
                        client.state = .loading
                        Task {
                            client.connectVPN()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                            Text("Connect")
                        }
                        .padding()
                    }
                    .keyboardShortcut("c")
                case .connected:
                    Text("VPN Connected")
                    Button("Disconnect") {
                        client.state = .loading
                        Task {
                            client.disconnectVPN()
                        }
                    }
                    .keyboardShortcut("d")
                case .error:
                    Text("Error")
                case .loading:
                    Text("Loading...")
                case .needsCredentials:
                    EmptyView()
                }
                Button("Refresh Status") {
                    Task {
                        client.reloadState()
                    }
                }.keyboardShortcut("r")
                Button {
                    NSApp.activate(ignoringOtherApps: true)
                    openSettings()
//                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    Text(client.state == .needsCredentials ? "Log in..." : "Settings")
                }
                Divider()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q")
            }
        }
        Settings {
            AccountPreferences(client: client, username: client.username ?? "", password: client.password ?? "")
        }
    }
}
