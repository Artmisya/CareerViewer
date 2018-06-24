//
//  WorkExperienceViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import RxSwift
import RxCocoa

class WorkExperienceViewController: BaseViewController {
    
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet var workExperienceTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    private let ROWHEIGHT:CGFloat=169.0
    private let resume=Resume()
    private let disposeBag = DisposeBag()
    
    private var dataSource:Variable<[WorkExperience]>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUpUi()
        setUpClickActions()
        
        configureTableView()
        
        loadWorkExperience()
        
        
    }
    
    private func loadWorkExperience(){
        
        loadingView.startAnimating()
        
        
        let cuncurrentQueue = ConcurrentDispatchQueueScheduler(queue:
            DispatchQueue.global(qos:.utility))
        let mainQueue = SerialDispatchQueueScheduler(queue: DispatchQueue.main, internalSerialQueueName: "main")
        
        resume.fetchWorkExperience()
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
            .addDisposableTo(disposeBag)
        
    }
    
    
    private func configureTableView(){
        
        workExperienceTableView.rowHeight = UITableViewAutomaticDimension
        workExperienceTableView.estimatedRowHeight = ROWHEIGHT
        
        let nib = UINib(nibName: "WorkExperienceCell", bundle: nil)
        workExperienceTableView.register(nib, forCellReuseIdentifier: "WorkExperienceCell")
    }
    
    
    private func setupUpUi(){
        
        self.title = "Work Experience"
        
        loadingView.hidesWhenStopped=true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh!")
        
    }
    
    private func setUpClickActions(){
        
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        workExperienceTableView.addSubview(refreshControl)
        
        // setting print button
        
        let btnName_print = UIButton()
        btnName_print .setImage(UIImage(named: "print"), for: .normal)
        btnName_print .frame = CGRectMake(0, 0, 30, 30)
        btnName_print .addTarget(self, action: #selector(self.printClicked), for: .touchUpInside)
        //.... Set Left Bar Button item
        let rightBarButton_print  = UIBarButtonItem()
        rightBarButton_print .customView = btnName_print
        self.navigationItem.rightBarButtonItem=rightBarButton_print
        
    }
    
    @objc func didPullToRefresh() {
        
        print ("didPullToRefresh")
        loadWorkExperience()
        
    }
    
    // load table view using a rxswift observer
    
    private func loadTableView(){
        
        // clear datasource delegate first
        workExperienceTableView.dataSource=nil
        
        //initialize the data source
        dataSource=Variable(resume.workExperienceList!)
        
        // making the bind
        dataSource?.asObservable().bind(to: workExperienceTableView.rx.items(cellIdentifier: "WorkExperienceCell")) { index, workExperinceObj,
            cell in
            if let workExperinceCell = cell as? WorkExperienceCell {
                
                workExperinceCell.roleLbl.text = workExperinceObj.role
                workExperinceCell.companyLbl.text = workExperinceObj.company
                workExperinceCell.durationLbl.text=workExperinceObj.duration
                workExperinceCell.descryptionLbl.text=workExperinceObj.descryption
                
                workExperinceCell.selectionStyle = .none
            }
            
            }.disposed(by: disposeBag)
        
    }
    
    @objc override func printClicked(sender: UIButton) {
        
        self.printTableViewAsPDF(tableView:self.workExperienceTableView)
        
    }
}
