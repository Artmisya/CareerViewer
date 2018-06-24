//
//  ContactViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit

import UIKit

import RxSwift
import RxCocoa
class ContactViewController:BaseViewController,UISearchBarDelegate{
    
    
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet var contactTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    private let ROWHEIGHT:CGFloat=169.0
    private let resume=Resume()
    private let disposeBag = DisposeBag()
    
    private var dataSource:Variable<[Contact]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUpUi()
        setUpClickActions()
        
        configureTableView()
        
        loadContact()
        
    }
    
    private func loadContact(){
        
        loadingView.startAnimating()
        
        let cuncurrentQueue = ConcurrentDispatchQueueScheduler(queue:
            DispatchQueue.global(qos:.utility))
        let mainQueue = SerialDispatchQueueScheduler(queue: DispatchQueue.main, internalSerialQueueName: "main")
        
        resume.fetchContacts()
            .observeOn(mainQueue)
            .subscribeOn(cuncurrentQueue)
            .subscribe(
                
                onNext: {
                    
                    //successfully get data
                    
                    self.loadTableView()
            },
                onError: { error in
                    //an error happend while geting data
                    self.handleError(error: error as! ErrorType)
                    
                    self.loadingView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                    
            },
                onCompleted: {
                    
                    self.loadingView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
    }
    
    
    private func setupUpUi(){
        
        self.title="Contact"
        loadingView.hidesWhenStopped=true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh!")
        
    }
    
    private func setUpClickActions(){
        
        
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        contactTableView.addSubview(refreshControl)
        
        // setting print button
        
        let btnName_print = UIButton()
        btnName_print .setImage(UIImage(named: "print"), for: .normal)
        btnName_print .frame = CGRectMake(0, 0, 30, 30)
        btnName_print .addTarget(self, action: #selector(self.printClicked(sender:)), for: .touchUpInside)
        
        //.... Set Left Bar Button item
        let rightBarButton_print  = UIBarButtonItem()
        rightBarButton_print .customView = btnName_print
        self.navigationItem.rightBarButtonItem=rightBarButton_print
        
    }
    
    
    private func configureTableView(){
        
        contactTableView.rowHeight = UITableViewAutomaticDimension
        contactTableView.estimatedRowHeight = ROWHEIGHT
        
        let nib = UINib(nibName: "ContactCell", bundle: nil)
        contactTableView.register(nib, forCellReuseIdentifier: "ContactCell")
    }
    
    
    @objc func didPullToRefresh() {
        
        print ("didPullToRefresh")
        loadContact()
        
    }
    
    
    // load table view using a rxswift observer
    
    private func loadTableView(){
        
        // clear datasource delegate first
        contactTableView.dataSource=nil
        
        //initialize the data source
        dataSource=Variable(resume.contactList!)
        
        // making the bind
        dataSource?.asObservable().bind(to: contactTableView.rx.items(cellIdentifier: "ContactCell")) { index, contactObj,
            cell in
            if let contactCell = cell as? ContactCell {
                
                
                contactCell.contactLbl.text = contactObj.value
                
                // set the icon based on contact type
                contactCell.contactImage.image=UIImage(named: "\(contactObj.type)")
                
                // setting the click action on contact
                contactCell.clickableView.isUserInteractionEnabled=true
                let tapGesture = tapGestureRecognizerwithParam(target: self, action: #selector(self.contactTapped(recognizer: )))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.param=contactObj
                contactCell.clickableView.addGestureRecognizer(tapGesture)
                contactCell.selectionStyle = .none
            }
            
            }.disposed(by: disposeBag)
        
    }
    
    // this method give user a way to contact based on which contact type is clicked
    @objc func contactTapped(recognizer:tapGestureRecognizerwithParam){
        
        let contact=recognizer.param as! Contact
        
        switch contact.type{
            
        case ContactType.email:
            
            openEmail(email:contact.value)
            
        case ContactType.mobile:
            
            call(phoneNo:contact.value)
            
        case  ContactType.linkedin:
            
            openLinkedin(url:contact.value)
            
        case  ContactType.github:
            
            openBrowser(url:contact.value)
            
        default:
            
            openBrowser(url:contact.value)
            
        }
        
    }
    
    
    private func openEmail(email:String){
        
        print("openEmail")
        
        if let url = URL(string: "mailto://\(email)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else{
            
            let userError=ErrorType.generalError(message: ErrorMessage.failToOpenEmail.rawValue)
            self.handleError(error: userError )
        }
        
        
        
    }
    
    private func call(phoneNo:String){
        
        print("call")
        
        if let url = URL(string: "tel://\(phoneNo)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else{
            
            let userError=ErrorType.generalError(message: ErrorMessage.failToOpenCall.rawValue)
            self.handleError(error: userError )
        }
        
    }
    
    private func openLinkedin(url:String){
        
        
        print("openLinkedin")
        
        // if url is not in a yourName-yourLastName-yourID format then just open in it browser
        if(url.contains("linkedin")){
            
            openBrowser(url: url)
            return
            
        }
        
        //the url shoule be in yourName-yourLastName-yourID format
        let webURL = URL(string: "https://www.linkedin.com/in/"+url)!
        
        let appURL = URL(string: "linkedin://profile/"+url)!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    private func openBrowser(url:String){
        
        print("openBrowser")
        
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else{
            
            let userError=ErrorType.generalError(message: ErrorMessage.failToOpenBrowser.rawValue)
            self.handleError(error: userError )
        }
        
    }
    
    @objc override func printClicked(sender: UIButton) {
        
        self.printTableViewAsPDF(tableView:self.contactTableView)
        
    }
    
}
