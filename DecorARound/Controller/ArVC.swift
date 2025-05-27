//
//  ArVC.swift
//  DecorAround
//

import UIKit
import SceneKit
import ARKit
import FirebaseStorage

class ArVC: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    private var infoLabel: UILabel!
    var productId: String = ""
    private var downloadedModelURL: URL?
    
    private static var persistentScene: SCNScene = SCNScene()
    
    private var selectedNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = ArVC.persistentScene

        //addInfoLabel()
        addGoBackButton()
        registerGestureRecognizers()
        downloadModelFromFirebase()
    }

    private func downloadModelFromFirebase() {
        let storage = Storage.storage()
        let path = "models/\(productId).usdz"
        let modelRef = storage.reference(withPath: path)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(productId).usdz")

        modelRef.write(toFile: tempURL) { url, error in
            if let error = error {
                print("Model indirme hatası: \(error.localizedDescription)")
                return
            }
            print("Model başarıyla indirildi: \(tempURL.path)")
            self.downloadedModelURL = tempURL
        }
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

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotated))
            sceneView.addGestureRecognizer(rotationGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pannedToMove))
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.sceneView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func pannedToMove(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: sceneView)

        switch recognizer.state {
        case .began:
            let hitResults = sceneView.hitTest(location, options: nil)
            if let hit = hitResults.first,
               hit.node.name?.starts(with: "product_") == true || hit.node.parent?.name?.starts(with: "product_") == true {
                selectedNode = hit.node.name?.starts(with: "product_") == true ? hit.node : hit.node.parent
            }

        case .changed:
            guard let node = selectedNode else { return }
            let planeResults = sceneView.hitTest(location, types: .existingPlane)
            if let result = planeResults.first {
                let currentY = node.position.y // Y eksenini sabit tut (model zıplamasın)
                node.position = SCNVector3(
                    result.worldTransform.columns.3.x,
                    currentY,
                    result.worldTransform.columns.3.z
                )
            }

        case .ended, .cancelled:
            selectedNode = nil

        default:
            break
        }
    }


    @objc func rotated(recognizer: UIRotationGestureRecognizer) {
        let location = recognizer.location(in: sceneView)

        switch recognizer.state {
        case .began:
            let hitResults = sceneView.hitTest(location, options: nil)
            if let hit = hitResults.first,
               hit.node.name?.starts(with: "product_") == true || hit.node.parent?.name?.starts(with: "product_") == true {
                selectedNode = hit.node.name?.starts(with: "product_") == true ? hit.node : hit.node.parent
            }

        case .changed:
            guard let node = selectedNode else { return }
            node.eulerAngles.y -= Float(recognizer.rotation)
            recognizer.rotation = 0

        case .ended, .cancelled:
            selectedNode = nil

        default:
            break
        }
    }


    

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let touch = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(touch, options: nil)

            if let hitNode = hitTestResults.first?.node,
               let name = hitNode.name,
               name.hasPrefix("delete_") {
                hitNode.parent?.removeFromParentNode()
                print("Model silindi: \(name)")
                return
            }

            // ✅ BURASI: Model daha önce eklendi mi?
            if sceneView.scene.rootNode.childNodes.contains(where: { $0.name == "product_\(productId)" }) {
                print("Bu model zaten sahnede.")
                return
            }

            guard let modelURL = downloadedModelURL else {
                print("Model URL geçerli değil.")
                return
            }

        let planeHit = sceneView.hitTest(touch, types: .existingPlane)
        if let hit = planeHit.first {
            do {
                let modelScene = try SCNScene(url: modelURL, options: nil)
                let wrapperNode = modelScene.rootNode.flattenedClone()

                for child in modelScene.rootNode.childNodes {
                    wrapperNode.addChildNode(child)
                }

                wrapperNode.position = SCNVector3(
                    hit.worldTransform.columns.3.x,
                    hit.worldTransform.columns.3.y,
                    hit.worldTransform.columns.3.z
                )
                wrapperNode.name = "product_\(productId)"

                let deleteText = SCNText(string: "✕", extrusionDepth: 0.01)
                deleteText.font = UIFont.boldSystemFont(ofSize: 2.0)
                deleteText.firstMaterial?.diffuse.contents = UIColor.red
                deleteText.firstMaterial?.emission.contents = UIColor.red
                deleteText.firstMaterial?.isDoubleSided = true

                let deleteNode = SCNNode(geometry: deleteText)
                deleteNode.scale = SCNVector3(0.03, 0.03, 0.03)
                deleteNode.position = SCNVector3(0, 0.8, 0) // modelin biraz üstünde
                deleteNode.eulerAngles.x = -.pi / 2         // yukarıya bakması için düzleme yatırılıyor
                deleteNode.name = "delete_\(UUID().uuidString)"
                
                let constraint = SCNBillboardConstraint()
                constraint.freeAxes = .Y
                deleteNode.constraints = [constraint]

                wrapperNode.addChildNode(deleteNode)

                sceneView.scene.rootNode.addChildNode(wrapperNode)
                print("Model eklendi: \(productId)")
            } catch {
                print("Model yükleme hatası: \(error.localizedDescription)")
            }
        } else {
            print("Plane bulunamadı")
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            DispatchQueue.main.async {
                //self.infoLabel.text = "Plane Detected"
                print("Yüzey algılandı")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
