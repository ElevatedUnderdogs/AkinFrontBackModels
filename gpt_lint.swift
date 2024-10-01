import Foundation

// Function to send file content to GPT and get error feedback
func sendToGPT(fileContent: String, openAIKey: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
    
    let prompt = "Check the following Swift code for errors and provide line numbers with error messages in JSON format:\n\n\(fileContent)"
    let body: [String: Any] = [
        "model": "gpt-4",
        "prompt": prompt,
        "max_tokens": 1000,
        "temperature": 0.5
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let text = choices.first?["text"] as? String {
            completion(text)
        } else {
            completion(nil)
        }
    }
    task.resume()
}

// Function to post a comment to the PR
func postComment(prNumber: String, comment: String, repo: String, githubToken: String) {
    let url = URL(string: "https://api.github.com/repos/\(repo)/issues/\(prNumber)/comments")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(githubToken)", forHTTPHeaderField: "Authorization")

    let body: [String: Any] = ["body": comment]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
            print("Comment posted successfully.")
        } else {
            print("Failed to post comment.")
        }
    }
    task.resume()
}

// Function to get the list of changed files
func getChangedFiles() -> [String] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["diff", "--name-only", "origin/main"]  // Use 'origin/master'
    
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    return output.split(separator: "\n").map(String.init)
}


// Main function
func main() {
    // Get environment variables
    guard let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
          let githubToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
        print("Missing environment variables.")
        return
    }

    // Rest of your code logic
    let prNumber = "84"  // Replace with your PR number for testing
    let repo = "ElevatedUnderdogs/AkinFrontBackModels"
    
    let changedFiles = getChangedFiles()
    
    for file in changedFiles {
        if FileManager.default.fileExists(atPath: file) {
            let fileContent = try! String(contentsOfFile: file, encoding: .utf8)

            sendToGPT(fileContent: fileContent, openAIKey: openAIKey) { gptFeedback in
                guard let gptFeedback = gptFeedback else {
                    print("Failed to get GPT feedback for \(file)")
                    return
                }
                
                // Create a comment string based on the feedback
                var comment = "### GPT Lint Feedback for \(file):\n"
                comment += gptFeedback
                
                // Post the feedback as a comment on the PR
                postComment(prNumber: prNumber, comment: comment, repo: repo, githubToken: githubToken)
            }
        }
    }
}

// Run the main function
main()

