//
//  CreateKeys.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 2018/5/23.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import Foundation
import LocalAuthentication
// the keys need labels, which should be unique to your app
let privateLabel = "an app specific label for your private key"
let publicLabel = "an app specific label for your public key"

// create an Access Control
func createAccessControl() -> SecAccessControl? {
    var accessControlError: Unmanaged<CFError>?
    guard let accessControl = SecAccessControlCreateWithFlags(
        kCFAllocatorDefault,
        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
        [.touchIDCurrentSet], &accessControlError) else {
            // couldn't create accessControl
            return nil
    }
    
    return accessControl
}

func createKeyPair(_ accessControl: SecAccessControl) {
    let privateKeyParams: [String: Any] = [
        kSecAttrLabel as String: privateLabel,
        kSecAttrIsPermanent as String: true,
        kSecAttrAccessControl as String: accessControl,
        ]
    
    let params: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits as String: 256,
        kSecPrivateKeyAttrs as String: privateKeyParams,
        kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        ]
    
    // create the key pair
    var _publicKey, _privateKey: SecKey?
    let status = SecKeyGeneratePair(params as CFDictionary, &_publicKey, &_privateKey)
    
    guard status == errSecSuccess,
        let publicKey = _publicKey,
        let privateKey = _privateKey else {
            // couldn't generate key pair
            return
    }
    
    // force store the public key in the keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecAttrApplicationTag as String: publicLabel,
        kSecValueRef as String: publicKey,
        kSecAttrIsPermanent as String: true,
        kSecReturnData as String: true,
        ]
    
    // add the public key to the keychain
    var raw: CFTypeRef?
    var status2 = SecItemAdd(query as CFDictionary, &raw)
    
    // if it already exists, delete it and try to add it again
    if status2 == errSecDuplicateItem {
        status2 = SecItemDelete(query as CFDictionary)
        status2 = SecItemAdd(query as CFDictionary, &raw)
    }
}


func getPublicKey() -> CFDictionary? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrApplicationTag as String: publicLabel, // the public label you used when the key was created
        kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
        kSecReturnData as String: true,
        kSecReturnRef as String: true,
        kSecReturnPersistentRef as String: true,
        ]
    
    var publicKey: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &publicKey)
    
    guard status == errSecSuccess else {
        // couldn't get public key
        return nil
    }
    
    return publicKey as! CFDictionary
}


//To get the SecKey reference from the CFDictionary of the public key above:
/**
let converted = publicKey as! [String: Any]
let keyRef = converted[kSecValueRef as String] as! SecKey
*/
 
//To get the actual key data from the public key:
/**
let converted = publicKey as! [String: Any]
let data = converted[kSecValueData as String] as! Data
 */

//If you’re sending this key data to a server, you’ll almost certainly want it in the DER or PEM formats that OpenSSL understands:

/**
let x9_62HeaderECHeader = [UInt8]([
    /* sequence          */ 0x30, 0x59,
                            /* |-> sequence      */ 0x30, 0x13,
                                                    /* |---> ecPublicKey */ 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, // http://oid-info.com/get/1.2.840.10045.2.1 (ANSI X9.62 public key type)
    /* |---> prime256v1  */ 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, // http://oid-info.com/get/1.2.840.10045.3.1.7 (ANSI X9.62 named elliptic curve)
    /* |-> bit headers   */ 0x07, 0x03, 0x42, 0x00
    ])

let DER = Data(x9_62HeaderECHeader) + data

let PEM =
    "-----BEGIN PUBLIC KEY-----\n"
        + DER.base64EncodedString(options: [.lineLength64Characters, .endLineWithCarriageReturn])
        + "\n-----END PUBLIC KEY-----"

*/

func getPrivateKey(context: LAContext) -> SecKey? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
        kSecAttrLabel as String: privateLabel, // the private label you used when the key was created
        kSecReturnRef as String: true,
        kSecUseOperationPrompt as String: "", // a prompt shown to the user for why they key is needed
        kSecUseAuthenticationContext as String: context, // an LAContext on which `evaluatePolicy` has succeeded
    ]
    
    var privateKey: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &privateKey)
    
    guard status == errSecSuccess else {
        // couldn't get private key
        return nil
    }
    
    return privateKey as! SecKey
}

/**
 
 How can this be used?
 When the user chooses to use biometric auth, create a public / private key pair for storing in the Secure Enclave, and store the public key in the keychain for later use. Then the public key can be used for either:
 
 Encryption
 User data can be encrypted using the public key, secure in the knowledge that it can only be decrypted by the Secure Enclave which contains the matching private key, and which can only be accessed after a successful biometric authentication.
 
 Signing
 The public key can be sent to a server and associated with a user and device. Subsequently, in order to get a session token from the server:
 
 the app makes a request to the server for a string of random data (a nonce).
 
 after a successful biometric authentication, the app signs the nonce using the private key in the Secure Enclave, and sends the signed nonce back to the server.
 
 the server can then use the public key which was registered for the user to verify the signature of the nonce, indicating that the user has been authenticated on the device, and so then provides a session token. This would substitute the normal username plus password hash being sent for server authentication.
 
 Code examples for the various steps above are provided below. These are just examples without any error handling.
 
 I highly recommend looking at the SecureEnclaveCrypto repo in GitHub from where I got most of this code, and on which I based my implementation. The repo hasn’t been updated for iOS 11 or Swift 4.x unfortunately. The EllipticCurveKeyPair repo is also very useful to look at, and is where I got the algorithm for converting a public key into DER and PEM formats.
 

 */

//Sign some data
func sign(_ message: Data, privateKey: SecKey) -> Data? {
    var error : Unmanaged<CFError>?
    let result = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, message as CFData, &error)
    guard let signature = result else {
        return nil
    }
    
    return signature as Data
}

//Encrypt some data
func encrypt(_ message: Data, publicKey: SecKey) -> Data? {
    var error : Unmanaged<CFError>?
    
    let result = SecKeyCreateEncryptedData(publicKey, .eciesEncryptionStandardX963SHA256AESGCM, message as CFData, &error)
    
    if result == nil {
        return nil
    }
    
    return result as! Data
}

//Decrypt some data

func decrypt(_ encrypted: Data, privateKey: SecKey) -> Data? {
    var error : Unmanaged<CFError>?
    
    let result = SecKeyCreateDecryptedData(privateKey, .eciesEncryptionStandardX963SHA256AESGCM, encrypted as CFData, &error)
    
    if result == nil {
        return nil
    }
    
    return result as! Data
}
