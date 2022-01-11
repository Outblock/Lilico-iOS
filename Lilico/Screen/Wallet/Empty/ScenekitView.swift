//
//  3DCoinView.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import SceneKit
import SwiftUI
import UIKit

struct ScenekitView: UIViewRepresentable {
    let scene = SCNScene(named: "Bitcoin_metal_coin.obj")!

    func makeUIView(context _: Context) -> SCNView {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 50)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(lightNode)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
//
//        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))

        // retrieve the SCNView
        let scnView = SCNView()
        scnView.backgroundColor = UIColor.clear
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context _: Context) {
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
//        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.clear
    }
}

struct ScenekitView_Previews: PreviewProvider {
    static var previews: some View {
        ScenekitView()
            .background(Color.LL.rebackground)
    }
}
