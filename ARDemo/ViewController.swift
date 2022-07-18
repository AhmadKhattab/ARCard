//
//  ViewController.swift
//  ARDemo
//
//  Created by Ahmad Ashraf Khattab on 30/06/2022.
//

import UIKit
import SceneKit
import ARKit
import MessageUI

class ViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Outlet(s)
    @IBOutlet var sceneView: ARSCNView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "StaffID", bundle: nil) else {
            fatalError("Unable to load tracking images")
        }
        configuration.trackingImages = trackingImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Method(s)
    private func addGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(recognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tappedView = sender.view as! SCNView
        let touchLocation = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(touchLocation, options: nil)
        
        if !hitTest.isEmpty {
            let nodeName = hitTest.first?.node.name
            if nodeName == Constants.linkedIn {
                openSiteWith(url: Constants.linkedInURL)
            } else if nodeName == Constants.phone {
                call()
            } else if nodeName == Constants.email {
                sendEmail()
            } else if nodeName == Constants.twitter {
                openSiteWith(url: Constants.twitterURL)

            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        let planeNode = SCNNode(geometry: plane)
        let node = SCNNode()
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
        let spacing: Float = 2.0
        let titleSpacing: Float = 1.0
       
        // image node
        let avatarImageNode = imageNode(for: Constants.avatarImageName)
        avatarImageNode.position.x = plane.boundingBox.max.x + spacing
        avatarImageNode.position.y = Float(plane.height / 2) + plane.boundingBox.min.y
        
        planeNode.addChildNode(avatarImageNode)
        
        // title node
        let titleNode = textNode(Constants.name, font: UIFont.boldSystemFont(ofSize: 10))
        titleNode.pivotOnTopLeft()
        titleNode.position.x = avatarImageNode.boundingBox.max.x + titleSpacing
        titleNode.position.y = avatarImageNode.height / 2
        
        avatarImageNode.addChildNode(titleNode)
        
        // linked in node
        let linkedInImageNode = imageNode(for: Constants.linkedIn)
        linkedInImageNode.position.x = plane.boundingBox.min.x + 0.5
        linkedInImageNode.position.y = plane.boundingBox.min.y - spacing
        
        planeNode.addChildNode(linkedInImageNode)
        
        // phone node
        let phoneImageNode = imageNode(for: Constants.phone)
        phoneImageNode.position.x = plane.boundingBox.min.x + (Float(plane.width) * 0.25) + 1
        phoneImageNode.position.y = plane.boundingBox.min.y - spacing
        
        planeNode.addChildNode(phoneImageNode)
        
        // email node
        let emailImageNode = imageNode(for: Constants.email)
        emailImageNode.position.x = plane.boundingBox.min.x + (Float(plane.width) * 0.5) + 1.5
        emailImageNode.position.y = plane.boundingBox.min.y - spacing
        
        planeNode.addChildNode(emailImageNode)
        
        // twitter node
        let twitterImageNode = imageNode(for: Constants.twitter)
        twitterImageNode.position.x = plane.boundingBox.min.x + (Float(plane.width) * 0.75) + 2
        twitterImageNode.position.y = plane.boundingBox.min.y - spacing
        
        planeNode.addChildNode(twitterImageNode)
        
        return node
    }
    
    private func openSiteWith(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func call() {
        if let url = URL(string: Constants.phoneNumber), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        text.materials = [material]
        text.flatness = 0.1
        
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.1, 0.1, 0.1)
        textNode.name = "TitleNode"
        return textNode
    }
    
    func imageNode(for imageName: String) -> SCNNode {
        let image = UIImage(named: imageName)?.roundedImage
        let plane = SCNPlane(width: 2.5, height: 2.5)
        plane.firstMaterial?.diffuse.contents = image
        let imageNode = SCNNode(geometry: plane)
        imageNode.name = "\(imageName)"
        return imageNode
    }
}
// MARK: - MFMailComposeViewControllerDelegate
extension ViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.mailRecipient])
            mail.setMessageBody(Constants.messageBody, isHTML: true)

            present(mail, animated: true)
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
// MARK: - Constants
private extension ViewController {
    struct Constants {
        static let name: String = "Ahmad\nKhattab"
        static let avatarImageName: String = "khattab"
        static let linkedIn: String = "linked_in"
        static let phone: String = "phone"
        static let email: String = "email"
        static let twitter: String = "twitter"
        static let mailRecipient: String = "akhattab03@gmail.com"
        static let messageBody: String = "<p>You're so awesome!</p>"
        static let linkedInURL: String = "https://www.linkedin.com/in/ahmad-khattab-693683172/"
        static let twitterURL: String = "https://twitter.com/AhmadLkhattab"
        static let phoneNumber: String = "tel://01000000000"
        
    }
}
