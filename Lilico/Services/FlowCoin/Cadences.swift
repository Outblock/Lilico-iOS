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
    
    static let transferToken = """
        import FungibleToken from 0xFUNGIBLETOKEN
        import FlowToken from 0xFLOWTOKEN
    
        transaction(amount: UFix64, to: Address) {
    
            // The Vault resource that holds the tokens that are being transferred
            let sentVault: @FungibleToken.Vault
    
            prepare(signer: AuthAccount) {
    
                // Get a reference to the signer's stored vault
                let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                    ?? panic("Could not borrow reference to the owner's Vault!")
    
                // Withdraw tokens from the signer's stored vault
                self.sentVault <- vaultRef.withdraw(amount: amount)
            }
    
            execute {
    
                // Get the recipient's public account object
                let recipient = getAccount(to)
    
                // Get a reference to the recipient's Receiver
                let receiverRef = recipient.getCapability(/public/flowTokenReceiver)
                    .borrow<&{FungibleToken.Receiver}>()
                    ?? panic("Could not borrow receiver reference to the recipient's Vault")
    
                // Deposit the withdrawn tokens in the recipient's receiver
                receiverRef.deposit(from: <-self.sentVault)
            }
        }
    """
    
    static let nftCollectionEnable = """
        import NonFungibleToken from 0xNONFUNGIBLETOKEN
        import <NFT> from <NFTAddress>
        
        transaction {
          prepare(signer: AuthAccount) {
              // if the account doesn't already have a collection
              if signer.borrow<&<NFT>.Collection>(from: <CollectionStoragePath>) == nil {
        
                  // create a new empty collection
                  let collection <- <NFT>.createEmptyCollection()
                  
                  // save it to the account
                  signer.save(<-collection, to: <CollectionStoragePath>)
        
                  // create a public capability for the collection
                  signer.link<&<NFT>.Collection{NonFungibleToken.CollectionPublic, <CollectionPublic>}>(<CollectionPublicPath>, target: <CollectionStoragePath>)
              }
          }
        }
    """
}
