//
//  MyBandsViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 3/15/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import DropDown
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MyBandsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, DismissalDelegate  {
    
    @IBOutlet weak var bandTypeView: UIView!
    @IBOutlet weak var myBandsCollectionView: UICollectionView!

    @IBOutlet weak var myONBCollectionView: UICollectionView!
    @IBOutlet weak var createNewBandButton: UIButton!
    @IBOutlet weak var bandTypePicker: UIPickerView!
    @IBAction func createNewBandPressed(_ sender: Any) {
        dropDown.show()
        bandTypeView.isHidden = false
        dropDownDone = false
        createNewBandButton.isHidden = true
        
        

    }
    let ref = FIRDatabase.database().reference()
    let dropDown = DropDown()
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.cancelAction = {[unowned self] () in
            self.bandTypeView.isHidden = true
            self.createNewBandButton.isHidden = false
        }
        bandTypeView.isHidden = true
        loadCollectionViews()
        bandTypePicker.delegate = self
        bandTypePicker.dataSource = self
        
       // bandTypePicker.selectRow(0, inComponent: 1, animated: false)
        
        createNewBandButton.layer.cornerRadius = 10
        createNewBandButton.layer.masksToBounds = true
        
        bandTypePicker.delegate = self
        
        //dropDownMenu Stuff
       
        dropDown.selectionBackgroundColor = UIColor.orange.withAlphaComponent(0.4)
        dropDown.anchorView = self.createNewBandButton//collectionView.cellForItem(at: indexPath)
        dropDown.dataSource = ["Create New Band","Create New OneNightBand"]
        
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            if index == 0{
                self.bandTypeView.isHidden = true
                let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateBandViewController") as! CreateBandViewController
                self.addChildViewController(popOverVC)
                popOverVC.view.frame = self.view.frame
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParentViewController: self)
                self.dropDownDone = true
                self.createNewBandButton.isHidden = false
                
            }
            else {
                print("OneNightBand")
                self.bandTypeView.isHidden = true
                self.dropDownDone = true
                self.createNewBandButton.isHidden = false
            }
            
            
        }
        dropDown.direction = .top
        //dropDown.selectRow(at: 1)
        dropDown.backgroundColor = UIColor.orange.withAlphaComponent(0.6)
        dropDown.textColor = UIColor.white.withAlphaComponent(0.8)
        
        

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var createNewONBH: UILabel!
    @IBOutlet weak var CreateNewBandH: UILabel!
    var bandArray = [Band]()
    var bandIDArray = [String]()
    var ONBArray = [Band]()
    var bandsDict = [String: Any]()
    var sizingCell: SessionCell?
    func loadCollectionViews(){
        bandArray.removeAll()
        ONBArray.removeAll()
        navigationItem.title = "Your Bands"
        myBandsCollectionView.isHidden = false
        myONBCollectionView.isHidden = true
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        self.ref.child("bands").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let dictionary = snap.value as? [String: Any]
                    let tempBand = Band()
                    tempBand.setValuesForKeys(dictionary!)
                    self.bandArray.append(tempBand)
                    self.bandsDict[tempBand.bandID!] = tempBand
                }
            }
            
            self.ref.child("users").child(userID!).child("artistsBands").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        self.bandIDArray.append((snap.value! as! String))
                    }
                }
                
                
                        
                        
                        DispatchQueue.main.async {
                            for _ in self.bandIDArray{
                                
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.myBandsCollectionView.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                self.myBandsCollectionView.backgroundColor = UIColor.clear
                                self.myBandsCollectionView.dataSource = self
                                self.myBandsCollectionView.delegate = self
                            }
                            
                        }
                
                        
                    })
                    
                    
                })
        
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    var ONBIDArray = [String]()
    var tempIndex = Int()
    var pressedButton = String()
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MyBandsToSessionMaker" {
            if let viewController = segue.destination as? SessionMakerViewController {
                viewController.sessionID = self.bandIDArray[tempIndex]
                if(self.pressedButton == "band"){
                    viewController.sessionID = self.bandIDArray[tempIndex]
                }
                if(self.pressedButton == "ONB"){
                    viewController.sessionID = self.ONBIDArray[tempIndex]
                }
            }
        }

        
    }
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.bandIDArray.count
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as! SessionCell
        tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((bandsDict[bandIDArray[indexPath.row]] as! Band).bandPictureURL[0])
        //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
        tempCell.sessionCellLabel.text = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandName
        tempCell.sessionCellLabel.textColor = UIColor.white
        tempCell.sessionId = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandID

        return tempCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
       // if(self.collectionView == myBandsCollectionView){
            if self.bandIDArray.count != 1{
                return UIEdgeInsetsMake(0, 0, 0, 0)
            }else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.bandIDArray.count)
                let totalSpacingWidth = 10 * (self.bandIDArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        /*} else{
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }*/
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.myBandsCollectionView){
            tempIndex = indexPath.row
            if collectionView == self.myBandsCollectionView {
                self.pressedButton = "band"
            }else{
                self.pressedButton = "ONB"
            }
            performSegue(withIdentifier: "MyBandsToSessionMaker", sender: self)
        }
        
        
    }


    
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    // returns the # of rows in each component..
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 2
        
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if row == 0{
            self.myBandsCollectionView.isHidden = false
            self.myONBCollectionView.isHidden = true
        } else{
            self.myBandsCollectionView.isHidden = true
            self.myONBCollectionView.isHidden = false

        }
    }
    
    var menuText = ["Your Bands","Your OneNightBands"]
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = menuText[row]
        
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    
    func finishedShowing(viewController: UIViewController) {
        //if viewController.isBeingPresented && viewController.presentingViewController == self
        //{
        //self.shadeView.isHidden = true
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
        
        self.dismiss(animated: true, completion: nil)
        return
        //}
        
        // self.navigationController?.popViewController(animated: true)
    }
    var dropDownDone: Bool?

    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bandTypeView.isHidden == false && dropDownDone == false{
            bandTypeView.isHidden = true
            dropDownDone = true
        }
        
    }*/

    


    


}
