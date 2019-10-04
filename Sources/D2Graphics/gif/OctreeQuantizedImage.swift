import D2Utils

/**
 * A quantizer that generates uses an octree
 * in RGB color space.
 */
public struct OctreeQuantizedImage {
    private struct OctreeNode {
        private var red: UInt = 0
        private var green: UInt = 0
        private var blue: UInt = 0
        private var alpha: UInt = 0
        private var refs: UInt = 0
        private var childs: [OctreeNode]? = nil
        
        var color: Color { return Color(red: UInt8(red / refs), green: UInt8(green / refs), blue: UInt8(blue / refs)) }
        var isLeaf: Bool { return childs == nil }
        var colorTableIndex: Int = -1
        
        private func childIndex(of childColor: Color, depth: Int) -> Int {
            let shift = 7 - depth
            if shift < 0 {
                fatalError("RGB octree is too deep, depth: \(depth)")
            }
            let leftRed = ((childColor.red >> shift) & 1) << 2
            let leftGreen = ((childColor.green >> shift) & 1) << 1
            let leftBlue = (childColor.blue >> shift) & 1
            return Int(leftRed | leftGreen | leftBlue)
        }
        
        private mutating func ensureChildsExist() {
            if isLeaf {
                childs = Array(repeating: OctreeNode(), count: 8)
            }
        }
        
        mutating func insert(color insertedColor: Color, depth: Int, maxDepth: Int) {
            if depth == maxDepth {
                red += UInt(insertedColor.red)
                green += UInt(insertedColor.green)
                blue += UInt(insertedColor.blue)
                refs += 1
            } else {
                ensureChildsExist()
                let i = childIndex(of: insertedColor, depth: depth)
                childs![i].insert(color: insertedColor, depth: depth + 1, maxDepth: maxDepth)
            }
        }
        
        func lookup(color lookupColor: Color, depth: Int = 0) -> Int {
            if isLeaf {
                return colorTableIndex
            } else {
                return childs![childIndex(of: lookupColor, depth: depth)].lookup(color: color, depth: depth + 1)
            }
        }
        
        func fill(colorTable: inout [Color]) {
            if isLeaf {
                colorTable.append(color)
            } else {
                for i in 0..<8 {
                    childs![i].fill(colorTable: &colorTable)
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
        octree = OctreeNode()

        let maxDepth = UInt(colorCount).log2Floor()

        for y in 0..<image.height {
            for x in 0..<image.width {
                octree.insert(color: image[y, x], depth: 0, maxDepth: maxDepth)
            }
        }

        octree.fill(colorTable: &colorTable)
    }
    
    private func quantize(color: Color) -> Int {
        if color.alpha < 128 {
            return transparentColorIndex
        } else {
            return octree.lookup(color: color)
        }
    }
    
    subscript(_ y: Int, _ x: Int) -> Int {
        return quantize(color: image[y, x])
    }
}
