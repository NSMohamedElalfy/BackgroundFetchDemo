//
//  ViewController.swift
//  BackgroundFetchAPIEx
//
//  Created by Mohamed El-Alfy on 3/14/15.
//  Copyright (c) 2015 Mohamed El-Alfy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    var arrNewsData:NSArray = []
    var dataFilePath:String!
    let NewsFeed:NSString = "http://feeds.reuters.com/reuters/technologyNews"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
         // 1. Make self the delegate and datasource of the table view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // 2. Specify the data storage file path.
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDirectory:NSString = paths.objectAtIndex(0) as! NSString
        self.dataFilePath = docDirectory.stringByAppendingPathComponent("newsdata")
        
        // 3. Initialize the refresh control.
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        //self.refreshData()
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.dataFilePath) {
            self.arrNewsData = NSArray(contentsOfFile: self.dataFilePath)!
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData(){
        let xmlParser = XMLParser(XMLURLString: NewsFeed as String)
        xmlParser.startParsingWithCompletionHandler { (success:Bool, dataArray:[AnyObject]!, error:NSError!) -> Void in
            if success {
                self.performNewFetchedDataActionsWithDataArray(dataArray as NSArray)
                self.refreshControl.endRefreshing()
            }else{
                println(error.localizedDescription)
            }
            
        }
    }
    
    func performNewFetchedDataActionsWithDataArray(dataArray:NSArray){
        // 1. Initialize the arrNewsData array with the parsed data array.
        self.arrNewsData = NSArray(array: dataArray)
        
        // 2. Reload the table view.
        self.tableView.reloadData()
        
        // 3. Save the data permanently to file.
        if !self.arrNewsData.writeToFile(self.dataFilePath, atomically: true){
            
            NSLog("Couldn't save data.")
        }
    }
    
    func fetchNewDataWithCompletionHandler(completionHandler:(UIBackgroundFetchResult)->Void){
        
        let xmlParser = XMLParser(XMLURLString: NewsFeed as String)
        xmlParser.startParsingWithCompletionHandler { (success:Bool, dataArray:[AnyObject]!, error:NSError!) -> Void in
            if success {
                let tempDataArray = dataArray as NSArray
                if self.arrNewsData.count != 0 {
                    
                    let latestDataDict:NSDictionary = tempDataArray.objectAtIndex(0) as! NSDictionary
                    let latestTitle:NSString = latestDataDict.objectForKey("title") as! NSString
                
                    let existingDataDict:NSDictionary = self.arrNewsData.objectAtIndex(0) as! NSDictionary
                    let existingTitle:NSString = existingDataDict.objectForKey("title") as! NSString
                    
                    if latestTitle.isEqualToString(existingTitle as String){
                        completionHandler(UIBackgroundFetchResult.NoData)
                        NSLog("No New Data Found")
                    }else{
                        completionHandler(UIBackgroundFetchResult.NewData)
                        self.performNewFetchedDataActionsWithDataArray(tempDataArray)
                        NSLog("New Data Found")
                    }
                }else{
                    completionHandler(UIBackgroundFetchResult.NewData)
                    self.performNewFetchedDataActionsWithDataArray(tempDataArray)
                    NSLog("New Data Found")
                }
                
            }else{
                completionHandler(UIBackgroundFetchResult.Failed);
                
                NSLog("Failed to fetch new data.")
                println(error.localizedDescription)
            }
            
        }
        
    }
    
    @IBAction func removeDataFile(sender: AnyObject) {
        
        if NSFileManager.defaultManager().fileExistsAtPath(self.dataFilePath) {
            NSFileManager.defaultManager().removeItemAtPath(self.dataFilePath, error: nil)
            self.arrNewsData = []
            self.tableView.reloadData()
        }
    }
    


}


extension ViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.arrNewsData.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellNewsTitle", forIndexPath: indexPath) as! UITableViewCell
        let dict:NSDictionary = self.arrNewsData.objectAtIndex(indexPath.row) as! NSDictionary
        
        cell.textLabel?.text = dict.objectForKey("title") as? String
        cell.detailTextLabel?.text = dict.objectForKey("pubDate") as? String
        
        return cell
        
    }
    
    
}

extension ViewController:UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict : NSDictionary = self.arrNewsData.objectAtIndex(indexPath.row) as! NSDictionary
        let newsLink:String = dict.objectForKey("link") as! String
        UIApplication.sharedApplication().openURL(NSURL(string: newsLink)!)
    }
    
}

