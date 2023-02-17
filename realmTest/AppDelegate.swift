//
//  AppDelegate.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        
        
        let config = Realm.Configuration(
            schemaVersion: 2, // Set the new schema version.
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Category.className()) { oldObject, newObject in
                        // Add the new "dateCreated" property and set it to the current date.
                        newObject!["color"] = UIColor.randomFlat().hexValue()
                    }
                }
            })


        // Tell Realm to use this new configuration object for the default Realm.
        Realm.Configuration.defaultConfiguration = config
    
        do {
            let realm = try Realm()
        } catch {
            print("error to create realm instanse: \(error.localizedDescription)")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

