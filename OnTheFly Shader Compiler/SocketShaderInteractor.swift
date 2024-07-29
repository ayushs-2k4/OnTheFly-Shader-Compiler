//
//  SocketShaderInteractor.swift
//  OnTheFly Shader Compiler
//
//  Created by Ayush Singhal on 09/06/24.
//

import SwiftUI

@Observable
final class SocketShaderInteractor {
    var shaderLibrary: ShaderLibrary = .default

    private let session = URLSession.shared
    private let url = URL(string: "ws://localhost:8080")!
    private var task: URLSessionWebSocketTask?

    func initiate() {
        task = session.webSocketTask(with: url)
        task?.resume()

        subscribe()
    }

    private func subscribe() {
        task?.receive { [weak self] result in
            switch result {
            case let .success(value):
                if case let .data(data) = value {
                    self?.shaderLibrary = ShaderLibrary(data: data)
                    self?.subscribe() // Continue listening for more messages
                    print("Succefully initialted")
                } else if case let .string(text) = value {
                    // Handle text message if needed
                    print("Received text: \(text)")
                }

            case let .failure(error):
                print("Error: \(error)")
            }
        }
    }

    func send(text: String) async {
        do {
            try await task?.send(.string(text))
            print("Sent text")
        } catch {
            print("Failed to send message: \(error)")
        }
    }

    static let defaultMetalCode: String = """
    #include <metal_stdlib>
    using namespace metal;

    [[ stitchable ]]
    float2 distortionEffect(
        float2 position,
        float4 bounds,
        float t
    ) {
      float2 uv = position / bounds.zw;
      position.y += 40 * sin((4 * uv.x + 2 * t));
      position.x += 40 * sin((4 * uv.x + 2 * t));
      return position;
    }
    """
}
