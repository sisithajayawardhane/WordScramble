//
//  ContentView.swift
//  WordScramble
//
//  Created by mac on 2022-06-02.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var score:Int {
        var wordScore =  usedWords.count * 10
        for word in usedWords {
            if word.count > 3 {
                wordScore += (word.count - 3)
            }
        }
//        ForEach(usedWords, id:\.self){ word in
//            if word.count > 3 {
//                wordScore += (word.count - 3)
//            }
//        }
        return wordScore
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self){ word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("Start New game"){
                        usedWords.removeAll()
                        newWord = ""
                        startGame()
                    }
                }
            }
            Text("Score: \(score)").font(.title)
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isBigEnough(word: answer) else {
            wordError(title: "Word is too short", message: "You can't make words less than two letters")
            return
        }
        
        guard isNotRootWord(word: answer) else {
            wordError(title: "Word is same as given word", message: "Try to make a word with its letters")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt form bundle.")
    }
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    func isBigEnough(word:String) -> Bool {
        word.count > 2 ? true : false
    }
    func isNotRootWord(word:String) -> Bool {
        word != rootWord ? true : false
    }
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title:String, message:String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
