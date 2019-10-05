// Based on https://www.cubic.org/docs/octree.htm

import D2Utils

fileprivate let MAX_DEPTH = 8 // bits in a byte (of each color channel)

/**
 * A quantizer that generates uses an octree
 * in RGB color space.
 */
public struct OctreeQuantizedImage: QuantizedImage {
    private class OctreeNode: Hashable, CustomStringConvertible {
        private var red: UInt = 0
        private var green: UInt = 0
        private var blue: UInt = 0
        private var refs: UInt = 0

        let depth: Int
        private(set) var childs: [OctreeNode?] = Array(repeating: nil, count: 8)
        private(set) weak var parent: OctreeNode?
        
        var refsOrOne: UInt { return (refs == 0) ? 1 : refs }
        var childRefSum: UInt { return childs.compactMap { $0?.refs }.reduce(0, +) }
        var bitShift: Int { return 7 - depth }
        var color: Color { return Color(red: UInt8(red / refsOrOne), green: UInt8(green / refsOrOne), blue: UInt8(blue / refsOrOne)) }
        var isLeaf: Bool { return refs > 0 }
        var leaves: [OctreeNode] { return isLeaf ? [self] : childs.flatMap { $0?.leaves ?? [] } }
        var description: String { return "(r: \(red), g: \(green), b: \(blue))<\(refs)> \(childs)" }

        private(set) var colorTableIndex: Int = -1
        
        init(depth: Int, parent: OctreeNode? = nil) {
            self.depth = depth
            self.parent = parent
        }
        
        private func ensureBitShiftNotNegative() {
            if bitShift < 0 {
                fatalError("RGB octree is too deep, depth: \(depth)")
            }
        }
        
        private func childIndex(of childColor: Color) -> Int {
            ensureBitShiftNotNegative()
            let leftRed = ((childColor.red >> bitShift) & 1) << 2
            let leftGreen = ((childColor.green >> bitShift) & 1) << 1
            let leftBlue = (childColor.blue >> bitShift) & 1
            return Int(leftRed | leftGreen | leftBlue)
        }
        
        func insert(color insertedColor: Color) {
            if depth == MAX_DEPTH {
                red = UInt(insertedColor.red)
                green = UInt(insertedColor.green)
                blue = UInt(insertedColor.blue)
                refs = 1
            } else {
                let i = childIndex(of: insertedColor)
                if childs[i] == nil {
                    childs[i] = OctreeNode(depth: depth + 1, parent: self)
                }
                childs[i]!.insert(color: insertedColor)
            }
        }
        
        func lookup(color lookupColor: Color) -> Int {
            if isLeaf {
                return colorTableIndex
            } else {
                // TODO: For debugging
                if childs[childIndex(of: lookupColor)] == nil {
                    print("While looking up \(lookupColor) @ depth \(depth), child index: \(childIndex(of: lookupColor))")
                    print(self)
                }
                return childs[childIndex(of: lookupColor)]!.lookup(color: lookupColor)
            }
        }
        
        /**
         * "Mixes" all child nodes in this node. This method assumes all children are leaves
         * and returns the number of reduced leaves.
         */
        @discardableResult
        func reduce() -> Int {
            var reduced = 0

            for i in 0..<8 {
                let child = childs[i]
                if let c = child {
                    red += c.red
                    green += c.green
                    blue += c.blue
                    refs += c.refs
                    childs[i] = nil
                    reduced += 1
                }
            }

            return reduced
        }
        
        func fill(colorTable: inout [Color]) {
            if isLeaf {
                colorTableIndex = colorTable.count
                colorTable.append(color)
            } else {
                for i in 0..<8 {
                    childs[i]?.fill(colorTable: &colorTable)
                }
            }
        }
        
        /** Performs a pre-order traversal on this octree. */
        func walk(onNode: (OctreeNode) -> Void) {
            onNode(self)
            for child in childs {
                child?.walk(onNode: onNode)
            }
        }
        
        static func ==(lhs: OctreeNode, rhs: OctreeNode) -> Bool { lhs === rhs }
        
        func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    }
    
    /**
     * A wrapper around a reducible octree node that
     * defines comparability and equatability via the
     * sum of child refs.
     */
    private struct QueuedReducibleNode: Comparable {
        let inner: OctreeNode
        
        init(_ inner: OctreeNode) { self.inner = inner }
        
        static func <(lhs: QueuedReducibleNode, rhs: QueuedReducibleNode) -> Bool { return lhs.inner.childRefSum < rhs.inner.childRefSum }
        
        static func ==(lhs: QueuedReducibleNode, rhs: QueuedReducibleNode) -> Bool { return lhs.inner.childRefSum == rhs.inner.childRefSum }
    }
    
    private let image: Image
    private let transparentColorIndex: Int
    private var octree: OctreeNode
    public private(set) var colorTable: [Color]
    
    public init(fromImage image: Image, colorCount: Int, transparentColorIndex: Int) {
        self.image = image
        self.transparentColorIndex = transparentColorIndex
        colorTable = []
        octree = OctreeNode(depth: 0)
        
        print("Inserting colors")
        for y in 0..<image.height {
            for x in 0..<image.width {
                octree.insert(color: image[y, x])
            }
        }
        
        var leafCount = 0
        var reduceQueues = [StableBinaryHeap<QueuedReducibleNode>]()

        // Find reducible nodes at each depth
        octree.walk {
            if $0.isLeaf {
                leafCount += 1
            } else {
                while reduceQueues.count <= $0.depth {
                    reduceQueues.append(StableBinaryHeap())
                }
                reduceQueues[$0.depth].insert(QueuedReducibleNode($0))
            }
        }
        
        print("Reducing octree, leafCount = \(leafCount)")
        while leafCount > colorCount {
            // Find deepest reducible node
            var reducible: QueuedReducibleNode? = nil

            for i in (0..<reduceQueues.count).reversed() {
                if !reduceQueues[i].isEmpty {
                    reducible = reduceQueues[i].popMax()
                    break
                }
            }
            
            guard let reducibleNode = reducible?.inner else { fatalError("Too few reducible nodes") }
            leafCount -= reducibleNode.reduce() - 1
        }

        // DEBUG:
        // for i in (0..<reduceQueues.count).reversed() {
        //     if !reduceQueues[i].isEmpty {
        //         print("Reduced until depth \(i), leafCount: \(leafCount)")
        //         break
        //     }
        // }

        print("Filling color table")
        octree.fill(colorTable: &colorTable)
    }
    
    private func quantize(color: Color) -> Int {
        if color.alpha < 128 {
            return transparentColorIndex
        } else {
            return octree.lookup(color: color)
        }
    }
    
    public subscript(_ y: Int, _ x: Int) -> Int {
        return quantize(color: image[y, x])
    }
}
