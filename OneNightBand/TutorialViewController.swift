//
//  TutorialViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/2/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import DropDown


class TutorialViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate{
    
    let TAGS = ["Guitar", "Bass Guitar", "Piano", "Saxophone", "Trumpet", "Stand-up Bass", "violin", "Drums", "Cello", "Trombone", "Vocals", "Mandolin", "Banjo", "Harp"]
    var sizingCell: TagCell?
    var tags = [Tag]()
    var pageTexts = [String]()
    var pageViewController: UIPageViewController!
    var currentIndex = 0
    var selectedCount = 0
    let dropDown = DropDown()
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        startExploringButton.isHidden = true
        if(currentIndex == 0){
            self.collectionView.isHidden = false
            self.editBioTextView.isHidden = true
            currentIndex += 1
            
        }
        else{
            self.collectionView.isHidden = true
            self.editBioTextView.isHidden = false
            currentIndex -= 1
        }

        continueButton.isHidden = false
        let skillsViewController = self.pageTutorialAtIndex(0) as AboutONBViewController
        var viewControllers = [AboutONBViewController]()
        
        
        
        viewControllers = [skillsViewController]
        
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
        
        //making pageView only take up top half of screen
        //self.pageViewController.view.frame.size.height = self.view.frame.size.height/2
        //adding subview
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        
        backButton.isHidden = true
        //currentIndex = 0

        
    }
    
    @IBOutlet weak var continueButton: UIButton!
    @IBAction func continueSelected(_ sender: AnyObject) {
        //startExploringButton.isHidden = false
        if(currentIndex == 0){
            self.collectionView.isHidden = false
            self.editBioTextView.isHidden = true
            currentIndex += 1
        }
        else{
            self.collectionView.isHidden = true
            self.editBioTextView.isHidden = false
            currentIndex -= 1
        }
        if(selectedCount != 0 && editBioTextView.text != "Tap here to edit your artist bio!"){
            startExploringButton.isEnabled = true
            startExploringButton.isHidden = false
            startExploringButton.titleLabel?.text = "Start Exploring!"
        }else{
            startExploringButton.isEnabled = false
            startExploringButton.isHidden = true
            startExploringButton.titleLabel?.text = "Fill Out Missing Info to Continue"
        }
        
        

        
        

        continueButton.isHidden = true
        let bioViewController = self.pageTutorialAtIndex(1) as AboutONBViewController
        var viewControllers = [AboutONBViewController]()
        viewControllers = [bioViewController]
        
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        //making pageView only take up top half of screen
        //self.pageViewController.view.frame.size.height = self.view.frame.size.height/2
        //adding subview
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        backButton.isHidden = false
        //currentIndex = 1
        
    }
    @IBOutlet weak var editBioTextView: UITextView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startExploringButton: UIButton!
    
    var mostRecentTagTouched = IndexPath()
    override func viewDidLoad(){
        super.viewDidLoad()
        
        backButton.isHidden = true
        continueButton.isHidden = false
        startExploringButton.isHidden = true
        startExploringButton.isEnabled = false
        
        self.editBioTextView.delegate = self
        self.editBioTextView.isHidden = true
        editBioTextView.text = "Tap here to edit your artist bio!"
        editBioTextView.textColor = UIColor.orange
        //editBioTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -10).isActive = true
        //editBioTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 10).isActive = true
       
        //let dropDown = DropDown()
        
        dropDown.selectionBackgroundColor = UIColor.orange.withAlphaComponent(0.4)
        dropDown.anchorView = self.view//collectionView.cellForItem(at: indexPath)
        dropDown.dataSource = ["1","2","3","4","5"]
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.tagsAndSkill[self.TAGS[self.mostRecentTagTouched.row]] = index + 1
            self.dropDown.selectRow(at: index)
            //self.dropDown.selectRow(at: 2)
            self.dropDown.hide()
        }
        dropDown.direction = .top
        dropDown.selectRow(at: 2)
        dropDown.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dropDown.textColor = UIColor.white.withAlphaComponent(0.8)
        

        
        //initializing TagCell and creating a cell for each item in array TAGS
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.collectionView.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        for name in TAGS {
            let tag = Tag()
            tag.name = name
            self.tags.append(tag)
        }

        pageTexts = ["What Instrument(s) are you best with? Only select an instrument if you feel comfortable enough playing it with other musicians in a jam environment.","Add a little bio about your musical style and background so other musicians have a good feel of your playing style."]
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "UITutorialPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        //initializing first aboutONBViewController
        let initialContentViewController = self.pageTutorialAtIndex(0) as AboutONBViewController
        var viewControllers = [AboutONBViewController]()
        viewControllers = [initialContentViewController]
        currentIndex += 1
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
       
        //making pageView only take up top half of screen
        self.pageViewController.view.frame.size.height = self.view.frame.size.height/2
        //adding subview
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        pageViewController.view.isUserInteractionEnabled = false
        /*self.collectionView.isHidden = false
        self.editBioTextView.isHidden = true*/
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if editBioTextView.textColor == UIColor.orange {
            editBioTextView.text = nil
            editBioTextView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if editBioTextView.text.isEmpty {
            editBioTextView.text = "Tap here to edit your artist bio!"
            editBioTextView.textColor = UIColor.orange
        }
        /*for tag in tags{
            if(tag.selected == true){
                selectedCount+=1
            }
        }*/
        if(selectedCount != 0 && editBioTextView.text != "Tap here to edit your artist bio!"){
            startExploringButton.isHidden = false
            startExploringButton.isEnabled = true
            startExploringButton.titleLabel?.text = "Start Exploring?"
        }else{
            startExploringButton.isHidden = true
            startExploringButton.isEnabled = false
            startExploringButton.titleLabel?.text = "Fill Out Missing Info to Continue"
        }

    }
    //CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath as IndexPath) as! TagCell
        self.configureCell(cell, forIndexPath: (indexPath as NSIndexPath) as IndexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(self.sizingCell!, forIndexPath: (indexPath as NSIndexPath) as IndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    var tagsAndSkill = [String: Int]()
    //var instrumentDict = [String: Any]()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let dropDown = Drop
        self.mostRecentTagTouched = indexPath
        if(tags[indexPath.row].selected == true){
            selectedCount -= 1
            tagsAndSkill.removeValue(forKey: TAGS[indexPath.row])
        }else{
            selectedCount += 1
            dropDown.show()

            //self.dropDown.anchorView
        }
        
        collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        self.collectionView.reloadData()
    }
    
    func configureCell(_ cell: TagCell, forIndexPath indexPath: IndexPath) {
        let tag = tags[(indexPath as NSIndexPath).row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = tag.selected ? UIColor.white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        cell.backgroundColor = tag.selected ? UIColor.orange : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
    
    
    //PageController Functions
    func pageTutorialAtIndex(_ index: Int) ->AboutONBViewController{
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialContentHolder") as! AboutONBViewController
        pageContentViewController.tutorialText = pageTexts[index]
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        
        let viewController = viewController as! AboutONBViewController
        var index = viewController.pageIndex! as Int
        
        if(index == 0 || index == NSNotFound){
            return nil
        }
        
        index -= 1
        currentIndex -= 1
        return self.pageTutorialAtIndex(index)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! AboutONBViewController
        var index = viewController.pageIndex! as Int
        if(index == pageTexts.endIndex - 1 || index == NSNotFound){
            return nil
        }
        index += 1
        currentIndex += 1
        if(index == pageTexts.count){
            return nil
        }
        return self.pageTutorialAtIndex(index)
    }
    
    open func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return pageTexts.count
    }
    
    open func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        if currentIndex == 1{
            return 0
        }
        else{
            return 1
        }
    }
    
    
    // Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        guard completed else { return }
        if(currentIndex == 0){
            self.collectionView.isHidden = false
            self.editBioTextView.isHidden = true
            currentIndex += 1
        }
        else{
            self.collectionView.isHidden = true
            self.editBioTextView.isHidden = false
            currentIndex -= 1
        }
    }
    
    @IBAction func startExploringButtonPressed(_ sender: AnyObject) {
        
        
        var tagArray = [String]()
        for tag in tags{
            if(tag.selected == true){
                tagArray.append(tag.name!)
                selectedCount+=1
            }

        }
        if(selectedCount != 0 && editBioTextView.text != nil){
            //startExploringButton.isHidden = false
            //startExploringButton.isEnabled = true
        

        if let user = FIRAuth.auth()?.currentUser?.uid{
            let ref = FIRDatabase.database().reference()
            let userRef = ref.child("users").child(user)
            var dict = [String: Any]()
            dict["instruments"] = tagsAndSkill 
            dict["bio"] = editBioTextView.text as Any?
            userRef.updateChildValues(dict, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err as Any)
                    return
                }
            })
            

            
        }else{
            //need to sign them out
            return
        }
        

        //successfully authenticate user
        /*else{
         print("Account Created")
         self.performSegue(withIdentifier: "AboutONBSegue", sender: self)
         }*/
        //var ref: FIRDatabaseReference!
        //ref = FIRDatabase.database().reference()
        
        }
        else{
            print("invalid form")
        }
    }


}
