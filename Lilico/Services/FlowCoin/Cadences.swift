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
    
    static let nftTransfer = """
      import NonFungibleToken from 0xNONFUNGIBLETOKEN
      import Domains from 0xDOMAINS
      import <NFT> from <NFTAddress>
      // This transaction is for transferring and NFT from
      // one account to another
      transaction(recipient: Address, withdrawID: UInt64) {
        prepare(signer: AuthAccount) {
          // get the recipients public account object
          let recipient = getAccount(recipient)
          // borrow a reference to the signer's NFT collection
          let collectionRef = signer
            .borrow<&NonFungibleToken.Collection>(from: <CollectionStoragePath>)
            ?? panic("Could not borrow a reference to the owner's collection")
          let senderRef = signer
            .getCapability(<CollectionPublicPath>)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
          // borrow a public reference to the receivers collection
          let recipientRef = recipient
            .getCapability(<CollectionPublicPath>)
            .borrow<&{<CollectionPublic>}>()
          
          if recipientRef == nil {
            let collectionCap = recipient.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
            let collection = collectionCap.borrow()!
            var defaultDomain: &{Domains.DomainPublic}? = nil
          
            let ids = collection.getIDs()
            if ids.length == 0 {
              panic("Recipient have no domain ")
            }
            
            // check defualt domain
            defaultDomain = collection.borrowDomain(id: ids[0])!
            // check defualt domain
            for id in ids {
              let domain = collection.borrowDomain(id: id)!
              let isDefault = domain.getText(key: "isDefault")
              if isDefault == "true" {
                defaultDomain = domain
              }
            }
            let typeKey = collectionRef.getType().identifier
            // withdraw the NFT from the owner's collection
            let nft <- collectionRef.withdraw(withdrawID: withdrawID)
            if defaultDomain!.checkCollection(key: typeKey) == false {
              let collection <- <NFT>.createEmptyCollection()
              defaultDomain!.addCollection(collection: <- collection)
            }
            defaultDomain!.depositNFT(key: typeKey, token: <- nft, senderRef: senderRef )
          } else {
            // withdraw the NFT from the owner's collection
            let nft <- collectionRef.withdraw(withdrawID: withdrawID)
            // Deposit the NFT in the recipient's collection
            recipientRef!.deposit(token: <-nft)
          }
        }
      }
    """
    
    static let claimInboxToken = """
      import Domains from 0xDOMAINS
      import FungibleToken from 0xFUNGIBLETOKEN
      import Flowns from 0xFLOWNS
      import <Token> from <TokenAddress>
      transaction(name: String, root:String, key:String, amount: UFix64) {
        var domain: &{Domains.DomainPrivate}
        var vaultRef: &<Token>.Vault
        prepare(account: AuthAccount) {
          let prefix = "0x"
          let rootHahsh = Flowns.hash(node: "", lable: root)
          let nameHash = prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
          let collectionCap = account.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
          let collection = collectionCap.borrow()!
          var domain: &{Domains.DomainPrivate}? = nil
          let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")
          
          let ids = collection.getIDs()
          let id = Domains.getDomainId(nameHash)
          if id != nil && !Domains.isDeprecated(nameHash: nameHash, domainId: id!) {
            domain = collectionPrivate.borrowDomainPrivate(id!)
          }
          self.domain = domain!
          let vaultRef = account.borrow<&<Token>.Vault>(from: <TokenStoragePath>)
          if vaultRef == nil {
            account.save(<- <Token>.createEmptyVault(), to: <TokenStoragePath>)
            account.link<&<Token>.Vault{FungibleToken.Receiver}>(
              <TokenReceiverPath>,
              target: <TokenStoragePath>
            )
            account.link<&<Token>.Vault{FungibleToken.Balance}>(
              <TokenBalancePath>,
              target: <TokenStoragePath>
            )
            self.vaultRef = account.borrow<&<Token>.Vault>(from: <TokenStoragePath>)
          ?? panic("Could not borrow reference to the owner's Vault!")
          } else {
            self.vaultRef = vaultRef!
          }
        }
        execute {
          self.vaultRef.deposit(from: <- self.domain.withdrawVault(key: key, amount: amount))
        }
      }
    """
}
