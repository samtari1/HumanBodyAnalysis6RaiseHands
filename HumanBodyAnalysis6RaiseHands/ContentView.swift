//
//  ContentView.swift
//  HumanBodyAnalysis6RaiseHands
//
//  Created by Quanpeng Yang on 3/22/26.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var bodyPose: String = "Detecting..."
    let imageName = "raisehand" // Your asset name

    var body: some View {
        VStack(spacing: 20) {
            // 1. Display the Image
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
            }

            // 2. Display the Action Text
            VStack(alignment: .leading) {
                Text("Body Analysis:")
                    .font(.headline)
                
                Text(bodyPose)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .task {
            await detectAction()
        }
    }

    func detectAction() async {
        // Load from Assets
        guard let uiImage = UIImage(named: imageName),
              let cgImage = uiImage.cgImage else {
            bodyPose = "Image not found."
            return
        }

        do {
            let request = DetectHumanBodyPoseRequest()
            let observations = try await request.perform(on: cgImage, orientation: .up)
            
            var text = ""
            
            if observations.isEmpty {
                text = "No people detected."
            }

            for (index, observation) in observations.enumerated() {
                text += "Person \(index + 1):\n"
                
                // --- Left Hand Logic ---
                // In Vision, Y increases as you move UP (0.0 is bottom, 1.0 is top)
                if let leftWrist = observation.joint(for: .leftWrist),
                   let leftElbow = observation.joint(for: .leftElbow) {
                    
                    if leftWrist.location.y > leftElbow.location.y {
                        text += "• Left hand raised \n"
                    }
                }
                
                // --- Right Hand Logic ---
                if let rightWrist = observation.joint(for: .rightWrist),
                   let rightElbow = observation.joint(for: .rightElbow) {
                    
                    if rightWrist.location.y > rightElbow.location.y {
                        text += "• Right hand raised \n"
                    }
                }
                
                text += "\n"
            }
            
            bodyPose = text
            
        } catch {
            bodyPose = "Error: \(error.localizedDescription)"
        }
    }
}
