//
//  OneNightBandViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/6/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class OneNightBandViewController: UIViewController {
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var onbInfoTextView: UITextView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBAction func addMediaPressed(_ sender: Any) {
    }
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBAction func chatButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var findArtistsButton: UIButton!

    @IBAction func findArtistsPressed(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
