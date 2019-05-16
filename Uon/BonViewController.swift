//
//  BonViewController.swift
//  Bon
//
//  Created by Chris on 16/5/14.
//  Copyright © 2016年 Chris. All rights reserved.
//

import Cocoa

class BonViewController: NSViewController {
    
    @IBOutlet weak var infoTableView: NSTableView!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBOutlet weak var bonLoginView: BonLoginView!
    @IBOutlet weak var settingsButton: BonButton!
    
    var username: String = ""{
        didSet {
            usernameTextField.stringValue = username
            BonUserDefaults.username = username
        }
    }
    var password: String = ""{
        didSet {
            passwordTextField.stringValue = password
            BonUserDefaults.password = password
        }
    }
    
    var seconds: Int = 0
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.isOpaque = false
        view.window?.backgroundColor = NSColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.bonHighlight().cgColor
        
        username = BonUserDefaults.username
        password = BonUserDefaults.password
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getOnlineInfo),
            name: Notification.Name(rawValue: BonConfig.BonNotification.GetOnlineInfo),
            object: nil
        )

        getOnlineInfo()
        
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        
        bonLoginView.show(.loading)
        login()
        
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        
        bonLoginView.show(.loading)
        logout()
        
    }
    
    @IBAction func switchToPasswordTextField(_ sender: AnyObject) {
        usernameTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    
    @IBAction func enterKeyPressed(_ sender: AnyObject) {
        onLoginButton(sender)
    }
    
    @IBAction func onSettingsButton(_ sender: BonButton) {
        SettingsMenuAction.makeSettingsMenu(sender)
    }
    
    func showLoginView() {
        bonLoginView.isHidden = false
    }
    
    func hideLoginView() {
        bonLoginView.isHidden = true
    }
    
    // MARK: - Network operation
    
    func login() {
        username = usernameTextField.stringValue
        password = passwordTextField.stringValue
        let queryString: String = BonNetwork.getQueryString()
        let parameters = [
            "userId": username.encodeURIComponent(),
            "password": password.encrypt(),
            "service": "",
            "queryString": queryString.encodeURIComponent(),
            "operatorPwd": "",
            "operatorUserId": "",
            "validcode": "",
            "passwordEncrypt": "true"
        ]
        
        BonNetwork.post(parameters, success: { (value) in
            print(value)
            if value.contains("success") {
                
                delay(1) {
                    self.getOnlineInfo()
                }
                delay(1) {
                    self.bonLoginView.show(.loginSuccess)
                }
            } else if value.contains("You are already online.") || value.contains("IP has been online, please logout.") {
                delay(1) {
                    self.getOnlineInfo()
                }
                delay(1) {
                    self.bonLoginView.show(.loginSuccess)
                }
            } else if value.contains("Password is error.") {
                delay(1) {
                    self.bonLoginView.show(.passwordError)
                }
            } else if value.contains("User not found.") {
                delay(1) {
                    self.bonLoginView.show(.usernameError)
                }
            } else if value.contains("Arrearage users.") { // E2616: Arrearage users.(已欠费)
                delay(1) {
                    self.bonLoginView.show(.inArrearsError)
                }
            }
            else {
                delay(1) {
                    self.bonLoginView.show(.error)
                }
            }
        }) { (error) in
            print(self.username)
            print(self.password)
            self.bonLoginView.show(.timeout)
        }
    }
    
    
    // MARK : - logout
    
    func logout() {
        
        BonNetwork.get(URL: UCAS.URL.LogoutURL, success: { (value) in
            NSLog(value)
            self.bonLoginView.isHidden = false
        })
    }
    
    // MARK : - get online info
    
    @objc func getOnlineInfo() {
        
        BonNetwork.get(URL: UCAS.URL.InfoURL, success: { (value) in
            
            NSLog(value)
            if(value.contains("fail")) {
                loginState = .offline
                self.showLoginView()
            } else {
                self.hideLoginView()
                loginState = .online
                self.itemsInfo = [self.username, "INFINITE", "INFINITE", "INFINITE", "INFINITE"]
                
                self.updateItems()
            }
            
        }) { (error) in
            loginState = .offline
            self.showLoginView()
        }
    }
    
    var items = [BonItem]()
    var itemsInfo = [String]()
    let itemsName = ["USERNAME", "USED DATA", "USED TIME", "BALANCE", "DAILY AVAILABLE DATA"]
    
    func updateItems() {
        self.items = []
        for index in 0...4 {
            let item = BonItem(name: itemsName[index], info: itemsInfo[index])
            items.append(item)
        }
        infoTableView.reloadData()
    }
    
}


// MARK: - Table view

extension BonViewController: NSTableViewDataSource {
    
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return items.count
    }
    
    @objc(tableView:viewForTableColumn:row:) func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return BonCell.view(tableView, owner: self, subject: items[row])
    }
    
}

extension BonViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
}
