import SwiftUI
import IntentsUI // <<-- IMPORTANT: Import IntentsUI

struct ContentView: View {
    @State private var showAddShortcutView = false
    @State private var lastSiriMessage: String = "Ready to log events with Siri."

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(lastSiriMessage)
                    .padding()

                Button("Add 'Log Entry' Shortcut to Siri") {
                    self.showAddShortcutView = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .navigationTitle("Siri Logger V2")
            .sheet(isPresented: $showAddShortcutView) {
                // Pass a closure to dismiss the sheet
                AddVoiceShortcutView {
                    // This closure will be called by AddVoiceShortcutView to dismiss
                    self.showAddShortcutView = false
                }
            }
            .onAppear {
                print("ContentView appeared.")
            }
        }
    }
}

struct AddVoiceShortcutView: UIViewControllerRepresentable {
    // Closure to be called when the sheet should be dismissed
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> INUIAddVoiceShortcutViewController {
        let intent = LogV2Intent()
        intent.suggestedInvocationPhrase = "Log my entry"

        // Create the INShortcut. Handle potential nil if intent isn't shortcut-eligible.
        guard let shortcut = INShortcut(intent: intent) else {
            // This should ideally not happen for a valid custom intent.
            // Return a placeholder or handle error appropriately.
            // For simplicity, returning an empty controller, but you might want
            // to show an alert or log this error.
            print("Error: Could not create INShortcut from LogV2Intent.")
            // A real app might have a fallback UI or error handling here.
            // For now, to satisfy the return type, we provide a basic INUIAddVoiceShortcutViewController.
            // This path indicates a problem with the intent's shortcut eligibility.
            let dummyIntent = INIntent() // Generic intent
            let dummyShortcut = INShortcut(intent: dummyIntent)! // Force unwrap for dummy case
            return INUIAddVoiceShortcutViewController(shortcut: dummyShortcut)
        }

        let addVoiceShortcutVC = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addVoiceShortcutVC.delegate = context.coordinator
        return addVoiceShortcutVC
    }

    func updateUIViewController(_ uiViewController: INUIAddVoiceShortcutViewController, context: Context) {
        // Nothing to update here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onDismiss: onDismiss)
    }

    class Coordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
        var parent: AddVoiceShortcutView
        var onDismiss: () -> Void // Store the dismiss closure

        init(_ parent: AddVoiceShortcutView, onDismiss: @escaping () -> Void) {
            self.parent = parent
            self.onDismiss = onDismiss
        }

        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            if let error = error {
                print("Error adding voice shortcut: \(error.localizedDescription)")
            } else if let voiceShortcut = voiceShortcut {
                print("Successfully added voice shortcut: \(voiceShortcut.invocationPhrase)")
            } else {
                print("User might have edited an existing shortcut or other non-add scenario.")
            }
            controller.dismiss(animated: true, completion: nil)
            self.onDismiss() // Call the closure to update ContentView's state
        }

        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            print("User cancelled adding voice shortcut from delegate.")
            controller.dismiss(animated: true, completion: nil)
            self.onDismiss() // Call the closure to update ContentView's state
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
