//
//  ListOfAdressesViewController.swift
//  ZafeplaceSDK
//
//  Created by Dmitriy Zhyzhko on 25.06.2018.
//  Copyright © 2018 Z4. All rights reserved.
//

import Foundation
import UIKit

class ListOfAdressesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array = [String?] ()
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jstCell")
        cell?.textLabel?.text = array[indexPath.row]
        
        return cell!
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
