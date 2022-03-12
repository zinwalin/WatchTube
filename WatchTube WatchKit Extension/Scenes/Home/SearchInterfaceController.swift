//
//  SearchInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 20/02/2022.
//

import WatchKit
import Foundation
import Alamofire
import SwiftUI

class SearchInterfaceController: WKInterfaceController {
    @IBOutlet weak var searchTermsTableRow: WKInterfaceTable!
    @IBOutlet weak var tableLabel: WKInterfaceLabel!
    @IBOutlet weak var input: WKInterfaceTextField!
    @IBOutlet weak var clearButton: WKInterfaceButton!
    var tableContents: Array<String> = []
    
    override func willActivate() {
        super.willActivate()
        input.setRelativeWidth(1, withAdjustment: 0)
        updateSearch(terms: "")
        input.setText("")

    }


    @IBAction func ClearField() {
        input.setText("")
        input.setRelativeWidth(1, withAdjustment: 0)
        updateSearch(terms: "")
    }
    @IBAction func SearchFieldEdited(_ value: NSString?) {
        let terms = value as String? ?? ""
        updateSearch(terms: terms)
        if terms != "" {
            input.setRelativeWidth(0.9, withAdjustment: 0)
        } else {
            input.setRelativeWidth(1, withAdjustment: 0)
        }
    }

    func updateSearch(terms: String) {
        if terms == "" {
            // the terms is empty so we just show the recents also why tf dont dis update positions in the table pls help
            
            self.tableLabel.setText("Recents")
            // show the recent searches
            
            let keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
            var lastTwentyKeywordsHistory = Array(keywordsHistory.suffix(20))
            lastTwentyKeywordsHistory = lastTwentyKeywordsHistory.reversed()
            tableContents = []
            searchTermsTableRow.setNumberOfRows(lastTwentyKeywordsHistory.count, withRowType: "SearchTermsRow")
            for i in 0 ..< lastTwentyKeywordsHistory.count {
                guard let row = searchTermsTableRow.rowController(at: i) as? SearchTermsRow else {
                    continue
                }
                row.label.setText(lastTwentyKeywordsHistory[i])
                row.text = lastTwentyKeywordsHistory[i]
                tableContents.append(lastTwentyKeywordsHistory[i])
            }
            if lastTwentyKeywordsHistory.count == 0 {
                self.tableLabel.setHidden(true)
            } else {
                self.tableLabel.setHidden(false)
            }
            
        } else {
            // get search queries
            
            let suggestionpath = "https://suggestqueries-clients6.youtube.com//complete/search?client=youtube&hl=en&gl=\(Locale.current.regionCode ?? "en")&q=\(terms.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&xssi=t&gs_ri=youtube&ds=yt"
            self.tableLabel.setText("Suggestions")
            self.tableLabel.setHidden(false)
            self.searchTermsTableRow.setNumberOfRows(1, withRowType: "SearchTermsRow")
            self.tableContents = []
            for i in 0 ..< 1 {
                guard let row = self.searchTermsTableRow.rowController(at: i) as? SearchTermsRow else {
                    continue
                }
                row.label.setText(terms)
                row.text = terms
                self.tableContents.append(terms)
            }
            AF.request(suggestionpath) { $0.timeoutInterval = 3 }.validate().responseString {res in
                
                switch res.result {
                case .success(let string):
                    do {
                        let manipulated = String(string.dropFirst(5))
                        let data = Data(manipulated.utf8)
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? Array<Any> {
                            // try to read out a string array
                            let parsed = json[1] as? Array<Any> ?? []
                            var suggestions = parsed
                            for (i, item) in suggestions.enumerated() {
                                let suggestion = item as! Array<Any>
                                suggestions[i] = suggestion[0] as! String
                            }
                            suggestions = suggestions.suffix(9)
                            suggestions.insert(json[0] as! String, at: 0)
                            self.tableContents = []
                            self.searchTermsTableRow.setNumberOfRows(suggestions.count, withRowType: "SearchTermsRow")
                            for i in 0 ..< suggestions.count {
                                guard let row = self.searchTermsTableRow.rowController(at: i) as? SearchTermsRow else {
                                    continue
                                }
                                row.label.setText((suggestions[i] as! String))
                                row.text = (suggestions[i] as! String)
                                self.tableContents.append(suggestions[i] as! String)
                            }
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let table = tableContents
        let term = table[rowIndex]
        var keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
        var lastTwentyKeywordsHistory = Array(keywordsHistory.suffix(20))
        lastTwentyKeywordsHistory = lastTwentyKeywordsHistory.reversed()
        if tableContents == lastTwentyKeywordsHistory {
            let oldPlace = lastTwentyKeywordsHistory.firstIndex(of: term)!
            
            lastTwentyKeywordsHistory.remove(at: oldPlace)
            lastTwentyKeywordsHistory.insert(term, at: 0)
            updateSearch(terms: "")
        } else {
            if keywordsHistory.contains(term) {} else {
                keywordsHistory.append(term)
                UserDefaults.standard.set(keywordsHistory, forKey: preferencesKeys.keywordsHistory)
            }
        }
        
        self.pushController(withName: "VideoListInterfaceController", context: term)
    }
}
