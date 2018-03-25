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
    private let resume=AppDelegate.resume
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
        resume.fetchWorkExperience().subscribe(
            
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
        
        
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        workExperienceTableView.addSubview(refreshControl)
        
    }
    
    func didPullToRefresh() {
        
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
            
            }.addDisposableTo(disposeBag)
        
    }
    
    
}