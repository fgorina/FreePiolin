//
//  AppDelegate.swift
//  onvotar
//
//  Created by Francisco Gorina Vanrell on 28/9/17.
//  Copyright © 2017 Francisco Gorina. All rights reserved.
//

import UIKit
import MiniZipPackage


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let baseUrl = URL(string: "https://ipfs.io/ipns/QmZxWEBJBVkGDGaKdYPQUXX4KC5TCWbvuR4iYZrTML8XCR/db.20170926")!
        
        let newUrl = AppDelegate.localApplicationDocumentsDirectory()!.appendingPathComponent("db")
        let path = newUrl.path
        
        // If database directory is not created create it
        if !FileManager.default.fileExists(atPath: path){
            DispatchQueue.global().async {
                do {
                    for dir in 0..<256{
                        let dirstr = String(format:"%02x", dir)
                        let dirUrl = newUrl.appendingPathComponent(dirstr)
                        try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: [:])
                    }
                }catch{
                    NSLog("All bad")
                 }
            }
         }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    class func localApplicationDocumentsDirectory() -> URL?
    {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        
    }
}

