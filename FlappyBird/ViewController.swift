//
//  ViewController.swift
//  FlappyBird
//
//  Created by 馬煜東 on 2019/10/24.
//  Copyright © 2019年 ikutou.ba. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        let scene = GameScene(size:skView.frame.size)
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden:Bool{
        get{
            return true
        }
    }


}

