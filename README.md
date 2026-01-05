# PDF Pal 📄

A Flutter application that allows users to upload a PDF file, extract its text locally on the device, and chat with the content using Google's Gemini 2.5 Flash model.

## 🛠️ Features

- **Local PDF Processing**: Extracts text directly on the device using `pdf_text`.
- **Gemini Integration**: Connects directly to the Gemini REST API for fast, context-aware answers.
- **Markdown Support**: Renders rich text (bold, lists, code blocks) in the chat interface.
- **Simple UI**: Clean, easy-to-understand Flutter code suitable for beginners.

## 📦 Gemini CLI Installation (Quick Start)

This project was generated using the **Gemini CLI**, an interactive AI agent for software engineering. To install it:

1. **Install via npm:**

    ```bash
    npm install -g gemini-chat-cli
    ```

2. **Start the agent:**

    ```bash
    gemini-chat-cli
    ```

    *Follow the on-screen instructions to authenticate with your Google account.*

## 🏃‍♂️ How to Run This App

1. **Clone/Open the project:**

    ```bash
    cd pdf_chat_gemini
    ```

2. **Install Dependencies:**

    ```bash
    flutter pub get
    ```

3. **Configure API Key:**
    - Create a `.env` file in the root directory (if not present).
    - Add your Gemini API key:

      ```env
      GEMINI_API_KEY=your_actual_api_key_here
      ```

4. **Run:**

    ```bash
    flutter run
    ```

## 🤖 Prompt Used to Generate This App

```
Generate a complete Flutter project that lets a user upload a PDF, extract its text locally, and chat with the uploaded PDF content using the direct Gemini REST API. Do not use Firebase or firebase_core at all.

Requirements:

1. **User Interface (UI)**
- A main screen with:
  * A button labeled "Upload PDF".
  * A TextField for typing user questions.
  * A "Send" button.
  * A markdown test formatted output from the AI should be there
  * A scrolling chat list showing user messages and AI replies as simple chat bubbles.

2. **PDF Upload and Text Extraction**
- Use the `file_picker` package to let users choose a PDF file.
- Use a Dart/Flutter PDF text extraction package such as `read_pdf_text`, `pdf_text`, or `flutter_pdf_text` to extract text from the PDF file on the device:
  - `read_pdf_text`: easy to use and returns text directly from PDF pages. :contentReference[oaicite:1]{index=1}
  - `pdf_text`: a simple package to convert a PDF into a string. :contentReference[oaicite:2]{index=2}
  - `flutter_pdf_text`: a fork that also supports text extraction on both iOS and Android. :contentReference[oaicite:3]{index=3}
- After extraction, store the text in a variable for use in prompt generation.

3. **Gemini REST API Integration**
- Use the `http` package to call the **Gemini REST API** directly.
- Store the Gemini API key using secure configuration (e.g., `.env` or secure storage) and include it in the Authorization header for API calls.
- Construct a prompt combining the extracted PDF text and the user question.
  Example prompt structure:
    "You are an AI that answers questions based on this PDF. Here is the PDF content: [[PDF_TEXT]]. Question: [[USER_QUESTION]]"
- Send a POST request to the Gemini REST endpoint with the prompt.
- Parse the AI response and show it in the chat UI.
- Use gemini-2.5-flash model strictly

4. **Chat Logic**
- When the user taps "Send":
  * Combine extracted PDF text and user question into one prompt.
  * Call the Gemini REST API.
  * Add the user message and AI response to a chat list that updates on screen.

5. **Code Clarity**
- Keep the code simple and easy to understand for beginner students.
- Use comments to explain how the file picker, PDF extraction, API call, and chat UI work.
- Basic error handling (e.g., show a toast if PDF extraction fails or API call fails).

6. **Output**
- Generate full Flutter source code with widget structure clearly visible.
- Include the **pubspec.yaml** with all necessary dependencies (`file_picker`, one PDF text extraction package, `http`, etc.).
- Ensure the app runs with minimal configuration.

The app should be easy to understand and editable by students. Use the latest stable Flutter version.
```
