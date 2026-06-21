//
//  NowPlayingView.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import SwiftUI

struct NowPlayingView: View {
    @StateObject private var vm = NowPlayingViewModel()
    @State private var showToast = false

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("CURRENT SONG")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("SecondaryText"))

            HStack(spacing: 2) {
                nowPlayingInfoView
                actionButton
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("RemindBackground"))
        .task {
            await vm.recognizeCurrentSong()
        }
        .task(id: vm.analyzedSong?.artworkURL) {
            await vm.loadArtwork(url: vm.analyzedSong?.artworkURL)
        }
    }
}

private extension NowPlayingView {
    
    var nowPlayingInfoView: some View {
        Group {
            if vm.isLoading {
                loadingNowPlayingView
            } else {
                loadedNowPlayingView
            }
        }
    }
    
    var loadingNowPlayingView: some View {
        PartialBorderShape(radius: 15)
            .stroke(
                Color("NotiButtonColor"),
                style: StrokeStyle(lineWidth: 2, dash: [6])
            )
            .frame(height: 60)
            .padding(1)
    }
    
    var loadedNowPlayingView: some View {
        HStack(spacing: 12) {
            artworkView

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.analyzedSong?.title ?? "Unknown Song")
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(.white)

                Text(vm.analyzedSong?.artist ?? "Unknown Artist")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(Color("SecondaryText"))
            }

            Spacer(minLength: 0)
        }
        .padding(5)
        .background(
            RoundedCorners(
                radius: 15,
                corners: [.topLeft, .bottomLeft]
            )
            .fill(Color("NotiButtonColor"))
        )
        .onTapGesture {
            copySongToClipboard()
        }
        .contextMenu {
            Button {
                copySongToClipboard()
            } label: {
                Label("Copy", systemImage: "clipboard.fill")
            }
        }
        .overlay {
            if showToast {
                ToastView(message: "Copied")
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showToast)
    }
    
    var artworkView: some View {
        
        Group {
            
            if let image = vm.artworkImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                placeholder
            }
        }
    }
    
    var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.5, green: 0.5, blue: 0.5))
            
            Text("?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
    }
    
    var songInfoView: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(vm.analyzedSong?.title ?? "Unknown Song")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
            
            Text(vm.analyzedSong?.artist ?? "Unknown Artist")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("SecondaryText"))
        }
        .onTapGesture {
            copySongToClipboard()
        }
        .contextMenu {
            
            Button {
                copySongToClipboard()
            } label: {
                
                Label("Copy", systemImage: "clipboard.fill")
            }
        }
    }
    var actionButton: some View {
        Button {
            Task {
                await vm.recognizeCurrentSong()
            }
        } label: {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "ear.and.waveform")
                }
            }
            .padding(12)
            .frame(width: 60, height: 60)
            .background(
                RoundedCorners(
                    radius: 15,
                    corners: [.topRight, .bottomRight]
                )
                .fill(Color("NotiButtonColor"))
            )
        }
        .buttonStyle(.plain)
    }
}

private extension NowPlayingView {

    func copySongToClipboard() {

        let title = vm.analyzedSong?.title ?? "Unknown Song"
        let artist = vm.analyzedSong?.artist ?? "Unknown Artist"

        let text = "\(title) by \(artist)"

        #if os(iOS)

        UIPasteboard.general.string = text

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        #elseif os(macOS)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)

        #endif

        showToast = true

        Task {

            try? await Task.sleep(for: .seconds(1.5))

            showToast = false
        }
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(path.cgPath)
    }
}

struct PartialBorderShape: Shape {
    var radius: CGFloat

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let topLeft = CGPoint(x: rect.minX + radius, y: rect.minY)
            let bottomLeft = CGPoint(x: rect.minX + radius, y: rect.maxY)

            // Start at top-left (after corner radius)
            path.move(to: topLeft)

            // Top edge → to top-right (NO stroke drawn on right side later)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

            // Move to bottom-right
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))

            // Bottom edge → back to bottom-left (after radius)
            path.addLine(to: bottomLeft)

            // Left side with rounded corners

            // Bottom-left corner arc
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )

            // Left vertical line up
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))

            // Top-left corner arc
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(270),
                clockwise: false
            )

            return path
        }
}
