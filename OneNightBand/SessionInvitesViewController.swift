//
//  SessionInvitesViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/25/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class SessionInvitesViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    var invitePageViewController: UIPageViewController!
    var inviteArray = [Invite]()
    var snapKey = [String: Any]()
    
    
   let emptyLabel: UILabel = {
        var tempLabel = UILabel()
        tempLabel.text = "You have 0 pending invites"
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightLight)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    
    }()
    func setupEmptyLabel(){
        emptyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    
    
    
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.view.addSubview(emptyLabel)
        setupEmptyLabel()
        emptyLabel.isHidden = true
        
        
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("users").child(currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount != 0{
                self.emptyLabel.isHidden = true
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                //var index = 0
                
                for snap in snapshots{
                    
                    if let dictionary = snap.value as? [String: Any] {
                        
                        //self.snapKey = dictionary
                        let invite = Invite()
                        invite.setValuesForKeys(dictionary)
                        self.inviteArray.append(invite)
                        //print(dictionary)
                    
                    }
                }
                }
            self.invitePageViewController = self.storyboard?.instantiateViewController(withIdentifier: "UITutorialPageViewController") as! UIPageViewController
            self.invitePageViewController.dataSource = self
            self.invitePageViewController.delegate = self

        
                let initialContentViewController = self.pageTutorialAtIndex(0) as InviteViewData
                var viewControllers = [InviteViewData]()
                viewControllers = [initialContentViewController]
                    
                
                self.invitePageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                //making pageView only take up top half of screen
                self.invitePageViewController.view.frame.size.height = self.view.frame.size.height
                //adding subview
                self.addChildViewController(self.invitePageViewController)
                self.view.addSubview(self.invitePageViewController.view)
                self.invitePageViewController.didMove(toParentViewController: self)
                self.invitePageViewController.gestureRecognizers.first?.cancelsTouchesInView = false
            }else{
                self.emptyLabel.isHidden = false
            }

        })
    
    }
    
    //PageController Functions
    func pageTutorialAtIndex(_ index: Int) ->InviteViewData{        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "InviteViewData") as! InviteViewData
        if(presentationCount(for: self.invitePageViewController) != 0){
            pageContentViewController.pageIndex = index
            pageContentViewController.inviteSenderText = self.inviteArray[index].sender
            pageContentViewController.sessionNameText = self.inviteArray[index].sessionID
            pageContentViewController.instrumentNeededText = self.inviteArray[index].instrumentNeeded
            pageContentViewController.dateText = self.inviteArray[index].sessionDate            
        }
        
        return pageContentViewController
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! InviteViewData
        var index = viewController.pageIndex! as Int
        if(index == 0 || index == NSNotFound){
            return nil
        }
        index -= 1
        return self.pageTutorialAtIndex(index)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! InviteViewData
        var index = viewController.pageIndex! as Int
        
        if(index == (inviteArray.endIndex) - 1 || index == NSNotFound){
            return nil
        }
        index += 1
        if(index == inviteArray.count){
            return nil
        }
        return self.pageTutorialAtIndex(index)
    }
    
    open func presentationCount(for pageViewController: UIPageViewController) -> Int{
        
        return inviteArray.count //inviteArray.count
        
    }
    
    open func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        return 0
    }

    
}
