//
//  LoaderViewController.swift
//  onvotar
//
//  Created by Francisco Gorina Vanrell on 30/9/17.
//  Copyright © 2017 Francisco Gorina. All rights reserved.
//

import UIKit

class LoaderViewController: UIViewController {

    @IBOutlet weak var fPrimer: UITextField!
    @IBOutlet weak var fUltim: UITextField!
    @IBOutlet weak var fProgress: UIProgressView!
    
    @IBOutlet weak var fURL: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadData(){
        
        var primer = Int(fPrimer.text!)!
        var ultim = Int(fUltim.text!)!
        let baseUrl = URL(string:fURL.text!)!
        
        if primer < 0 {
            primer = 0
        }
        if primer > 255{
            primer = 255
        }
        if ultim < primer{
            ultim = primer
        }
        if ultim > 255{
            ultim = 255
        }
        
        
        loadData(from:primer, to:ultim, url:baseUrl)
        
    }
    
    func loadData(from: Int, to:Int, url:URL){
        
        fProgress.setProgress(0.0, animated: false)

        let newUrl = AppDelegate.localApplicationDocumentsDirectory()!.appendingPathComponent("db")
   
        let n = (to - from + 1) * 256

            DispatchQueue.global().async {
                var i = 0
                do {
                    
                    for dir in from..<to+1{
                        let dirstr = String(format:"%02x", dir)
                        let dirUrl = newUrl.appendingPathComponent(dirstr)
                        
                        for file in 0..<256{
                            
                            i = i+1
                            
                            // Update progress bar
                            
                            DispatchQueue.main.async {
                                let percent = Float(i)/Float(n)
                                self.fProgress.setProgress(percent, animated: true)
                            }
                            
                            // Load Data
                            
                            let filestr = String(format:"%02x.db", file)
                            
                            let inurl = url.appendingPathComponent(dirstr).appendingPathComponent(filestr)
                            let outurl = dirUrl.appendingPathComponent(filestr)
                            
                            do{
                                let data = try Data(contentsOf: inurl)      // Read data
                                try data.write(to: outurl)      // Write data to local file
                                NSLog("Loaded "+outurl.absoluteString)
                            }catch{
                                NSLog("Error in " + outurl.absoluteString)
                                NSLog("When loading " + inurl.absoluteString)
                            }
                        }
                    }
                }catch{
                    NSLog("All bad")
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        
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
