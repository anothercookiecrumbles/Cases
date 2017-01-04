//
//  PopoverViewController.swift
//  Cases
//
//  Created by Priyanjana Bengani on 1/3/17.
//  Copyright © 2017 anothercookiecrumbles. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController, NSTextViewDelegate{
    
    @IBOutlet var convertableTextView: NSTextView!
    @IBOutlet var convertedTextView: NSTextView!
    
    // Bunch of variables set up for `convertToTitle`
    let whitespaceSet = NSCharacterSet.whitespaces
    let articles: Set<String> = ["A", "the", "an"]
    let alwaysCapitalise: Set<String> = []
    let alwaysLowercase: Set<String> = ["is"]
    let endMarks: Set<Character> = ["!", "?", "."]
    
    // Regex for words which have a capital letter _inside_; e.g. macOS, iOS, etc.
    // Ignores the first character when it looks for upper-cased characters in word.
    let specialCapitalizationRegex = "..*[A-Z]+.*"
    var capitalizationPredicate: NSPredicate!
    
    // Regex for words with dots in them. e.g. urls (...but also ignoring end of word dots,
    // which would typically suggest that it's a fullstop.
    let dotRegex = "^[^ ]*\\.[^ ]*.$"
    var dotPredicate: NSPredicate!
    
    // Check parts of speech (sorry, english only)
    let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
    let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
    var tagger: NSLinguisticTagger!
    
    override func viewWillAppear() {
        clear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Initialise the predicates that'll be needed to check for camel-cased words and words with dot(s).
        capitalizationPredicate = NSPredicate(format: "SELF MATCHES %@", specialCapitalizationRegex)
        dotPredicate = NSPredicate(format: "SELF MATCHES %@", dotRegex)
        
        // Initialise the LinguisticTagger so that we can identify parts of speech.
        tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        
        // Yeah, this is a bit crummy but for some reason, NSTextView doesn't support placeholder values. 
        // I know, I know, I should add it manually.
        convertableTextView.string = ""
        
        // Ensure that the textview that shows the _converted_ text is read-only but users can select the text (mostly 
        // so that they can copy it).
        convertedTextView.isEditable = false
        convertedTextView.isSelectable = true
        convertedTextView.string = "Converted text appears here." // default boring string; should've been as a placeholder but... sigh
    }
    
    // Convert using the AP stylebook guidelines:
    // - Capitalize the principal words, including prepositions and conjunctions of four or more letters.
    // - Capitalize an article – the, a, an – or words of fewer than four letters if it is the first or
    // last word in a title.
    @IBAction func convertToTitle(_ sender: Any) {
        let convertable = convertableTextView.string
        
        // Keep local set of conjunctions and prepositions
        var lowercasable: Set<String> = []
        
        // First, let's get the parts-of-speech tags
        tagger.string = convertable
        tagger.enumerateTags(in: NSMakeRange(0, (NSString(string:convertable!)).length), scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            let token = (NSString(string:convertable!)).substring(with: tokenRange)
            if (tag == "Preposition" || tag == "Conjunction") {
                lowercasable.insert(token)
            }
        }
        
        let scanner = Scanner(string: convertable!)
        scanner.caseSensitive = true
        
        var final = [String]()
        
        while !scanner.isAtEnd {
            // Get word by continuously scanning until we hit whitespace or end of line.
            var extracted: NSString? = nil
            scanner.scanUpToCharacters(from: whitespaceSet, into: &extracted)
            
            // cast to string that has some nicer, higher-level functions
            var word = extracted as? String
            
            if (word != nil) {
                // trim spaces
                word = word?.trimmingCharacters(in: whitespaceSet)
                
                // Do not change words that have any character in upper-case _inside_ the word,
                // i.e. any word where there are capital letters that aren't the first character.
                // This will ensure we don't break words like macOS, iOS etc. 
                if (capitalizationPredicate.evaluate(with: word)) {
                    print("Continuing after capitalisation predicate matched")
                }
                // Splitting out as it's easier to debug.
                else if (dotPredicate.evaluate(with: word)) {
                    print("Continuing after dot predicate matched.")
                }
                // Always title-case the first word and the last word
                else if (final.isEmpty || scanner.isAtEnd) {
                    word = word?.capitalized
                }
                // Always capitalize the first word of a quote
                else if (word!.characters.first == "\"") {
                    word = word!.capitalized
                }
                // Always capitalize articles
                else if (articles.contains(word!.lowercased())) {
                    word = word!.capitalized
                }
                // Always capitalize words in `alwaysCapitalize` set
                else if (alwaysCapitalise.contains(word!)) {
                    word = word!.capitalized
                }
                // Always lower-case words in `alwaysLowercase` set
                else if (alwaysLowercase.contains(word!)) {
                    word = word!.lowercased()
                }
                // Lower-case prepositions and conjunctions unless they're >= 4 characters
                else if (lowercasable.contains(word!) && word!.characters.count < 4) {
                    word = word!.lowercased()
                }
                // This is probably OK? :/
                else {
                    word = word!.capitalized
                }
                
                // Always capitalize words after end-of-sentence punctuation marks.
                if (!final.isEmpty){
                    // get last item from the final array
                    if (endMarks.contains((final.last?.characters.last)!)) {
                        word = word!.capitalized
                    }
                }
                
                // Add word to array, which will eventually be converted to a string.
                final.append(word!)
            }
        }
        
        // And finally show the converted text in the display. 
        convertedTextView.string = final.joined(separator: " ")
    }
    
    // Clears the NSTextViews so that each time you open the app it's clean.
    func clear() {
        convertedTextView.string = "Converted text appears here."
        convertableTextView.string = ""
    }
    
    // Converts text to lower case (blindly) and displays it in the bottom NSTextView.
    @IBAction func convertToLower(_ sender: Any) {
        let convertable = convertableTextView.string
        convertedTextView.string = convertable?.lowercased()
    }
    
    // Blindly converts text to upper case and displays the converted text in the bottom NSTextView.
    @IBAction func convertToUpper(_ sender: Any) {
        let convertable = convertableTextView.string
        convertedTextView.string = convertable?.uppercased()
    }
    
}
