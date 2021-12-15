//
//  SettingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import SwiftUI

struct Address: Identifiable, Decodable {
    var id: Int
    var country: String
}

struct ProfileView: View {
    
    @State var isPinned = false
    @State var isDeleted = false
    
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isLogged") var isLogged = false
    @AppStorage("isLiteMode") var isLiteMode = true
    @State var address: Address = Address(id: 1, country: "Canada")
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    profile
                }
                
                Section {
                    NavigationLink {} label: {
//                        Label("Keys", systemImage: "key")
                        Label("Keys") {
                            Image("key")
                                .resizable()
                                .sizeToFit()
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label("Network") {
                            Image("network")
                                .resizable()
                                .sizeToFit()
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label("Cloud") {
                            Image("cloud-security")
                                .resizable()
                                .sizeToFit()
                        }
                    }
                }
                .listRowSeparator(.automatic)
                
                Section {
                    Toggle(isOn: $isLiteMode) {
                        Label("Face ID", systemImage: "faceid")
                    }
                }
                
                linksSection
                
//                updatesSection
//                Button {} label: {
//                    Text("Sign out")
//                        .frame(maxWidth: .infinity)
//                }
//                .tint(.red)
//                .onTapGesture {
//                    isLogged = false
//                    presentationMode.wrappedValue.dismiss()
//                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Account")
            .background(Color.LL.background.edgesIgnoringSafeArea(.all))
//            .task {
//                await fetchAddress()
//                await updates.fetchUpdates()
//            }
//            .refreshable {
//                await fetchAddress()
//                await updates.fetchUpdates()
//            }
        }
    }
    
    var linksSection: some View {
        Section {
            if !isDeleted {
                Link(destination: URL(string: "https://outblock.io")!) {
                    HStack {
                        Label("Website", systemImage: "house")
                            .tint(.primary)
                        Spacer()
                        Image(systemName: "link")
                            .tint(.secondary)
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        withAnimation {
                            isPinned.toggle()
                        }
                    } label: {
                        if isPinned {
                            Label("Unpin", systemImage: "pin.slash")
                        } else {
                            Label("Pin", systemImage: "pin")
                        }
                    }
                    .tint(isPinned ? .gray : .yellow)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        withAnimation {
                            isDeleted.toggle()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            
//            Link(destination: URL(string: "https://designcode.io")!) {
//                HStack {
//                    Label("YouTube", systemImage: "tv")
//                        .tint(.primary)
//                    Spacer()
//                    Image(systemName: "link")
//                        .tint(.secondary)
//                }
//            }
        }
        .listRowSeparator(.automatic)
    }
    
    var profile: some View {
        VStack {
            Image("safe-box")
                .symbolVariant(.circle.fill)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .blue.opacity(0.3), .red)
                .font(.system(size: 32))
                .padding()
                .background(Circle().fill(.ultraThinMaterial))
//                .background(AnimatedBlobView().frame(width: 400, height: 414).offset(x: 200, y: 0).scaleEffect(0.5))
//                .background(HexagonView().offset(x: -50, y: -100))
            Text("Lilico")
                .font(.title.weight(.semibold))
            Text(address.country)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
