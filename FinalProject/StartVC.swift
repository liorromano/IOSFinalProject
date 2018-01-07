//
//  StartVC.swift
//  FinalProject
//
//  Created by Romano on 03/01/2018.
//  Copyright © 2018 Romano. All rights reserved.
//

import UIKit

class StartVC: UIViewController {
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Pacifico font of label
        //SignInLabel.font = UIFont(name: "Pacifico", size: 25)
        
        //background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        Model.instance.loggedinUser { (ans) in
            if(ans != nil)
            {
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "TabBar")
                self.present(newViewController, animated: true, completion: nil)
            }
            else
            {
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginVC")
                self.present(newViewController, animated: true, completion: nil)
            }
        }
        
    }
}
