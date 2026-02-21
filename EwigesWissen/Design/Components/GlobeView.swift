import SwiftUI
import SceneKit

struct GlobeView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.isUserInteractionEnabled = false
        sceneView.antialiasingMode = .multisampling4X

        let scene = SCNScene()
        sceneView.scene = scene

        // Earth sphere
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 64

        let material = SCNMaterial()
        if let texture = UIImage(named: "EarthTexture") {
            material.diffuse.contents = texture
        } else {
            material.diffuse.contents = UIColor.systemBlue
        }
        material.lightingModel = .lambert
        sphere.materials = [material]

        let earthNode = SCNNode(geometry: sphere)
        scene.rootNode.addChildNode(earthNode)

        // Rotate slowly (~10 seconds per revolution)
        let rotation = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 10)
        earthNode.runAction(SCNAction.repeatForever(rotation))

        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 80
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)

        // Directional light for depth
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.light?.color = UIColor.white
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(directionalLight)

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 3.0)
        scene.rootNode.addChildNode(cameraNode)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
