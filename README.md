# Cases
A macOS status bar application that allows you to convert between different cases: lower, upper, title. 

When you launch the application, a new item shows on the status bar, with an icon "Aa". When you click on it, you see this:

![ScreenShot](/images/opening_screenshot.png "Opening Screenshot")

Clicking on the individual buttons shows you the _converted_ text in the bottom textview. 

This isn't the prettiest thing in the world, but it was done in one evening after I got tired of fixing/standardising titles. I first attempted to do this using AppleScript, but it kept crashing on me and I didn't quite understand the syntax so decided to write this instead. 

## Technology and testing 

This application has been developed using Xcode 8.2.1 and Swift 3 on macOS 10.12.1. 

## Usage

The "To Upper" and "To Lower" buttons are fairly self-explanatory. The "To Title" less so. 

The rules triggered by the "To Title" action are predominantly based on the AP Styleguide along with some tweaks based on [this](http://daringfireball.net/2008/05/title_case).

These are as follows: 

- We assume that, for the most part, the words are properly formed, i.e. this doesn't support words that are randomly capitalised (e.g. "wIntER")
- All conjunctions and prepositions are lower-cased unless they're more than four characters long (don't ask me; that's what the AP says) 
- The first word and the last word are always camel-cased or capitalised
  - "camel-cased" refers to words like "macOS" or "iPhone"; 
  - "capitalised" refers to the first letter of the word being in upper case and the rest in lower
- Hyphenated (Compound) words are always capitalised (e.g. band-aid, state-of-the-art)
- If a "word" has a dot (or multiple dots) in it, nothing changes. e.g. "apple.com" or "i.e."
- The first word of a quote is always capitalised (only the first character of the word, if you want to be pedantic)
- The first word after an end mark (".", "!", "?") is always capitalised
- The first word after a colon (":") is always capitalised
- Articles ("a", "the", "an") are always in lowercase
- There is a set of words that should always be capitalised (an empty set at the moment) and a set of words that should always be in lower case (current entries: "is", "to")
- It always uses smartquotes
