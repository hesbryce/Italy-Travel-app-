//
//  ContentView.swift
//  KMB
//
//  Created by Bryce Ellis on 7/4/25.
//

import SwiftUI
import AVFoundation

struct Phrase: Identifiable, Codable, Equatable {
    let id: UUID
    let label: String
    let translation: String
    let pronunciation: String
}

struct ContentView: View {
    // MARK: - Storage
    @AppStorage("orderedPhrases") private var storedPhrasesData: Data = Data()
    
    // MARK: - State
    @State private var directions: [Phrase] = []
    @State private var isExpanded = false

    // MARK: - Default Phrases (used if no saved order yet)
    private let defaultDirections: [Phrase] = [
        Phrase(id: UUID(), label: "Left", translation: "Sinistra", pronunciation: "See-nee-strah"),
        Phrase(id: UUID(), label: "Right", translation: "Destra", pronunciation: "Deh-strah"),
        Phrase(id: UUID(), label: "Straight", translation: "Dritto", pronunciation: "Dree-toh"),
        Phrase(id: UUID(), label: "Turn", translation: "Gira", pronunciation: "Jee-rah"),
        Phrase(id: UUID(), label: "Stop", translation: "Fermati", pronunciation: "Fehr-mah-tee"),
        Phrase(id: UUID(), label: "Go", translation: "Vai", pronunciation: "Vye"),
        Phrase(id: UUID(), label: "Slow down", translation: "Rallenta", pronunciation: "Rahl-lehn-tah"),
        Phrase(id: UUID(), label: "Speed limit", translation: "Limite di velocità", pronunciation: "Lee-mee-teh dee veh-loh-chee-tah"),
        Phrase(id: UUID(), label: "Up", translation: "Su", pronunciation: "Soo"),
        Phrase(id: UUID(), label: "Down", translation: "Giù", pronunciation: "Joo")
    ]

    var body: some View {
        NavigationView {
            List {
                Section {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        ForEach(directions) { phrase in
                            PhraseRow(
                                phrase: phrase,
                                onSpeak: { speak(phrase.translation) }
                            )
                        }
                        .onMove(perform: move)

                        // Collapse button at bottom
                        Button("Collapse") {
                            withAnimation { isExpanded = false }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        .foregroundColor(.blue)
                    } label: {
                        Text("🧭 Directions")
                            .font(.headline)
                            .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Italy Phrases")
            .toolbar {
                EditButton()
            }
            .onAppear {
                directions = loadStoredPhrases() ?? defaultDirections
            }
        }
    }

    // MARK: - Reorder + Save
    private func move(from source: IndexSet, to destination: Int) {
        directions.move(fromOffsets: source, toOffset: destination)
        savePhrases()
    }

    private func savePhrases() {
        if let data = try? JSONEncoder().encode(directions) {
            storedPhrasesData = data
        }
    }

    private func loadStoredPhrases() -> [Phrase]? {
        guard let decoded = try? JSONDecoder().decode([Phrase].self, from: storedPhrasesData),
              !decoded.isEmpty else {
            return nil
        }
        return decoded
    }

    // MARK: - Text-to-Speech
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        utterance.rate = 0.45
        AVSpeechSynthesizer().speak(utterance)
    }
}

// MARK: - Phrase Row
struct PhraseRow: View {
    let phrase: Phrase
    var onSpeak: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(phrase.label)
                    .font(.body)
                Text("\(phrase.translation) • \(phrase.pronunciation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onSpeak) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
