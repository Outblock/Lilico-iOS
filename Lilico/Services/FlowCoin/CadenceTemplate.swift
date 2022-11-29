//
//  Cadence.swift
//  Lilico
//
//  Created by Selina on 29/6/2022.
//

import Foundation

class CadenceTemplate {
    static let addToken = """
        import FungibleToken from 0xFungibleToken
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
    
    static let queryAddressByDomainFlowns = """
        import Flowns from 0xFlowns
        import Domains from 0xDomains
        pub fun main(name: String, root: String) : Address? {
            let prefix = "0x"
            let rootHahsh = Flowns.hash(node: "", lable: root)
            let namehash = prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
            var address = Domains.getRecords(namehash)
            return address
        }
    """
    
    static let transferTokenWithInbox = """
      import FungibleToken from 0xFungibleToken
      import Domains from 0xDomains
      import <Token> from <TokenAddress>

      transaction(amount: UFix64, recipient: Address) {
        let senderRef: &{FungibleToken.Receiver}
        // The Vault resource that holds the tokens that are being transfered
        let sentVault: @FungibleToken.Vault
        let sender: Address

        prepare(signer: AuthAccount) {
          // Get a reference to the signer's stored vault
          let vaultRef = signer.borrow<&<Token>.Vault>(from: <TokenStoragePath>)
            ?? panic("Could not borrow reference to the owner's Vault!")
          self.senderRef = signer.getCapability(<TokenReceiverPath>)
            .borrow<&{FungibleToken.Receiver}>()!
          self.sender = vaultRef.owner!.address
          // Withdraw tokens from the signer's stored vault
          self.sentVault <- vaultRef.withdraw(amount: amount)
        }

        execute {
          // Get the recipient's public account object
          let recipientAccount = getAccount(recipient)

          // Get a reference to the recipient's Receiver
          let receiverRef = recipientAccount.getCapability(<TokenReceiverPath>)
            .borrow<&{FungibleToken.Receiver}>()
          
          if receiverRef == nil {
              let collectionCap = recipientAccount.getCapability<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
              let collection = collectionCap.borrow()!
              var defaultDomain: &{Domains.DomainPublic}? = nil

              let ids = collection.getIDs()

              if ids.length == 0 {
                  panic("Recipient have no domain ")
              }
              
              defaultDomain = collection.borrowDomain(id: ids[0])!
                  // check defualt domain
              for id in ids {
                let domain = collection.borrowDomain(id: id)!
                let isDefault = domain.getText(key: "isDefault")
                if isDefault == "true" {
                  defaultDomain = domain
                }
              }
              // Deposit the withdrawn tokens in the recipient's domain inbox
              defaultDomain!.depositVault(from: <- self.sentVault, senderRef: self.senderRef)

          } else {
              // Deposit the withdrawn tokens in the recipient's receiver
              receiverRef!.deposit(from: <- self.sentVault)
          }
        }
      }
    """
    
    static let nftCollectionEnable = """
        import NonFungibleToken from 0xNonFungibleToken
            import MetadataViews from 0xMetadataViews
            import <NFT> from <NFTAddress>

            transaction {

              prepare(signer: AuthAccount) {
                if signer.borrow<&<NFT>.Collection>(from: <CollectionStoragePath>) == nil {
                  let collection <- <NFT>.createEmptyCollection()
                  signer.save(<-collection, to: <CollectionStoragePath>)
                }
                if (signer.getCapability<&<CollectionPublicType>>(<CollectionPublicPath>).borrow() == nil) {
                  signer.unlink(<CollectionPublicPath>)
                  signer.link<&<CollectionPublicType>>(<CollectionPublicPath>, target: <CollectionStoragePath>)
                }
              }
            }
    """
    
    static let nftTransfer = """
      import NonFungibleToken from 0xNonFungibleToken
      import Domains from 0xDomains
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
      import Domains from 0xDomains
      import FungibleToken from 0xFungibleToken
      import Flowns from 0xFlowns
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
    
    static let claimInboxNFT = """
      import Domains from 0xDomains
            import Flowns from 0xFlowns
            import NonFungibleToken from 0xNonFungibleToken
            import MetadataViews from 0xMetadataViews
            import <NFT> from <NFTAddress>

            // key will be 'A.f8d6e0586b0a20c7.Domains.Collection' of a NFT collection
            transaction(name: String, root: String, key: String, itemId: UInt64) {
              var domain: &{Domains.DomainPrivate}
              var collectionRef: &<NFT>.Collection
              prepare(account: AuthAccount) {
                let prefix = "0x"
                let rootHahsh = Flowns.hash(node: "", lable: root)
                let nameHash = prefix.concat(Flowns.hash(node: rootHahsh, lable: name))
                var domain: &{Domains.DomainPrivate}? = nil
                let collectionPrivate = account.borrow<&{Domains.CollectionPrivate}>(from: Domains.CollectionStoragePath) ?? panic("Could not find your domain collection cap")

                let id = Domains.getDomainId(nameHash)
                if id !=nil {
                  domain = collectionPrivate.borrowDomainPrivate(id!)
                }
                self.domain = domain!

                let collectionRef = account.borrow<&<NFT>.Collection>(from: <CollectionStoragePath>)
                if collectionRef == nil {
                  account.save(<- <NFT>.createEmptyCollection(), to: <CollectionStoragePath>)
                  account.link<&<CollectionPublicType>>(<CollectionPublicPath>, target: <CollectionStoragePath>)
                  self.collectionRef = account.borrow<&<NFT>.Collection>(from: <CollectionStoragePath>)?? panic("Can not borrow collection")
                } else {
                  self.collectionRef = collectionRef!
                }
              
              }
              execute {
                self.collectionRef.deposit(token: <- self.domain.withdrawNFT(key: key, itemId: itemId))
              }
            }
    """
    
