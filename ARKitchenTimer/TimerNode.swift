import SceneKit

class TimerNode: SCNNode {
    convenience init(identifier: String) {
        self.init()
        
        let string = "00:00"
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont.systemFont(ofSize: 12)
        text.flatness = 0.005
        geometry = text
        name = identifier
        let fontScale: Float = 0.01
        scale = SCNVector3(fontScale, fontScale, fontScale)
        
        let minVec = boundingBox.min
        let maxVec = boundingBox.max
        let bound = SCNVector3Make(maxVec.x - minVec.x,
                                   maxVec.y - minVec.y,
                                   maxVec.z - minVec.z);

        let plane = SCNPlane(width: CGFloat(bound.x + 1),
                            height: CGFloat(bound.y + 1))
        plane.cornerRadius = 0.2
        plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.9)
        plane.name = identifier.planeName
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(CGFloat( minVec.x) + CGFloat(bound.x) / 2 ,
                                        CGFloat( minVec.y) + CGFloat(bound.y) / 2,CGFloat(minVec.z - 0.01))
        planeNode.name = identifier.planNodeName

        addChildNode(planeNode)
    }
    
    func remove() {
        childNodes.forEach { $0.removeFromParentNode() }
        removeFromParentNode()
    }
}

private extension String {
    var planeName: String { self + "Plane" }
    var planNodeName: String { self + "PlaneNode" }
}
