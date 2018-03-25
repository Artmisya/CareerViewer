//
//  OverviewViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//


import UIKit
import RxSwift

class OverviewViewController: BaseViewController {
    
    @IBOutlet var closeWarningImage: UIImageView!
    @IBOutlet var warningView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var descryptionTxt: UITextView!
    
    
    private let disposeBag = DisposeBag()
    private let resume=AppDelegate.resume
    private let refreshControl = UIRefreshControl()
    private var isOfflineMode:Bool=false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUpUi()
        setUpClickActions()
        
        loadOverview()
    }

    private func loadOverview() {
        
        loadingView.startAnimating()
        resume.fetchOverview().subscribe(
            
            onNext :{ isOfflineMode in
                
                //successfully get data from API
                self.isOfflineMode=isOfflineMode
                self.assignDataToUi()
        },
            onError: { error in
                
                //an error happend while geting data from API
                print(error.localizedDescription)
                
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.handleError(error: error as! ErrorType)
                
        },
            onCompleted: {
                
                print("onCompleted")
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                
        }, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
    private func assignDataToUi(){
        
        print ("assignDataToUi")
        
        // just to make sure
        if resume.overview==nil{
            
            return
        }
        
        nameLbl.text=resume.overview?.name
        descryptionTxt.text=resume.overview?.descryption
        
        guard let imageData = resume.overview?.image as? Data else{
            return
        }
        profileImage.image=UIImage(data: imageData)
        
        // if it is aoffline mode show the offline warning message after a delay of 2 second
        
        if (isOfflineMode){
            
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                UIView.transition(with: self.warningView, duration: 1.7, options: .transitionCurlDown, animations: {
                    self.warningView.isHidden = false
                })
            }
        }
        else{
            
            warningView.isHidden=true
        }
        
    }
    
    private func setupUpUi(){
        
        self.title="Overview"
        
        loadingView.hidesWhenStopped=true
        
        self.scrollView.isScrollEnabled = true
        self.scrollView.alwaysBounceVertical = true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh!")
        
        warningView.backgroundColor=UIColor(colorLiteralRed: 170/225, green: 170/255, blue: 170/255, alpha: 0.57)
        
        self.profileImage.layer.cornerRadius = 23.0
        self.profileImage.clipsToBounds = true
        
        
    }
    
    private func setUpClickActions(){
        
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        
        closeWarningImage.isUserInteractionEnabled=true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.closeWarningTapped(recognizer:)))
        closeWarningImage.addGestureRecognizer(tapGesture)
        
        warningView.isUserInteractionEnabled=true
        let swapGesture=UISwipeGestureRecognizer(target: self, action: #selector(self.closeWarningTapped(recognizer:)))
        swapGesture.direction=UISwipeGestureRecognizerDirection.left
        warningView.addGestureRecognizer(swapGesture)
        
        
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
    
    func didPullToRefresh() {
        
        loadOverview()
        
    }
    
    func closeWarningTapped(recognizer:UITapGestureRecognizer){
        
        UIView.transition(with: warningView, duration: 0.5, options: .transitionCurlUp, animations: {
            self.warningView.isHidden = true
        })
        
    }
    


}
