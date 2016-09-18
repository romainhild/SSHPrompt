//
//  HostsListTableViewController.swift
//  SSHPrompt
//
//  Created by hild on 18/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import UIKit

class HostsListTableViewController: UITableViewController {
    
    var hostList = [Host]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadHostList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostCell", for: indexPath)

        cell.textLabel?.text = hostList[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            self.hostList.remove(at: indexPath.row)
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.reloadData()
        }
        actions.append(deleteAction)
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { action, indexPath in
            self.performSegue(withIdentifier: "addHostSegue", sender: self.hostList[indexPath.row])
        }
        actions.append(editAction)
        
        return actions
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addHostSegue" {
            let nav = segue.destination as! UINavigationController
            let hostController = nav.topViewController as! HostViewController
            hostController.delegate = self
            if let host = sender as? Host {
                hostController.host = host
            }
        }
        else if segue.identifier == "connectSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let terminalController = segue.destination as! TerminalViewController
                terminalController.connect(toHost: hostList[indexPath.row])
            }
        }
    }

}

extension HostsListTableViewController: HostViewControllerDelegate {
    func hostView(sender: HostViewController, editedHost host: Host) {
        if let index = hostList.index(of: host) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func hostView(sender: HostViewController, savedHost host: Host) {
        hostList.append(host)
        tableView.reloadData()
    }
    
    func hostViewCanceled(sender: HostViewController) {
        tableView.reloadData()
    }
}

extension HostsListTableViewController {
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func dataFilePath() -> String {
        return (documentsDirectory() as NSString)
            .appendingPathComponent("HostList.plist")
    }
    
    func saveHostList() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(hostList, forKey: "HostList")
        archiver.finishEncoding()
        data.write(toFile: dataFilePath(), atomically: true)
    }
    
    func loadHostList() {
        let path = dataFilePath()
        if FileManager.default.fileExists(atPath: path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
                hostList = unarchiver.decodeObject(forKey: "HostList") as! [Host]
                unarchiver.finishDecoding()
            }
        }
    }
}
