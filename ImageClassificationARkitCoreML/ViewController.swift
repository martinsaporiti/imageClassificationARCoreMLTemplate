//
//  ViewController.swift
//  ImageClassificationARkitCoreML
//
//  Created by Martin Saporiti on 30/05/2018.
//  Copyright © 2018 Martin Saporiti. All rights reserved.
//

import UIKit
import ARKit
import CoreML
import Vision

class ViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var resultText: UITextField!
    
    private var requests = [VNRequest]()
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration);
        self.sceneView.delegate = self
        self.resultText.alpha = 0.5
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        self.sceneView.scene = scene
        
        self.setUpVision()
        self.updateCoreML()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sceneView.session.pause()

    }

    
    func setUpVision(){
        guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model)
            else { fatalError("Can't load VisionML model") }

        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)

        classificationRequest.imageCropAndScaleOption = .centerCrop

        self.requests = [classificationRequest]
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        self.updateCoreML()
    }

    
    
    func updateCoreML() {
        
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Run Vision Image Request
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        guard let observations = request.results
            else { print("no results: \(error!)"); return }

        let classifications = observations[0...4]
            .compactMap({ $0 as? VNClassificationObservation })
            .filter({ $0.confidence > 0.3 })
            .sorted(by: { $0.confidence > $1.confidence })
            .map {
                (prediction: VNClassificationObservation) -> String in
                return "\(round(prediction.confidence * 100 * 100)/100)%: \(prediction.identifier)"
        }

        DispatchQueue.main.async {
            print(classifications.joined(separator: "###"))
            self.resultText.text = classifications.joined(separator: "\n")
            
        }
    }
    

}

