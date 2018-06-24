//
//  EducationViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class EducationViewController: BaseViewController {
    
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet var educationTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    private let ROWHEIGHT:CGFloat=169.0
    private let resume=Resume()
    private let disposeBag = DisposeBag()
    private var dataSource:Variable<[Education]>?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUpUi()
        setUpClickActions()
        
        configureTableView()
        
        
        loadEducation()
        
        print("going to load loadEducation")
        
    }
    
    private func loadEducation(){
        
        loadingView.startAnimating()
        
        let cuncurrentQueue = ConcurrentDispatchQueueScheduler(queue:
            DispatchQueue.global(qos:.utility))
        
        let mainQueue = SerialDispatchQueueScheduler(queue: DispatchQueue.main, internalSerialQueueName: "main")
        
        resume.fetchEducation()
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
                    
                    print("onCompleted")
                    self.loadingView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        
        //        resume.fetchEducation().subscribe(
        //
        //            onNext: {
        //
        //                //successfully get data
        //                self.loadTableView()
        //        },
        //            onError: { error in
        //
        //                //an error happend while geting data
        //                self.handleError(error: error as! ErrorType)
        //
        //                self.loadingView.stopAnimating()
        //                self.refreshControl.endRefreshing()
        //
        //        },
        //            onCompleted: {
        //
        //                print("onCompleted")
        //                self.loadingView.stopAnimating()
        //                self.refreshControl.endRefreshing()
        //
        //        }, onDisposed: nil)
        //            .addDisposableTo(disposeBag)
        
        
    }
    
    
    private func configureTableView(){
        
        
        educationTableView.rowHeight = UITableViewAutomaticDimension
        educationTableView.estimatedRowHeight = ROWHEIGHT
        
        let nib = UINib(nibName: "EducationCell", bundle: nil)
        educationTableView.register(nib, forCellReuseIdentifier: "EducationCell")
    }
    
    
    private func setupUpUi(){
        
        self.title="Education"
        
        loadingView.hidesWhenStopped=true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh!")
        
    }
    
    private func setUpClickActions(){
        
        
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        educationTableView.addSubview(refreshControl)
        
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
    
    @objc func didPullToRefresh() {
        
        print ("didPullToRefresh")
        loadEducation()
        
    }
    
    // load table view using a rxswift observer
    
    private func loadTableView(){
        
        // clear datasource delegate first
        educationTableView.dataSource=nil
        
        //initialize the data source
        dataSource=Variable(resume.educationList!)
        
        // making the bind
        dataSource?.asObservable().bind(to: educationTableView.rx.items(cellIdentifier: "EducationCell")) { index, educationObj,
            cell in
            if let educationCell = cell as? EducationCell {
                
                educationCell.degreeLevelLbl.text = educationObj.degree
                educationCell.universityLbl.text = educationObj.university
                educationCell.AvgLbl.text=educationObj.avg
                educationCell.durationLbl.text=educationObj.duration
                
                cell.selectionStyle = .none
            }
            
            }.disposed(by: disposeBag)
        
    }
    
    @objc override func printClicked(sender: UIButton) {
        
        self.printTableViewAsPDF(tableView:self.educationTableView)
        
    }
}
