import UIKit

import GLKit
import OpenGLES

let frame = CGRect(x: 0, y: 0, width: 400, height: 300)
class TriangleView: GLKView { // ERROR: Use of undeclared type 'GLKView'
    override func drawRect(dirtyRect: CGRect) {
        glClearColor(0.0, 0.0, 0.1, 1.0)
    }
}


