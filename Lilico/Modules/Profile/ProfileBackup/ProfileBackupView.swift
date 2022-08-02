//
//  ProfileBackupView.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI

struct ProfileBackupView: View {
    let types: [BackupManager.BackupType] = [.icloud, .googleDrive, .manual]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(types, id: \.self) { type in
                ItemCell(title: type.descLocalizedString)
            }
        }
    }
}

extension ProfileBackupView {
    struct ItemCell: View {
        let title: String
        
        var body: some View {
            HStack(spacing: 0) {
                Image("")
                    .frame(width: 32, height: 32)
                    .background(Color.LL.Secondary.navy5)
                    .clipShape(Circle())
                    .padding(.trailing, 15)
                
                Text(title)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .frame(maxWidth: .infinity)
                
                Image(systemName: .checkmarkSelected)
                    .foregroundColor(Color.LL.Success.success2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
    }
}
