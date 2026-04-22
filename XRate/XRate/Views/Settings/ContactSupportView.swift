import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    let backendURL = "https://feedback.zzoutuo.com/api/feedback"

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Information") {
                    TextField("Name (optional)", text: $name)
                        .textContentType(.name)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)

                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .overlay {
                            if message.isEmpty {
                                Text("Describe your issue or suggestion...")
                                    .foregroundStyle(.tertiary)
                                    .padding(8)
                            }
                        }
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { submitFeedback() }
                        .disabled(!isValid || isSubmitting)
                }
            }
        }
        .alert("Message Sent", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Thank you for your feedback! We'll get back to you soon.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private var isValid: Bool {
        !email.isEmpty && email.contains("@") && message.count >= 3
    }

    private func submitFeedback() {
        guard isValid else { return }
        isSubmitting = true

        Task {
            do {
                var request = URLRequest(url: URL(string: backendURL)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                struct FeedbackBody: Encodable {
                    let topic: String?
                    let name: String?
                    let email: String
                    let message: String
                }

                let body = FeedbackBody(topic: nil, name: name, email: email, message: message)
                request.httpBody = try JSONEncoder().encode(body)

                let (_, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "FeedbackError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to send"])
                }

                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }

            await MainActor.run {
                isSubmitting = false
            }
        }
    }
}
