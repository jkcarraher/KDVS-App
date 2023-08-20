//
//  NowPlayingView.swift
//  KDVS
//
//  Created by John Carraher on 6/21/23.
//

import SwiftUI
import AVFoundation
import ShazamKit


struct NowPlayingView: View {
    let recorder = AudioStreamRecorder()
    
    @ObservedObject private var shazamManager = ShazamManager()
    @State private var analyzedSong: ShazamSong? = nil
    @State private var analyzedSongUpdated: Bool = false
    @State private var showProgressView: Bool = false

    @State private var infoText: String = "Unknown"
    @State private var artworkImage: Image?
    @State private var loadingBarProgress: CGFloat = 0.0
    @State private var isRecording: Bool = false
    @State private var showToast = false


    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("CURRENT SONG")
                    .font(.system(size: 14, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isRecording {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 20, height: 50)
            } else {
                HStack{
                    HStack{
                        if let artworkURL = analyzedSong?.artworkURL {
                            AsyncImage(url: artworkURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .frame(width: 50, height: 50, alignment: .center)
                            } placeholder: {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }.frame(width: 50, height: 50)
                                .id(UUID()) // Add this line
                            
                        }   else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray)
                                Text("?")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading){
                            Text(analyzedSong?.title ?? "Unknown Song")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)
                            
                            Text(analyzedSong?.artist ?? "Unknown Artist")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("SecondaryText"))
                                .multilineTextAlignment(.leading)
                        }
                    }.onTapGesture {
                        copyToClipboard("\(analyzedSong?.title ?? "Unknown Song") by \(analyzedSong?.artist ?? "Unknown Artist")")
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showToast = false
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            copyToClipboard("\(analyzedSong?.title ?? "Unknown") by \(analyzedSong?.artist ?? "Unknown")")
                        }){
                            Label("Copy", systemImage: "clipboard.fill")
                        }
                    }
                    
                    Spacer() // Add a spacer to push the button to the right
                    
                    Button(action: {
                        recordButtonPressed()
                    }, label: {
                        Image(systemName: "ear.and.waveform")
                            .resizable()
                            .foregroundColor(Color(UIColor.label))
                            .environment(\.colorScheme, .dark)
                            .background(Color.clear)
                            .frame(width: 15, height: 20)
                    }).frame(width: 40, height: 40, alignment: .center)
                        .background(Color("NotiButtonColor"))
                        .cornerRadius(30)
                        .padding([.top], 7)
                }.padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }.frame(maxWidth: .infinity, maxHeight: 120)
            .background(Color("RemindBackground"))
            .onAppear{
                recordButtonPressed()
            }
            .onReceive(shazamManager.$analyzedSong) { analyzedSong in
                self.analyzedSong = analyzedSong
                self.analyzedSongUpdated = true
            }
            .overlay(
                ToastView(message: "Copied")
                    .opacity(showToast ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5))
                )
    }
    func copyToClipboard(_ text: String) {
            #if os(iOS)
            UIPasteboard.general.string = text
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #elseif os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            
            #endif
        }

    func recordButtonPressed() {
        print("Recording Stream")
        isRecording = true // Show the progress bar
        analyzedSongUpdated = false
            // Start recording from the AVPlayer
            self.recorder.startRecording {
                // Wait for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Stop recording and perform analysis on the recorded audio
                    self.recorder.stopRecording { error in
                        // Handle the error, if any
                        if let error = error {
                            print("ERROR DOWNLOADING")
                            self.isRecording = false

                        } else{
                            // Handle the completion of the recording
                            if let audioFileURL = self.recorder.getAudioFileURL() {
                                print("Analyzing file @:\(audioFileURL)")
                                self.shazamManager.analyzeSegment(audioURL: audioFileURL){
                                    self.isRecording = false
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }


struct ToastView: View {
    let message: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.black.opacity(0.7))
                .frame(width: 100, height: 40)
            Text(message)
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
    }
}
