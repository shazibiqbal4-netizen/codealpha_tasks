# Flashcard Quiz App

A simple, clean flashcard app for studying, built with **SwiftUI**.
Developed as **Task 1** of the CodeAlpha App Development Internship.

## Features
- Question on the front, answer on the back, with a **Show Answer** button (flip animation)
- **Next** / **Previous** navigation with a "Card X of Y" counter
- **Add, edit and delete** flashcards
- Cards are saved on the device (UserDefaults), so they persist between launches
- Empty state screen when there are no cards

## Tech Stack
- Swift, SwiftUI
- UserDefaults + Codable for local storage

## Project Structure
| File | Purpose |
|------|---------|
| `FlashcardQuizApp.swift` | App entry point |
| `Flashcard.swift` | Data model |
| `FlashcardStore.swift` | Add / update / delete logic and saving |
| `ContentView.swift` | Study screen and flip card |
| `CardEditorView.swift` | Add / edit screen |

## How to Run
1. Open the project in Xcode (iOS 16 or later)
2. Select a simulator or device
3. Press **Run** (⌘R)

## Author
M Shazib Iqbal — CodeAlpha App Development Intern
