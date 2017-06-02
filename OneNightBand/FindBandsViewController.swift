//
//  FindBandsViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 3/29/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class FindBandsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarDelegate {

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JoinBandToBandBoard"{
            
            if let vc = segue.destination as? BandBoardViewController{
                print(bandTypePicker.selectedRow(inComponent: 0))
                vc.searchType = menuText[bandTypePicker.selectedRow(inComponent: 0)]
            } else if segue.identifier == "FindBandToFindMusicians"{
                if let vc = segue.destination as? ArtistFinderViewController
                {
                    vc.bandID = ""
                    vc.thisBandObject = Band()
                    vc.bandType = "findband"
                    
                }

                
            }
        }
    }

    @IBOutlet weak var tabBar: UITabBar!
    
    @available(iOS 2.0, *)
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items?[0]{
            performSegue(withIdentifier: "FindBandToFindMusicians", sender: self)
        } else if item == tabBar.items?[1]{
            
            
        } else if item == tabBar.items?[2]{
            performSegue(withIdentifier: "FindBandToProfile", sender: self)
        } else {
            performSegue(withIdentifier: "FindBandToFeed", sender: self)
        }
    }

    
    @IBAction func searchPressed(_ sender: Any) {
        performSegue(withIdentifier: "JoinBandToBandBoard", sender: self)
    }
    @IBOutlet weak var bandTypePicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        bandTypePicker.delegate = self
        bandTypePicker.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            //self.myBandsCollectionView.isHidden = false
            //self.myONBCollectionView.isHidden = true
        } else{
           // self.myBandsCollectionView.isHidden = true
            //self.myONBCollectionView.isHidden = false
            
        }
    }
    
    var menuText = ["Bands","OneNightBands"]
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = menuText[row]
        
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
