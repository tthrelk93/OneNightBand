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

class MyBandsViewController: UIViewController, DismissalDelegate, UINavigationControllerDelegate {
    var sender = String()
    @IBOutlet weak var bandTypeView: UIView!
   
    var wantedAd = WantedAd()
    @IBOutlet weak var createNewBandButton: UIButton!
    
    @IBOutlet weak var createNewONBButton: UIButton!
    @IBAction func createNewONBPressed(_ sender: Any) {
        self.bandTypeView.isHidden = true
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateOneNightBandViewController") as! CreateOneNightBandViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        popOverVC.destination = self.destination
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.wantedAd = self.wantedAd
        popOverVC.dismissalDelegate = self
        self.createNewBandButton.isHidden = false

        
    }
    @IBAction func createNewBandPressed(_ sender: Any) {
        self.bandTypeView.isHidden = true
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateBandViewController") as! CreateBandViewController
        self.addChildViewController(popOverVC)
        popOverVC.destination = self.destination
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.dismissalDelegate = self
        popOverVC.wantedAd = self.wantedAd
        
        self.createNewBandButton.isHidden = false

        

    }
   // @IBOutlet weak var noCurrentONBLabel: UILabel!
   // @IBOutlet weak var noCurrentBandsLabel: UILabel!
    let ref = FIRDatabase.database().reference()
   
    
       override func viewDidLoad() {
        super.viewDidLoad()
       
        //navigationController.is
        navigationItem.hidesBackButton = false
        navigationController?.isNavigationBarHidden = false
        
        bandTypeView.isHidden = false
        
        
        
       // bandTypePicker.selectRow(0, inComponent: 1, animated: false)
        
        createNewBandButton.layer.cornerRadius = 10
        createNewBandButton.layer.masksToBounds = true
        createNewONBButton.layer.cornerRadius = 10
        createNewONBButton.layer.masksToBounds = true
        
       
        
        //dropDownMenu Stuff
       let ONBPink = UIColor(colorLiteralRed: 201.0/255.0, green: 38.0/255.0, blue: 92.0/255.0, alpha: 1.0)
      
        
        
            
        }
    
            /*print("sender: \(self.sender)")
            if self.sender == "pfm"{
                
                self.createNewBandPressed(self)
           
            }*/
       
        
        
        

        // Do any additional setup after loading the view.
    var destination = String()
    
    @IBOutlet weak var createNewONBH: UILabel!
    @IBOutlet weak var CreateNewBandH: UILabel!
    var bandArray = [Band]()
    var bandIDArray = [String]()
    var ONBArray = [Band]()
    var bandsDict = [String: Any]()
    var sizingCell: SessionCell?
    var onbArray = [ONB]()
    var onbDict = [String: Any]()
    var onbIDArray = [String]()
    
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
                viewController.sender = "myBands"

            }
        } else {
            if let viewController = segue.destination as? OneNightBandViewController {
                viewController.onbID = self.onbIDArray[tempIndex]
            }
        }

        
    }
    /*
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if collectionView == myBandsCollectionView{
            return self.bandIDArray.count
        }
        else{
            return self.onbIDArray.count
        }
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as! SessionCell
        if collectionView == myBandsCollectionView{
            tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((bandsDict[bandIDArray[indexPath.row]] as! Band).bandPictureURL[0])
        //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
            tempCell.sessionCellLabel.text = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandName
            tempCell.sessionCellLabel.textColor = UIColor.white
            tempCell.sessionId = (bandsDict[bandIDArray[indexPath.row]] as! Band).bandID
        }
        else {
            tempCell.sessionCellImageView.loadImageUsingCacheWithUrlString((onbDict[onbIDArray[indexPath.row]] as! ONB).onbPictureURL[0])
            //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
            tempCell.sessionCellLabel.text = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbName
            tempCell.sessionCellLabel.textColor = UIColor.white
            tempCell.sessionId = (onbDict[onbIDArray[indexPath.row]] as! ONB).onbID
        }

        return tempCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if(collectionView == myBandsCollectionView){
            if self.bandIDArray.count != 1{
                return UIEdgeInsetsMake(0, 0, 0, 0)
            }else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.bandIDArray.count)
                let totalSpacingWidth = 10 * (self.bandIDArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        }
         else{
            if self.onbIDArray.count != 1{
                return UIEdgeInsetsMake(0, 0, 0, 0)
            }else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.onbIDArray.count)
                let totalSpacingWidth = 10 * (self.onbIDArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }

        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.myBandsCollectionView){
            tempIndex = indexPath.row
                performSegue(withIdentifier: "MyBandsToSessionMaker", sender: self)
        } else{
            tempIndex = indexPath.row
            performSegue(withIdentifier: "MyBandsToONB", sender: self)
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
            if myBandsCollectionView.visibleCells.count == 0{
                self.noCurrentBandsLabel.isHidden = false
                self.noCurrentONBLabel.isHidden = true
            } else {
                self.noCurrentBandsLabel.isHidden = true
                self.noCurrentONBLabel.isHidden = true
            }
            self.myBandsCollectionView.isHidden = false
            self.myONBCollectionView.isHidden = true
        } else{
            if myONBCollectionView.visibleCells.count == 0{
                self.noCurrentBandsLabel.isHidden = true
                self.noCurrentONBLabel.isHidden = false
            } else {
                self.noCurrentBandsLabel.isHidden = true
                self.noCurrentONBLabel.isHidden = true
            }

            self.myBandsCollectionView.isHidden = true
            self.myONBCollectionView.isHidden = false

        }
    }
    
    var menuText = ["Your Bands","Your OneNightBands"]
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = menuText[row]
        
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }*/
    
    func finishedShowing() {
        
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
        
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