    static let swapFromTokenToOtherToken = """
    import Token1Name from Token1Addr
        import FungibleToken from 0x9a0766d93b6608b7
        import SwapRouter from 0x2f8af5ed05bbde0d
        import SwapError from 0xddb929038d45d4b3
        transaction(
            tokenKeyFlatSplitPath: [String],
            amountInSplit: [UFix64],
            amountOutMin: UFix64,
            deadline: UFix64,
            tokenInVaultPath: StoragePath,
            tokenOutVaultPath: StoragePath,
            tokenOutReceiverPath: PublicPath,
            tokenOutBalancePath: PublicPath,
        ) {
            prepare(userAccount: AuthAccount) {
                assert(deadline >= getCurrentBlock().timestamp, message:
                    SwapError.ErrorEncode(
                        msg: "EXPIRED",
                        err: SwapError.ErrorCode.EXPIRED
                    )
                )
                let len = tokenKeyFlatSplitPath.length
                let tokenInKey = tokenKeyFlatSplitPath[0]
                let tokenOutKey = tokenKeyFlatSplitPath[len-1]
                var tokenOutAmountTotal = 0.0
                var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
                if tokenOutReceiverRef == nil {
                    userAccount.save(<- Token1Name.createEmptyVault(), to: tokenOutVaultPath)
                    userAccount.link<&Token1Name.Vault{FungibleToken.Receiver}>(tokenOutReceiverPath, target: tokenOutVaultPath)
                    userAccount.link<&Token1Name.Vault{FungibleToken.Balance}>(tokenOutBalancePath, target: tokenOutVaultPath)
                    tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
                }
                var pathIndex = 0
                var i = 0
                var path: [String] = []
                while(i < len) {
                    var curTokenKey = tokenKeyFlatSplitPath[i]
                    path.append(curTokenKey)
                    if (curTokenKey == tokenOutKey) {
                        log(path)
                        let tokenInAmount = amountInSplit[pathIndex]
                        let tokenInVault <- userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)!.withdraw(amount: tokenInAmount)
                        let tokenOutVault <- SwapRouter.swapWithPath(vaultIn: <- tokenInVault, tokenKeyPath: path, exactAmounts: nil)
                        tokenOutAmountTotal = tokenOutAmountTotal + tokenOutVault.balance
                        tokenOutReceiverRef!.deposit(from: <- tokenOutVault)
                        path = []
                        pathIndex = pathIndex + 1
                    }
                    i = i + 1
                }
                assert(tokenOutAmountTotal >= amountOutMin, message:
                    SwapError.ErrorEncode(
                        msg: "SLIPPAGE_OFFSET_TOO_LARGE expect min ".concat(amountOutMin.toString()).concat(" got ").concat(tokenOutAmountTotal.toString()),
                        err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
                    )
                )
            }
        }
    """
    
