//
//  SessionManager.swift
//  MultiPeerConnectivityApp
//
//  Created by Jack Borthwick on 7/27/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

import UIKit
import MultipeerConnectivity

struct Message {
    var peer: MCPeerID?
    var message: String
}

typealias MessageBlock = (message: Message) -> Void

private let cm_ServiceType = "cm-chat-service"


final class SessionManager: NSObject, MCBrowserViewControllerDelegate{
    private weak var browserPViewController :UIViewController?

    func presentBrowser(controller: UIViewController) {
        let browserPViewController = MCBrowserViewController(browser: browser, session: session)
        browserPViewController.delegate = self
        //browserViewController = controller
        controller.presentViewController(browserPViewController, animated: true, completion: nil)
    }
    
    init(displayName: String = UIDevice.currentDevice().name) {
        localPeer = MCPeerID(displayName: displayName)
        browser = MCNearbyServiceBrowser(peer: localPeer, serviceType: cm_ServiceType)
        advertiser = MCNearbyServiceAdvertiser(peer: localPeer, discoveryInfo: nil, serviceType: cm_ServiceType)
        
        super.init()
        advertiser.delegate = self
        browser.delegate = self
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    

    private var localPeer : MCPeerID
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser
    
    private var messageBlock: MessageBlock?
    private var isAdvertising = false
    private var isBrowsing = false
    
    
    lazy var session: MCSession = {//pass a block to our session variable, and whatever we return is what gets accessed when you do that session
        let session = MCSession(peer: self.localPeer, securityIdentity: nil, encryptionPreference: .None)
        session?.delegate = self
        return session
    }()
    
    func writeMessage(message: String) {
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            writeData(data)
        }
    }
    
    private func writeData(data: NSData) {
        var error: NSError?
        session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable, error: &error)
        if (error ==  nil) {
            readData(data, peer: localPeer)
        }
    }
    
    private func readData(data: NSData, peer: MCPeerID) {
        if let data = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.messageBlock?(message: Message(peer: peer, message: data)  )
            })
        }
    }
    
    //MARK: - Read Block
    func receiveMessage(block: MessageBlock) {
        messageBlock = block
    }
    
    
}

//MARK: - Browser Delegate

extension SessionManager: MCNearbyServiceBrowserDelegate {
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {

        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 10)
        }
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        //noop
    }
}


//MARK: - Advertiser delegate

extension SessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        invitationHandler(true, session)
    }
}


extension SessionManager: MCSessionDelegate {
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        //read data
        readData(data, peer: peerID)
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        //noop
    }
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        //noop
    }
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        //noop
    }
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        //noop
    }
}


// MARK: - MCBrowserViewController Delegate

extension SessionManager: MCBrowserViewControllerDelegate {
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        //noop
    }
    func browserViewController(browserViewController: MCBrowserViewController!, shouldPresentNearbyPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) -> Bool {
        return true
    }
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        browserViewController?.dismissViewControllerAnimated(true, completion: nil)//if erroring might be wrong browser vie controller
    }
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        browserViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}