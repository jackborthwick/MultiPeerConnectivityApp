//
//  ViewController.swift
//  MultiPeerConnectivityApp
//
//  Created by Jack Borthwick on 7/27/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource  {

    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    let session = SessionManager(displayName: "Jack")
    var messageCollection = [Message]()
    private let mc_chatCell = "mcChatCellIdentifier"
    
    @IBAction func usersPressed(sender: AnyObject) {
        session.presentBrowser(self)
    }
    
    @IBAction func sendMessagePressed(sender: AnyObject) {
        if inputTextField.text != nil && count(inputTextField.text) > 0 {
            session.writeMessage(inputTextField.text)
            inputTextField.text = ""
        }
    }
    func insertMessage(message: Message) {
        messageCollection.append(message)
        let insertionIndexPath = NSIndexPath(forRow: messageCollection.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([insertionIndexPath], withRowAnimation: .Fade)
        tableView.scrollToRowAtIndexPath(insertionIndexPath, atScrollPosition: .Bottom, animated: false)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCollection.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var cell :MessageTableViewCell = tableView.dequeueReusableCellWithIdentifier(mc_chatCell, forIndexPath: indexPath) as!MessageTableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    func configureCell(cell: MessageTableViewCell, indexPath: NSIndexPath) {
        let message = messageCollection[indexPath.row]
        cell.senderLabel.text = message.peer?.displayName != nil ? "\(message.peer!.displayName!) ::" : "N/A"
        println(message.peer?.displayName != nil ? "\(message.peer!.displayName!) ::" : "N/A")
        cell.messageLabel.text = message.message
    }
    //func configureCell
    
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillChangeFrame(aNotification: NSNotification) {
        let info = aNotification.userInfo!
        
        var frameEnd = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        var convertedFrameEnd = self.view.convertRect(frameEnd, fromView: nil)
        var heightOffSet = self.view.bounds.size.height - convertedFrameEnd.origin.y
        
        var animationDurationValue = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        var duration: NSTimeInterval = 0
        animationDurationValue.getValue(&duration)
        
        self.bottomConstraint.constant = heightOffSet
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.messageView.layoutIfNeeded()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        session.receiveMessage { [weak self](message) -> Void in
            self?.insertMessage(message)
        }
        registerForKeyboardNotifications()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

