//
//  ViewController.swift
//  pushplay
//
//  Created by Morten Just Petersen on 5/23/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import UIKit
import SpriteKit
import SceneKit
import AVFoundation

class ViewController: UIViewController {
    
    var prevX : Double = 0
    var prevY : Double = 0
    var prevZ : Double = 0

    var scene : SCNScene!
    var sceneView : SCNView!
    var box : SCNBox!
    var boxNode : SCNNode!
    var camera : SCNCamera!
    var cameraNode : SCNNode!
    var boxAnimation : CAAnimation!
    var currentSession = sessionStatus.Inactive
    var timer : NSTimer!
    
    enum sessionStatus {
        case Active, Inactive
    }
    
    var radioPlayer : AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMotion()
        showScene()
        UIApplication.sharedApplication().idleTimerDisabled = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }

    func showScene(){
        sceneView = SCNView(frame: view.frame)
        scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false // debug
        sceneView.backgroundColor = UIColor.blackColor()
        sceneView.antialiasingMode = SCNAntialiasingMode.Multisampling4X
        
        box = SCNBox(width: 10, height: 10, length: 30, chamferRadius: 50)
        box.firstMaterial?.diffuse.contents =  UIColor.blackColor() //UIColor(hue:0.572, saturation:0.974, brightness:0.298, alpha:1)
        box.firstMaterial?.specular.contents = UIColor.blueColor()
        boxNode = SCNNode(geometry: box)
        
        camera = SCNCamera()
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 30.0)
        cameraNode.constraints = [SCNLookAtConstraint(target: boxNode)]
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(boxNode)
        view.addSubview(sceneView)
        startSlowAnimation()
    }
    
    func startSlowAnimation(){
        boxNode.removeAllActions()
        boxNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(-360/(180/M_PI)), aroundAxis: SCNVector3Make(1, 1, 1), duration: 50)))
    }
    
    func startFastAnimation(){
        boxNode.removeAllActions()
        boxNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByAngle(CGFloat(-360/(180/M_PI)), aroundAxis: SCNVector3Make(1, 1, 1), duration: 1)))
    }
    
    
    func checkMotion(){
        let motionKit = MotionKit()
        motionKit.getAccelerationFromDeviceMotion(interval: 0.1) { (x, y, z) -> () in
            
            let diffX = self.roundSensor(x - self.roundSensor(self.prevX))
            let diffY = self.roundSensor(y - self.roundSensor(self.prevY))
            let diffZ = self.roundSensor(z - self.roundSensor(self.prevZ))
            
            let all = diffX + diffY + diffZ
            if all > 20 {
                println("\(NSDate())Touched. Let's do something")
                
                switch self.currentSession {
                case .Active:
                    self.stopSession()
                case .Inactive:
                    self.startSession()
                }
            }
        }
    }

    func startSession(){
        currentSession = .Active
        println("start session")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.timer = NSTimer.scheduledTimerWithTimeInterval(15*60, target: self, selector: "stopSession", userInfo: nil, repeats: false)
        })
        
        radioPlayer = AVPlayer.playerWithURL(NSURL(string: "http://streams2.kqed.org:80/kqedradio")) as! AVPlayer
        radioPlayer.play()
        
        box.firstMaterial?.specular.contents = UIColor.whiteColor()
        startFastAnimation()
    }
    
    func stopSession(){
        timer.invalidate()
        currentSession = .Inactive
        radioPlayer.pause()
        println("stopping session")
        box.firstMaterial?.specular.contents = UIColor.blueColor()
        startSlowAnimation()
    }
    
    func roundSensor(value:Double) -> Double {
        return abs(round(value*100))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

