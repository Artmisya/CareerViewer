//
//  SkillViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SkillViewController: BaseViewController,UISearchBarDelegate{
    
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet var skillTableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    private let ROWHEIGHT:CGFloat=169.0
    private let resume=AppDelegate.resume
    private let disposeBag = DisposeBag()
    
    private var dataSource:Variable<[Skill]>?
    private var filterDataSource:Variable<[Skill]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUpUi()
        setUpClickActions()
        
        configureTableView()
        
        loadSkill()
        
        createSearchObserver()
        
        
        
    }
    
    private func loadSkill(){
        
        loadingView.startAnimating()
        resume.fetchSkills().subscribe(
            
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
    
    
    private func setupUpUi(){
        
        self.title="Skills"
        loadingView.hidesWhenStopped=true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh!")
        
    }
    
    private func setUpClickActions(){
        
        
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        skillTableView.addSubview(refreshControl)
        
        view.isUserInteractionEnabled=true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(recognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        searchBar.delegate=self
        
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
        
        skillTableView.rowHeight = UITableViewAutomaticDimension
        skillTableView.estimatedRowHeight = ROWHEIGHT
        
        let nib = UINib(nibName: "SkillCell", bundle: nil)
        skillTableView.register(nib, forCellReuseIdentifier: "SkillCell")
    }
    
    
    func didPullToRefresh() {
        
        print ("didPullToRefresh")
        searchBar.text=""
        loadSkill()
        
    }
    
    
    // load table view using a rxswift observer
    
    private func loadTableView(){
        
        // clear datasource delegate first
        skillTableView.dataSource=nil
        
        //initialize the data source
        dataSource=Variable(resume.skillList!)
        filterDataSource=Variable(resume.skillList!)
        
        // making the bind
        filterDataSource?.asObservable().bind(to: skillTableView.rx.items(cellIdentifier: "SkillCell")) { index, skillObj,
            cell in
            if let skillCell = cell as? SkillCell {
                
                skillCell.titleLbl.text = skillObj.title
                
                skillCell.skillRateSlider.value=(skillObj.rate as NSString).floatValue
                
                skillCell.selectionStyle = .none
            }
            
            }.addDisposableTo(disposeBag)
        
    }
    
    // this method makes a rxswift observer over the search bar and enable search bar to filter skills based on search query
    
    private func createSearchObserver(){
        
        searchBar.rx.text.asObservable().subscribe(onNext: {
            (searchText) in
            
            self.filterDataSource?.value = self.dataSource!.value.filter({
                
                // if search text is empty no need filter
                if (searchText?.isEmpty)! {return true}
                
                return $0.title.lowercased().contains((searchText?.lowercased())!)
                
            })
            
        }).addDisposableTo(disposeBag)
        
    }
    
    // dismiss keyboard when user click on search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchBar.endEditing(true)
        
    }
    
    // dismiss keyboard when user tab on the view
    func viewTapped(recognizer: UITapGestureRecognizer){
        
        print ("viewTapped")
        self.searchBar.endEditing(true)
        
    }
    
}
