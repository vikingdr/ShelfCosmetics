//
//  FollowersVC.swift
//  Shelf
//
//  Created by Matthew James on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class FollowersVC: UIViewController {
    @IBOutlet var tblfollowers : UITableView!

    fileprivate var shouldLoadNextPage = false
 
    //----------------------------------------------------------
    // MARK: - View Life cycle methods
    //----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldLoadNextPage = SFollow.currentFollowers().count < SFollow.currentFollowersCount()
        
        tblfollowers.register(UINib(nibName: kLoadingMoreCellIdentifier, bundle: nil), forCellReuseIdentifier: kLoadingMoreCellIdentifier)
        tblfollowers.backgroundColor = UIColor.clear
        tblfollowers.backgroundView = nil
        tblfollowers.dataSource = self
        tblfollowers.delegate = self
        
        // Do any additional setup after loading the view.
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblfollowers.reloadData()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        //Registation_logo
        let titleView:UIImageView = UIImageView(image: UIImage(named: ""))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 35.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 21))
        label.center = CGPoint(x: 160, y: 50)
        label.textAlignment = NSTextAlignment.center
        label.text = "Followers"
        label.textColor=UIColor.white;
        //label.font = label.font.fontWithSize(20)
        label.font = UIFont (name: "Avenir-Heavy", size: 18)
        self.navigationItem.titleView=label

        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(FollowersVC.backPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
    }
    
    //----------------------------------------------------------
    // MARK: - Gestures
    //----------------------------------------------------------
    func profileTapped(_ gr: UITapGestureRecognizer) {
        if let row = gr.view?.tag {
            let followers = SFollow.currentFollowers()
            let followTuple = followers[row]
            if let follow = followTuple.follow {
                do {
                    try follow.fromUser!.fetchIfNeeded()
                } catch {
                    
                }
                let sUser = SUser(dataUser: follow.fromUser!)
                transitionToProfile(sUser)
            }
        }
    }
    
    fileprivate func updateFromUser( _ row : Int, cell : FollowCell) {
        let followers = SFollow.currentFollowers()
        let followTuple = followers[row]
        if let follow = followTuple.follow {
            cell.updateCellWithUser(follow.fromUser, isFollowing: followTuple.following)
            cell.followActionAlias = followActionAlias
        }
    }
    
    fileprivate func loadNextPage() {
        let page = SFollow.currentFollowersPages()[SFollow.currentFollowersPages().count - 1] + 1
        SFollow.updateFollowers(page, itemsPerPage: kItemsPerPage,  completion: { (success: Bool, shouldLoadNextPage: Bool) in
            self.shouldLoadNextPage = shouldLoadNextPage
            guard success == true else {
                return
            }
            
            let start = page * kItemsPerPage
            var end = start + kItemsPerPage
            if end > SFollow.currentFollowersCount() {
                end = SFollow.currentFollowersCount()
            }
            
            var insertIndexPaths = [IndexPath]()
            if end > start {
                for index in start..<end {
                    if index == start {
                        if self.shouldLoadNextPage {
                            insertIndexPaths.append(IndexPath(row: index, section: 0))
                        }
                    } else {
                        insertIndexPaths.append(IndexPath(row: index, section: 0))
                    }
                }
            }
            
            self.tblfollowers.beginUpdates()
            if !self.shouldLoadNextPage {
                self.tblfollowers.reloadRows(at: [IndexPath(row: start, section: 0)], with: .none)
            }
            self.tblfollowers.insertRows(at: insertIndexPaths, with: .none)
            self.tblfollowers.endUpdates()
        })
    }
    
    //----------------------------------------------------------
    // MARK: - Typealias
    //----------------------------------------------------------
    func followActionAlias(_ success: Bool, followAction: FollowAction) {
        guard success == false else {
            // Network calls were successful, do nothing
            return
        }
        
        let title = followAction == .follow ? "Follow User Error" : "Unfollow User Error"
        let message = followAction == .follow ? "Unable to follow user, please try again." : "Unable to unfollow user, please try again."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension FollowersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = SFollow.currentFollowers().count
        if shouldLoadNextPage {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < SFollow.currentFollowers().count {
            let cell = tableView.dequeueReusableCell(withIdentifier: kFollowCellIdentifier, for: indexPath) as! FollowCell
            cell.btnAdd.isSelected = false
            cell.vc = self
            updateFromUser(indexPath.row, cell: cell)
            cell.imgProfile.tag = indexPath.row
            cell.imgProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FollowersVC.profileTapped(_:))))
            cell.labelUsername.tag = indexPath.row
            cell.labelUsername.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FollowersVC.profileTapped(_:))))
            
            cell.backgroundColor = UIColor.clear
            
            if indexPath.row == SFollow.currentFollowers().count-1 {
                cell.seperatorView.isHidden = true
            }
            
            return cell
        }
        // Return LoadingMoreCell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLoadingMoreCellIdentifier, for: indexPath) as! LoadingMoreCell
            
            return cell
        }
    }
}

extension FollowersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == SFollow.currentFollowers().count - 1 {
            if shouldLoadNextPage {
                loadNextPage()
            }
        }
    }
}