    static let swapOtherTokenToFromToken = """
    import Token1Name from Token1Addr
        import FungibleToken from 0x9a0766d93b6608b7
        import SwapRouter from 0x2f8af5ed05bbde0d
        import SwapError from 0xddb929038d45d4b3
        transaction(
            tokenKeyFlatSplitPath: [String],
            amountOutSplit: [UFix64],
            amountInMax: UFix64,
            deadline: UFix64,
            tokenInVaultPath: StoragePath,
            tokenOutVaultPath: StoragePath,
            tokenOutReceiverPath: PublicPath,
            tokenOutBalancePath: PublicPath,
        ) {
            prepare(userAccount: AuthAccount) {
                assert( deadline >= getCurrentBlock().timestamp, message:
                    SwapError.ErrorEncode(
                        msg: "EXPIRED",
                        err: SwapError.ErrorCode.EXPIRED
                    )
                )
                let len = tokenKeyFlatSplitPath.length
                let tokenInKey = tokenKeyFlatSplitPath[0]
                let tokenOutKey = tokenKeyFlatSplitPath[len-1]
                var tokenOutAmountTotal = 0.0
                var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
                if tokenOutReceiverRef == nil {
                    userAccount.save(<- Token1Name.createEmptyVault(), to: tokenOutVaultPath)
                    userAccount.link<&Token1Name.Vault{FungibleToken.Receiver}>(tokenOutReceiverPath, target: tokenOutVaultPath)
                    userAccount.link<&Token1Name.Vault{FungibleToken.Balance}>(tokenOutBalancePath, target: tokenOutVaultPath)
                    tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
                }
                var pathIndex = 0
                var i = 0
                var path: [String] = []
                var amountInTotal = 0.0
                while(i < len) {
                    var curTokenKey = tokenKeyFlatSplitPath[i]
                    path.append(curTokenKey)
                    if (curTokenKey == tokenOutKey) {
                        log(path)
                        let tokenOutExpectAmount = amountOutSplit[pathIndex]
                        let amounts = SwapRouter.getAmountsIn(amountOut: tokenOutExpectAmount, tokenKeyPath: path)
                        let tokenInAmount = amounts[0]
                        amountInTotal = amountInTotal + tokenInAmount
                        let tokenInVault <- userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)!.withdraw(amount: tokenInAmount)
                        let tokenOutVault <- SwapRouter.swapWithPath(vaultIn: <- tokenInVault, tokenKeyPath: path, exactAmounts: amounts)
                        tokenOutAmountTotal = tokenOutAmountTotal + tokenOutVault.balance
                        tokenOutReceiverRef!.deposit(from: <- tokenOutVault)
                        path = []
                        pathIndex = pathIndex + 1
                    }
                    i = i + 1
                }
                assert(amountInTotal <= amountInMax, message:
                    SwapError.ErrorEncode(
                        msg: "SLIPPAGE_OFFSET_TOO_LARGE",
                        err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
                    )
                )
            }
        }
    """
}

extension CadenceTemplate {
    static let checkStakingIsEnabled = """
        import FlowIDTableStaking from 0xFlowTableStaking

        pub fun main():Bool {
            return FlowIDTableStaking.stakingEnabled()
        }
    """
    
    static let checkAccountStakingIsSetup = """
        import FlowStakingCollection from 0xLockedTokens

        /// Determines if an account is set up with a Staking Collection

        pub fun main(address: Address): Bool {
            return FlowStakingCollection.doesAccountHaveStakingCollection(address: address)
        }
    """
    
    static let setupAccountStaking = """
        import FungibleToken from 0xFungibleToken
        import FlowToken from 0xFlowToken
        import FlowIDTableStaking from 0xFlowTableStaking
        import LockedTokens from 0xLockedTokens
        import FlowStakingCollection from 0xStakingCollection

        /// This transaction sets up an account to use a staking collection
        /// It will work regardless of whether they have a regular account, a two-account locked tokens setup,
        /// or staking objects stored in the unlocked account

        transaction {
            prepare(signer: AuthAccount) {

                // If there isn't already a staking collection
                if signer.borrow<&FlowStakingCollection.StakingCollection>(from: FlowStakingCollection.StakingCollectionStoragePath) == nil {

                    // Create private capabilities for the token holder and unlocked vault
                    let lockedHolder = signer.link<&LockedTokens.TokenHolder>(/private/flowTokenHolder, target: LockedTokens.TokenHolderStoragePath)!
                    let flowToken = signer.link<&FlowToken.Vault>(/private/flowTokenVault, target: /storage/flowTokenVault)!
                    
                    // Create a new Staking Collection and put it in storage
                    if lockedHolder.check() {
                        signer.save(<-FlowStakingCollection.createStakingCollection(unlockedVault: flowToken, tokenHolder: lockedHolder), to: FlowStakingCollection.StakingCollectionStoragePath)
                    } else {
                        signer.save(<-FlowStakingCollection.createStakingCollection(unlockedVault: flowToken, tokenHolder: nil), to: FlowStakingCollection.StakingCollectionStoragePath)
                    }

                    // Create a public link to the staking collection
                    signer.link<&FlowStakingCollection.StakingCollection{FlowStakingCollection.StakingCollectionPublic}>(
                        FlowStakingCollection.StakingCollectionPublicPath,
                        target: FlowStakingCollection.StakingCollectionStoragePath
                    )
                }

                // borrow a reference to the staking collection
                let collectionRef = signer.borrow<&FlowStakingCollection.StakingCollection>(from: FlowStakingCollection.StakingCollectionStoragePath)
                    ?? panic("Could not borrow staking collection reference")

                // If there is a node staker object in the account, put it in the staking collection
                if signer.borrow<&FlowIDTableStaking.NodeStaker>(from: FlowIDTableStaking.NodeStakerStoragePath) != nil {
                    let node <- signer.load<@FlowIDTableStaking.NodeStaker>(from: FlowIDTableStaking.NodeStakerStoragePath)!
                    collectionRef.addNodeObject(<-node, machineAccountInfo: nil)
                }

                // If there is a delegator object in the account, put it in the staking collection
                if signer.borrow<&FlowIDTableStaking.NodeDelegator>(from: FlowIDTableStaking.DelegatorStoragePath) != nil {
                    let delegator <- signer.load<@FlowIDTableStaking.NodeDelegator>(from: FlowIDTableStaking.DelegatorStoragePath)!
                    collectionRef.addDelegatorObject(<-delegator)
                }
            }
        }
    """
}
