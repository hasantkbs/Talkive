import Foundation

class APIService {
    static let shared = APIService() // Singleton
    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    private init() {}

    @MainActor
    func checkServerStatus() async -> Bool {
        do {
            let (_, response) = try await URLSession.shared.data(from: baseURL)
            if let httpResponse = response as? HTTPURLResponse {
                print("APIService: Server responded with status code: \(httpResponse.statusCode)")
                // Any HTTP response means the server is reachable.
                return true
            }
            print("APIService: Server responded, but not an HTTPURLResponse.")
            return false
        } catch {
            print("Server status check failed: \(error.localizedDescription)")
            return false
        }
    }

    func getChatResponse(message: String, language: String) async throws -> String {
        guard let chatURL = URL(string: baseURL.absoluteString + "/chat") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: chatURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": message, "language": language]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return decodedResponse.response
    }
    
    // MARK: - Authentication API Calls (Placeholders)
    
    func login(email: String, password: String) async throws -> AuthResponse {
        // This is a placeholder. In a real app, you'd send a POST request to your /login endpoint.
        // For now, simulate success.
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        if email == "test@example.com" && password == "password" {
            return AuthResponse(token: "mock_auth_token_123", userId: "mock_user_id_1")
        } else {
            throw APIError.custom("Invalid email or password.")
        }
    }
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        // This is a placeholder. In a real app, you'd send a POST request to your /signup endpoint.
        // For now, simulate success.
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        if email.contains("@") && password.count >= 6 {
            return AuthResponse(token: "mock_auth_token_456", userId: "mock_user_id_2")
        } else {
            throw APIError.custom("Invalid email or password (min 6 chars).")
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL was invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .custom(message):
            return message
        }
    }
}

struct ChatResponse: Codable {
    let response: String
}

struct AuthResponse: Codable {
    let token: String
    let userId: String
}
