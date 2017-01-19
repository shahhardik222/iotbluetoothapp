

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var doorTable: UITableView!
    @IBOutlet var bleStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doorTable.tableFooterView = UIView()
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        // Start the Bluetooth discovery process
        _ = btDiscoverySharedInstance
    }
    
    
    func connectionChanged(_ notification: Notification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute: {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.bleStatus.text = "iDoorBell Connected"
                } else {
                    self.bleStatus.text = "iDoorBell Disconnected"
                }
            }
        });
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let tableViewCell : DoorBellCell = tableView.dequeueReusableCell(withIdentifier: "DoorCell", for: indexPath) as! DoorBellCell

        if indexPath.row == 0 {
            
            tableViewCell.doorImage.image = UIImage(named: "opendoor.png")
            tableViewCell.doorText.text = "Open the door"
        }
        else {
            tableViewCell.doorImage.image = UIImage(named: "closeddoor.png")
            tableViewCell.doorText.text = "Close the door"
        }
        
        return tableViewCell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            btDiscoverySharedInstance.openTheDoor()
        }
        else{
            btDiscoverySharedInstance.closeTheDoor()
        }
    }
    

}

