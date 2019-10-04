import D2Utils

/**
 * A quantizer that generates uses an octree
 * in RGB color space.
 */
public struct OctreeQuantizedImage: QuantizedImage {
    private struct OctreeNode {
        private let depth: Int
        private var red: UInt
        private var green: UInt
        private var blue: UInt
        private var refs: UInt = 0
        private var childs: [OctreeNode]? = nil
        
        var refsOrOne: UInt { return (refs == 0) ? 1 : refs }
        var bitShift: Int { return 7 - depth }
        var color: Color { return Color(red: UInt8(red / refsOrOne), green: UInt8(green / refsOrOne), blue: UInt8(blue / refsOrOne)) }
        var isLeaf: Bool { return childs == nil }
        private(set) var colorTableIndex: Int = -1
        
        init(depth: Int, red: UInt, green: UInt, blue: UInt) {
            self.depth = depth
            self.red = red
            self.green = green
            self.blue = blue
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
        
        private mutating func ensureChildsExist() {
            if isLeaf {
                ensureBitShiftNotNegative()
                childs = []
                for i: UInt in 0..<8 {
                    childs!.append(OctreeNode(
                        depth: depth + 1,
                        red: ((i >> 2) & 1) << bitShift,
                        green: ((i >> 1) & 1) << bitShift,
                        blue: (i & 1) << bitShift
                    ))
                }
            }
        }
        
        mutating func insert(color insertedColor: Color, maxDepth: Int) {
            if depth == maxDepth {
                if refs == 0 {
                    red = 0
                    green = 0
                    blue = 0
                }
                red += UInt(insertedColor.red)
                green += UInt(insertedColor.green)
                blue += UInt(insertedColor.blue)
                refs += 1
            } else {
                ensureChildsExist()
                let i = childIndex(of: insertedColor)
                childs![i].insert(color: insertedColor, maxDepth: maxDepth)
            }
        }
        
        func lookup(color lookupColor: Color) -> Int {
            if isLeaf {
                return colorTableIndex
            } else {
                return childs![childIndex(of: lookupColor)].lookup(color: color)
            }
        }
        
        mutating func fill(colorTable: inout [Color]) {
            if isLeaf {
                colorTableIndex = colorTable.count
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
        octree = OctreeNode(depth: 0, red: 0, green: 0, blue: 0)

        let maxDepth = UInt(colorCount).log2Floor()

        for y in 0..<image.height {
            for x in 0..<image.width {
                octree.insert(color: image[y, x], maxDepth: maxDepth)
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
    
    public subscript(_ y: Int, _ x: Int) -> Int {
        return quantize(color: image[y, x])
    }
}
