//
//  ViewController.swift
//  skulllibrista
//
//  Created by Herrison Feres on 25/05/22.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var street: UIImageView!
    @IBOutlet weak var player: UIImageView!
    @IBOutlet weak var viGameOver: UIView!
    @IBOutlet weak var lbInstructions: UILabel!
    @IBOutlet weak var lbTimePLayer: UILabel!
    
    var isMoving: Bool = false
    lazy var motionManager = CMMotionManager()
    var gameTimer: Timer!
    var startDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viGameOver.isHidden = true
        
        street.frame.size.width = view.frame.size.width * 2
        street.frame.size.height = street.frame.size.height * 2
        street.center = view.center
        
        player.center = view.center
        
        player.animationImages = []
        for i in 0...7 {
            let image = UIImage(named: "player\(i)")!
            player.animationImages?.append(image)
        }
        player.animationDuration = 0.5
        player.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { (timer) in
            self.start()
        }
    }
    
    
    
    func start(){
        lbInstructions.isHidden = true
        viGameOver.isHidden = true
        isMoving = false
        startDate = Date()
        
        self.player.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        self.street.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { data, error in
                if error == nil {
                    if let data = data  {
                        let angle = atan2(data.gravity.x, data.gravity.y) - .pi
                        self.player.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                        if !self.isMoving {
                            self.checkGameOver()
                        }
                    }
                }
            }
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { timer in
            self.rotateWorld()
        })
    }
    
    func rotateWorld(){
        let randomAngle = Double(arc4random_uniform(120))/100 - 0.6
        isMoving = true
        UIView.animate(withDuration: 0.75, animations: {
            self.street.transform = CGAffineTransform(rotationAngle: CGFloat(randomAngle))
        }) {(sucess) in self.isMoving = true}
    }
    
    func checkGameOver(){
        let worldAngle = atan2(Double(street.transform.a), Double(street.transform.b))
        let playerAngle = atan2(Double(player.transform.a), Double(player.transform.b))
        let difference = abs(worldAngle - playerAngle)
        if difference > 0.25 {
            gameTimer.invalidate()
            viGameOver.isHidden = false
            motionManager.stopDeviceMotionUpdates()
            let secondsPlayer = round(Date().timeIntervalSince(startDate))
            lbTimePLayer.text = "Você jogo durante \(secondsPlayer) segundos"
        }
    }


    @IBAction func playAgain(_ sender: Any) {
        start()
    }
}

