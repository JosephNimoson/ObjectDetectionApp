//
//  ViewController.swift
//  AICam
//
//  Created by Joseph on 24.07.2018.
//  Copyright © 2018 Joseph Nimoson. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //Initializing UIlabels Programmaticly
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //MARK Camera setup
        let captureSession = AVCaptureSession()
        
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        captureSession.addOutput(dataOutput)
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQue"))
        
        setupIdentifierConfidenceLabel()


    }
    
    //function of Label, position
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 170).isActive = true
    }
    
    
    
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       // print("camera was able to capture a frame", Date())
        
        //MARK: - Setting up functionality of Core ML model
        guard let model = try? VNCoreMLModel(for: Resnet50().model)else{return}
        
        let request = VNCoreMLRequest(model: model){
            (finishedReq, err) in
            //print(finishedReq.results)
            guard let results = finishedReq.results as?
                [VNClassificationObservation]else{return}
            guard let firstObservation = results.first else {return}
            
            print(firstObservation.identifier,firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
            }
            
            
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        

    }
}

