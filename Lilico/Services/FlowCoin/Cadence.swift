//
//  Cadence.swift
//  Lilico
//
//  Created by Selina on 29/6/2022.
//

import Foundation

class Cadences {
    static let addToken = """
        import FungibleToken from 0xFUNGIBLETOKEN
        import <Token> from <TokenAddress>
        transaction {
            prepare(signer: AuthAccount) {
                if(signer.borrow<&<Token>.Vault>(from: <TokenStoragePath>) != nil) {
                    return
                }
                signer.save(<-<Token>.createEmptyVault(), to: <TokenStoragePath>)
                
                signer.link<&<Token>.Vault{FungibleToken.Receiver}>(
                    <TokenReceiverPath>,
                        target: <TokenStoragePath>
                )
                
                signer.link<&<Token>.Vault{FungibleToken.Balance}>(
                    <TokenBalancePath>,
                        target: <TokenStoragePath>
                )
            }
        }
    """
    
    static let queryAddressByDomainFind = """
        import FIND from 0xFind
        //Check the status of a fin user
        pub fun main(name: String) : Address? {
            let status=FIND.status(name)
            return status.owner
        }
    """
}
