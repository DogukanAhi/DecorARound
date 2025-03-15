import UIKit
import SceneKit
import ARKit

class ArVC: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    private var infoLabel: UILabel!
    private var modelAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.autoenablesDefaultLighting = true

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene

        addInfoLabel()
        addGoBackButton()
        registerGestureRecognizers()
    }

    private func addInfoLabel() {
        infoLabel = UILabel()
        infoLabel.text = "Detecting Plane..."
        infoLabel.textColor = .white
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        infoLabel.layer.cornerRadius = 8
        infoLabel.layer.masksToBounds = true
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            infoLabel.widthAnchor.constraint(equalToConstant: 200),
            infoLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func addGoBackButton() {
        let goBackButton = UIButton(type: .system)
        goBackButton.setTitle("Go Back", for: .normal)
        goBackButton.setTitleColor(.white, for: .normal)
        goBackButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        goBackButton.layer.cornerRadius = 8
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        goBackButton.addTarget(self, action: #selector(goBackTapped), for: .touchUpInside)
        self.view.addSubview(goBackButton)

        NSLayoutConstraint.activate([
            goBackButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            goBackButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            goBackButton.widthAnchor.constraint(equalToConstant: 100),
            goBackButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func goBackTapped() {
        self.dismiss(animated: true)
    }

    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .changed {
            guard let sceneView = recognizer.view as? ARSCNView else {
                return
            }

            let touch = recognizer.location(in: sceneView)
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)

            if let hitTest = hitTestResults.first {
                let chairNode = hitTest.node

                let pinchScaleX = Float(recognizer.scale) * chairNode.scale.x
                let pinchScaleY = Float(recognizer.scale) * chairNode.scale.y
                let pinchScaleZ = Float(recognizer.scale) * chairNode.scale.z

                chairNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)

                recognizer.scale = 1
            }
        }
    }

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard !modelAdded else { return }

        guard let sceneView = recognizer.view as? ARSCNView else {
            return
        }

        let touch = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)

        if let hitTest = hitTestResults.first {
            let chairScene = SCNScene(named: "chair.dae")!
            guard let chairNode = chairScene.rootNode.childNode(withName: "chair", recursively: true) else {
                return
            }

            chairNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)

            self.sceneView.scene.rootNode.addChildNode(chairNode)
            modelAdded = true
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            DispatchQueue.main.async {
                self.infoLabel.text = "Plane Detected"
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }
}
