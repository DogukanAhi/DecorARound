import UIKit
import SceneKit
import ARKit

class ArVC: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ARSCNView delegesi
        sceneView.delegate = self
        sceneView.showsStatistics = true

        // Modeli ekle
        addChairModel()

        // "Go Back" yazısını ekle
        addGoBackLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // AR oturumunu başlat
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // Sandalye modelini ekleyen fonksiyon
    func addChairModel() {
        guard let chairScene = SCNScene(named: "chair_swan.scn") else { return }

        // Sandalyeyi sahneye ekle
        for node in chairScene.rootNode.childNodes {
            let moveChair = SCNAction.move(by: SCNVector3(x: 0, y: -100, z: -80), duration: 1)
            node.scale = SCNVector3(0.6, 0.6, 0.6)
            node.runAction(moveChair)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }

    // "Go Back" yazısını ekleyen fonksiyon
    func addGoBackLabel() {
        // "Go Back" için bir UILabel oluştur
        let goBackLabel = UILabel()
        goBackLabel.text = "Go Back"
        goBackLabel.textColor = .white
        goBackLabel.textAlignment = .center
        goBackLabel.font = UIFont.boldSystemFont(ofSize: 20)

        // Label'in çerçevesini ayarla
        goBackLabel.frame = CGRect(x: 20, y: 50, width: 100, height: 40)

        // Gesture recognizer ekle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackTapped))
        goBackLabel.isUserInteractionEnabled = true
        goBackLabel.addGestureRecognizer(tapGesture)

        // Label'i görünüme ekle
        self.view.addSubview(goBackLabel)
    }

    // "Go Back" yazısına tıklandığında çağrılacak metod
    @objc func goBackTapped() {
        performSegue(withIdentifier: "fromArVCtoHomeVC", sender: nil)
    }
}

extension ArVC: ARSCNViewDelegate {
    // AR Anchor ile çalışmak isterseniz burada düzenlemeler yapabilirsiniz
}
