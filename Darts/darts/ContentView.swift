import SwiftUI
import RealityKit
import simd

struct ContentView: View {
    var body: some View {
        RealityView { content in
            // Szene nur einmal aufsetzen
            if content.entities.isEmpty {
                setupScene(in: content)
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleTap(on: value.entity)
                }
        )
    }

    /// Initiale 3D-Szene aufbauen
    func setupScene(in content: RealityViewContent) {
        // Anker vor dir in Augenhöhe
        let anchor = AnchorEntity(world: SIMD3<Float>(0, 1.5, -2))

        // Dartboard als einfache Scheibe (Zylinder)
        let boardRadius: Float = 0.5
        let boardThickness: Float = 0.02

        // Achtung: Signatur ist height: then radius:
        let boardMesh = MeshResource.generateCylinder(
            height: boardThickness,
            radius: boardRadius
        )

        var boardMaterial = SimpleMaterial()
        boardMaterial.color = .init(tint: .white, texture: nil)

        let boardEntity = ModelEntity(mesh: boardMesh, materials: [boardMaterial])

        // Board drehen, damit es zu dir zeigt
        boardEntity.orientation = simd_quatf(
            angle: .pi / 2,
            axis: SIMD3<Float>(1, 0, 0)
        )

        // Name, damit wir es erkennen können
        boardEntity.name = "dartboard"

        anchor.addChild(boardEntity)
        content.add(anchor)
    }

    /// Wird aufgerufen, wenn auf ein Entity getippt wurde.
    func handleTap(on entity: Entity) {
        // Versuche, das getappte Entity oder dessen Parent als ModelEntity zu bekommen
        let model = entity as? ModelEntity ?? entity.parent as? ModelEntity

        // Prüfen, ob wir das Dartboard getroffen haben
        guard let board = model, board.name == "dartboard" else {
            return
        }

        // Einen "Pfeil" (Platzhalter) direkt am Board platzieren
        spawnDart(on: board)
    }

    /// Einfachen Dart-Pfeil (Box) vor dem Board platzieren
    func spawnDart(on board: ModelEntity) {
        let dartMesh = MeshResource.generateBox(size: 0.05)
        var dartMaterial = SimpleMaterial()
        dartMaterial.color = .init(tint: .red, texture: nil)
        let dart = ModelEntity(mesh: dartMesh, materials: [dartMaterial])

        // Ein Stück vor das Board setzen (lokale Koordinaten des Boards)
        dart.position = SIMD3<Float>(0, 0, 0.05)

        board.addChild(dart)
    }
}
