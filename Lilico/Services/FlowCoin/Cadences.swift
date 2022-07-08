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
        import FIND from 0xFIND
        //Check the status of a fin user
        pub fun main(name: String) : Address? {
            let status=FIND.status(name)
            return status.owner
        }
    """
    
    static let queryAddressByDomainFlowns = """
        import Flowns from 0xFLOWNS
        import Domains from 0xDOMAINS
        pub fun main(name: String, root: String) : Address? {
            let prefix = "0x"
            let rootHahsh = Flowns.hash(node: "", lable: root)
            let namehash = prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
            var address = Domains.getRecords(namehash)
            return address
        }
    """
}
