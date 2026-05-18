//
//  NowPlayingView.swift
//  KDVS
//
//  Created by John Carraher on 5/18/26.
//

import SwiftUI

struct NowPlayingView: View {

    @StateObject private var viewModel = NowPlayingViewModel()

    @State private var showToast = false

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("CURRENT SONG")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("SecondaryText"))

            HStack(spacing: 12) {

                artworkView

                songInfoView

                Spacer()

                actionButton
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("RemindBackground"))
        .overlay(alignment: .center) {

            if showToast {
                ToastView(message: "Copied")
                    .transition(.opacity)
            }
        }
        .task {
            await viewModel.recognizeCurrentSong()
        }
        .animation(.easeInOut(duration: 0.25), value: showToast)
    }
}

private extension NowPlayingView {

    var artworkView: some View {

        Group {

            if let artworkURL = viewModel.analyzedSong?.artworkURL {

                AsyncImage(url: artworkURL) { image in
                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            } else {

                ZStack {

                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)

                    Text("?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
            }
        }
    }

    var songInfoView: some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(viewModel.analyzedSong?.title ?? "Unknown Song")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text(viewModel.analyzedSong?.artist ?? "Unknown Artist")
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
                await viewModel.recognizeCurrentSong()
            }

        } label: {

            ZStack {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("NotiButtonColor"))
                    .frame(width: 40, height: 40)

                if viewModel.isLoading {

                    ProgressView()

                } else {

                    Image(systemName: "ear.and.waveform")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 20)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private extension NowPlayingView {

    func copySongToClipboard() {

        let title = viewModel.analyzedSong?.title ?? "Unknown Song"
        let artist = viewModel.analyzedSong?.artist ?? "Unknown Artist"

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
