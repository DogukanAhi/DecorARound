import UIKit
import SceneKit
import ARKit
import FirebaseStorage

class ArVC: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    private var infoLabel: UILabel!
    private var modelAdded = false
    var productId: String = ""
    private var downloadedModelURL: URL?

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
        
        downloadDAEModelFromFirebase()
    }

    private func downloadDAEModelFromFirebase() {
        let storage = Storage.storage()
            let path = "models/\(productId).usdz"  // .usdz uzantısını kullanın
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
        guard !modelAdded, let modelURL = downloadedModelURL else {
                print("Model URL geçerli değil veya model daha önce eklenmiş.")
                return
            }

            // Model dosyasının mevcut olup olmadığını kontrol et
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: modelURL.path) {
                print("Model dosyası mevcut değil!")
                return
            }

            // Dokunma noktasını test et
            let touch = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)

            if let hitTest = hitTestResults.first {
                // USDZ modelini yükle
                let modelNode = SCNNode()

                do {
                    // USDZ dosyasını sahneye yükleyin
                    let modelScene = try SCNScene(url: modelURL, options: nil)
                    if let rootNode = modelScene.rootNode.childNodes.first {
                        rootNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
                        sceneView.scene.rootNode.addChildNode(rootNode)
                        modelAdded = true
                        print("Model başarıyla eklendi.")
                    } else {
                        print("Model sahnesi boş.")
                    }
                } catch {
                    print("USDZ modelini yüklerken hata oluştu: \(error.localizedDescription)")
                }
            } else {
                print("Plane bulunamadı!")
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
