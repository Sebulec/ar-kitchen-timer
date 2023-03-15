
import ARKit
import RealityKit
import SwiftUI
import UIKit

struct ContentView : View {
    
    @State var kitchenTimer = KitchenTimer()
    
    var body: some View {
        ARViewContainer(kitchenTimer: kitchenTimer)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let kitchenTimer: KitchenTimer
    var sceneView = MyARSCNView(frame: .zero)
    
    func makeUIView(context: Context) -> ARSCNView {
        sceneView.touchDelegate = self
        sceneView.timersDelegate = kitchenTimer
        
        sceneView.addCoaching()
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = false
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        setupCamera(sceneView: sceneView)
                
        return sceneView
        
    }
    
    func setupCamera(sceneView: ARSCNView){
        let camera = sceneView.pointOfView?.camera!
        camera?.motionBlurIntensity = 1
        camera?.wantsDepthOfField = true
    }
    
    func showDebug(featureDots: Bool) {
        if featureDots {
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                      .renderAsWireframe,
                                      .showBoundingBoxes,
                                      .showCameras,
                                      .showConstraints,
                                      .showLightExtents,
                                      .showLightInfluences,
                                      .showSkeletons,
                                      ARSCNDebugOptions.showWorldOrigin]
            sceneView.showsStatistics = true
        } else {
            sceneView.debugOptions = []
            sceneView.showsStatistics = false
        }
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        updateTimers()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(sceneView)
    }
    
    private func updateTimers() {
        kitchenTimer.elements.forEach { sceneView.updateTimer(id: $0.id, value: $0.secondsToHoursMinutesSeconds()) }
    }
}

class MyARSCNView: ARSCNView {
    var touchDelegate: TouchDelegate?
    var timersDelegate: TimersDelegate?
    private var debounceTime: TimeInterval = 1
    private var touchEnabled: Bool = true
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchEnabled else { return }
        touchEnabled = false
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceTime) { [weak self] in
                self?.touchEnabled = true
            }
        }
        guard let touch = touches.first else { return }
        if touch.view == self {
            let viewTouchLocation: CGPoint = touch.location(in: self)
            
            print(viewTouchLocation)
            
            if let touchedNode = hitTest(viewTouchLocation, options: nil).first?.node {
                touchDelegate?.didTouch(node: touchedNode)
            }
        }
        
        guard let point = touches.first?.location(in: self) else { return }
        
        _ = touchDelegate?.didTouch(point, with: event)
        
        super.touchesEnded(touches, with: event)
    }
    
    func addTimer(worldCoord: SCNVector3) {
        let identifier = "timer_\(UUID().uuidString)"
        let timerNode = TimerNode(identifier: identifier)
        
        scene.rootNode.addChildNode(timerNode)
        timerNode.position = worldCoord
        
        timerNode.eulerAngles.y = (pointOfView?.eulerAngles.y)!
        timersDelegate?.didAddNewTimer(id: identifier)
    }
    
    func updateTimer(id: String, value: String) {
        guard let timerNode = scene.rootNode.childNode(withName: id, recursively: true),
                let textNode = timerNode.geometry as? SCNText else { return }
        
        textNode.string = value
    }
    
    deinit {
        touchDelegate = nil
        timersDelegate = nil
    }
}

extension MyARSCNView: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        touchDelegate?.didUpdateFrame()
    }
}

protocol TouchDelegate {
    func didTouch(_ point: CGPoint, with event: UIEvent?) -> UIView?
    func didUpdateFrame()
    func didTouch(node: SCNNode)
}

extension ARViewContainer: TouchDelegate {
    func didTouch(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let raycastQuery = sceneView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .horizontal) else { return nil }
        
        guard let result = sceneView.session.raycast(raycastQuery).first else {
            return nil
        }
            
        sceneView.addTimer(worldCoord: SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z))
        
        return nil
    }
    
    func didUpdateFrame() {
        updateTimers()
    }
    
    func didTouch(node: SCNNode) {
        if let timerNode = node.parent as? TimerNode {
            timerNode.remove()
        }
        guard let nodeName = node.name else { return }
        kitchenTimer.didStopTimer(id: nodeName)
    }
}

class Coordinator: NSObject {
    private let view: SCNView
    
    init(_ view: SCNView) {
        self.view = view
        super.init()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

// MARK: - Apple coaching code

extension ARSCNView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        // Create a ARCoachingOverlayView object
        let coachingOverlay = ARCoachingOverlayView()
        // Make sure it rescales if the device orientation changes
        coachingOverlay.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        addSubview(coachingOverlay)
        // Set the Augmented Reality goal
        coachingOverlay.goal = .horizontalPlane
        // Set the ARSession
        coachingOverlay.session = session
        // Set the delegate for any callbacks
        coachingOverlay.delegate = self
    }
    
    public func coachingOverlayViewDidDeactivate(
        _ coachingOverlayView: ARCoachingOverlayView
    ) {
        coachingOverlayView.activatesAutomatically = false
    }
}
