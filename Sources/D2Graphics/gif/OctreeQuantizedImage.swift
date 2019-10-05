// Based on https://www.cubic.org/docs/octree.htm

import D2Utils

fileprivate let MAX_DEPTH = 8 // bits in a byte (of each color channel)

/**
 * A quantizer that generates uses an octree
 * in RGB color space.
 */
public struct OctreeQuantizedImage: QuantizedImage {
    private class OctreeNode: CustomStringConvertible {
        private let depth: Int
        private var red: UInt = 0
        private var green: UInt = 0
        private var blue: UInt = 0
        private var refs: UInt = 0
        private var childs: [OctreeNode?] = Array(repeating: nil, count: 8)
        
        var refsOrOne: UInt { return (refs == 0) ? 1 : refs }
        var bitShift: Int { return 7 - depth }
        var color: Color { return Color(red: UInt8(red / refsOrOne), green: UInt8(green / refsOrOne), blue: UInt8(blue / refsOrOne)) }
        var isLeaf: Bool { return refs > 0 }
        var leafCount: Int { return isLeaf ? 1 : childs.compactMap { $0?.leafCount }.reduce(0, +) }
        var refCountWithChilds: Int { return Int(refs + childs.compactMap { $0?.refs }.reduce(0, +)) }
        var description: String { return "(r: \(red), g: \(green), b: \(blue))<\(refs)> \(childs)" }

        private(set) var colorTableIndex: Int = -1
        
        init(depth: Int) {
            self.depth = depth
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
                    childs[i] = OctreeNode(depth: depth + 1)
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
        
        /** "Mixes" all child nodes in this node. This method assumes all children are leaves. */
        func reduce() {
            for i in 0..<8 {
                let child = childs[i]
                if let c = child {
                    red += c.red
                    green += c.green
                    blue += c.blue
                    refs += c.refs
                    childs[i] = nil
                }
            }
        }
        
        private func findNodeWithFewestChildRefs() -> (OctreeNode, Int) {
            var bestNode = self
            var bestCount = refCountWithChilds

            for child in childs.compactMap({ $0 }) {
                let (childBestNode, childBestCount) = child.findNodeWithFewestChildRefs()
                if childBestCount < bestCount {
                    bestNode = childBestNode
                    bestCount = childBestCount
                }
            }
            
            return (bestNode, bestCount)
        }
        
        func reduceBest() {
            let (bestNode, _) = findNodeWithFewestChildRefs()
            bestNode.reduce()
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
        
        print("Reducing octree")
        while octree.leafCount > colorCount {
            octree.reduceBest()
        }
        
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
