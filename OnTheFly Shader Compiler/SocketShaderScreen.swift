//
//  SocketShaderScreen.swift
//  OnTheFly Shader Compiler
//
//  Created by Ayush Singhal on 09/06/24.
//

import SwiftUI

struct SocketShaderScreen: View {
    @State private var rawCode = SocketShaderInteractor.defaultMetalCode
    @State var time: Float = .zero
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let socketShaderInteractor = SocketShaderInteractor()

    var body: some View {
        VStack {
            makeContainer(title: "Preview") {
                VStack(spacing: .zero) {
                    Color.green.frame(height: 20.0)
                    Color.yellow.frame(height: 20.0)
                    Color.orange.frame(height: 20.0)
                    Color.red.frame(height: 20.0)
                    Color.purple.frame(height: 20.0)
                    Color.blue.frame(height: 20.0)
                }
                .drawingGroup()
                .frame(width: 200.0)
                .distortionEffect(socketShaderInteractor.shaderLibrary.distortionEffect(
                    .float4(0.0, 0.0, 200.0, 120.0),
                    .float(time)
                ),
                maxSampleOffset: CGSize(width: 200.0, height: 200.0))
                .onReceive(timer) { _ in
                    time += 0.1
                }
            }

            makeContainer(title: "Editor") {
                TextEditor(text: $rawCode)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .tint(.black)
                    .font(.system(size: 14.0, design: .monospaced))
                    .padding(.top, 40.0)
                    .padding(.leading, 12.0)
            }
        }
        .task {
            socketShaderInteractor.initiate()

            await socketShaderInteractor.send(text: rawCode)
        }
        .onChange(of: rawCode) {
            Task {
                await socketShaderInteractor.send(text: rawCode)
            }
        }
    }
}

private func makeContainer<V: View>(
    title: String,
    @ViewBuilder content: () -> V
) -> some View {
    Color.gray.opacity(0.2)
//        .aspectRatio(contentMode: .fit)
        .overlay {
            content()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .overlay {
            VStack {
                Text(title)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(Color.gray)
                Spacer()
            }
            .padding(16.0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8.0)
}

#Preview {
    SocketShaderScreen()
}
