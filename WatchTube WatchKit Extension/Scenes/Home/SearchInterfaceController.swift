//
//  SearchInterfaceController.swift
//  WatchTube WatchKit Extension
//
//  Created by llsc12 on 20/02/2022.
//

import WatchKit
import Foundation
import Alamofire

class SearchInterfaceController: WKInterfaceController {
    @IBOutlet weak var searchTermsTableRow: WKInterfaceTable!
    @IBOutlet weak var tableLabel: WKInterfaceLabel!
    @IBOutlet weak var input: WKInterfaceTextField!
    @IBOutlet weak var clearButton: WKInterfaceButton!
    var tableContents: Array<String> = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        input.setRelativeWidth(1, withAdjustment: 0)
        updateSearch(terms: "")
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
            self.tableLabel.setText("Recents")
            // show the recent searches
            let keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
            let lastTwentyKeywordsHistory = Array(keywordsHistory.suffix(20))
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
            let suggestionpath = "https://\(UserDefaults.standard.string(forKey: settingsKeys.instanceUrl) ?? Constants.defaultInstance)/api/v1/search/suggestions?q=\(terms.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
            self.tableLabel.setText("Suggestions")
            self.tableLabel.setHidden(false)
            self.tableContents = []
            self.searchTermsTableRow.setNumberOfRows(1, withRowType: "SearchTermsRow")
            for i in 0 ..< 1 {
                guard let row = self.searchTermsTableRow.rowController(at: i) as? SearchTermsRow else {
                    continue
                }
                row.label.setText(terms)
                row.text = terms
                self.tableContents.append(terms)
            }
            AF.request(suggestionpath) { $0.timeoutInterval = 3 }.validate().responseJSON {res in
                
                switch res.result {
                case .success(let data):
                    let json = data as! Dictionary<String, Any>
                    if json["error"] as? String != nil {print("api is having issues")}
                    let suggestions = json["suggestions"] as! Array<String>
                    
                    self.searchTermsTableRow.setNumberOfRows(suggestions.count, withRowType: "SearchTermsRow")
                    for i in 0 ..< suggestions.count {
                        guard let row = self.searchTermsTableRow.rowController(at: i) as? SearchTermsRow else {
                            continue
                        }
                        row.label.setText(suggestions[i])
                        row.text = suggestions[i]
                        self.tableContents.append(suggestions[i])
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let term = tableContents[rowIndex]
        var keywordsHistory = UserDefaults.standard.stringArray(forKey: preferencesKeys.keywordsHistory) ?? [String]()
        if keywordsHistory.contains(term) {} else {
            keywordsHistory.append(term)
            UserDefaults.standard.set(keywordsHistory, forKey: preferencesKeys.keywordsHistory)
        }
        self.pushController(withName: "VideoListInterfaceController", context: term)
    }
}
