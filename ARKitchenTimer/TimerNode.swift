import SceneKit

class TimerNode: SCNNode {
    // This convenience initializer takes an identifier string as a parameter and sets up a 3D text node with a timer string and a black background plane node to display the timer.
    convenience init(identifier: String) {
        self.init()
        
        let string = "00:00"
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont.systemFont(ofSize: 12)
        text.flatness = 0.005
        geometry = text
        name = identifier
        
        // The font size of the timer text is scaled down by a factor of 0.01.
        let fontScale: Float = 0.01
        scale = SCNVector3(fontScale, fontScale, fontScale)
        
        // The dimensions of the black background plane are determined by the bounding box of the timer text node plus a small buffer.
        let minVec = boundingBox.min
        let maxVec = boundingBox.max
        let bound = SCNVector3Make(maxVec.x - minVec.x,
                                   maxVec.y - minVec.y,
                                   maxVec.z - minVec.z);
        
        let plane = SCNPlane(width: CGFloat(bound.x + 1),
                             height: CGFloat(bound.y + 1))
        plane.cornerRadius = 0.2
        plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.9)
        
        // The identifier string is used to name the plane node for later reference.
        plane.name = identifier.planeName
        let planeNode = SCNNode(geometry: plane)
        
        // The position of the plane node is set to the bottom left corner of the timer text node with a slight offset in the z direction.
        planeNode.position = SCNVector3(CGFloat(minVec.x) + CGFloat(bound.x) / 2,
                                        CGFloat(minVec.y) + CGFloat(bound.y) / 2,
                                        CGFloat(minVec.z - 0.01))
        
        // The identifier string is used to name the plane node's parent node for later reference.
        planeNode.name = identifier.planNodeName
        
        // The plane node is added as a child node of the timer text node.
        addChildNode(planeNode)
    }
    
    // This method removes all child nodes of the timer text node and then removes the timer text node itself from its parent node.
    func remove() {
        childNodes.forEach { $0.removeFromParentNode() }
        removeFromParentNode()
    }
}

// This extension defines two computed properties on the String type that are used to generate unique names for the timer text node's black background plane node and its parent node.
private extension String {
    var planeName: String { self + "Plane" }
    var planNodeName: String { self + "PlaneNode" }
}





