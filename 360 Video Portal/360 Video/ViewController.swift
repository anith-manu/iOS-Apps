//
//  ViewController.swift
//  AR 360 Video Portal
//
//  Created by Anith Manu on 12/07/2018.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration.planeDetection = .horizontal
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            
        }
    }
    
    
    func addPortal(hitTestResult: ARHitTestResult) {
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.isPlaying = true
        
        let spriteKitScene = SKScene(size: CGSize(width: 640, height: 480))
        spriteKitScene.scaleMode = .aspectFill
        
        let videoUrl  = Bundle.main.url(forResource: "360Video", withExtension: "mp4")
        let videoPlayer = AVPlayer(url: videoUrl!)
        
        let videoSpriteKitNode = SKVideoNode(avPlayer:videoPlayer)
        
        videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoSpriteKitNode.size = spriteKitScene.size
        videoSpriteKitNode.yScale = -1.0
        videoSpriteKitNode.play()
        spriteKitScene.addChild(videoSpriteKitNode)
        
        let sphere = create(stars: SCNSphere(radius:1 ), and: spriteKitScene, and: nil, and: nil, and: nil, and: SCNVector3(0,0,-4))
        
        self.sceneView.scene.rootNode.addChildNode(sphere)
    }
    
    
    func create(stars geometry: SCNGeometry, and diffuse: SKScene?, and specular: UIImage?, and emission: UIImage?, and normal: UIImage?, and position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.normal.contents = normal
        node.geometry?.firstMaterial?.emission.contents = emission
        node.position = position
        node.geometry?.firstMaterial?.isDoubleSided = true
        
        return node
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else {return}
        
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
}
