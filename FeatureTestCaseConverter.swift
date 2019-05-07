import UIKit
import Foundation

var inputList = """
[tester waitForAbsenceOfViewWithAccessibilityIdentifier:@"sometext.id"];
[tester tapViewWithAccessibilityIdentifier:@"sometext.id"];
[tester waitForViewWithAccessibilityIdentifier:@"Asometext.id"];
[tester expectViewWithAccessibilityIdentifier:@"sometext.id" toContainText:@"some value"];
"""

func findDoubleQuoteString(value: String) -> String{
    var count = 1
    var outPutValue = ""
    
    for values in value{
        if values == "\""{
            count = count + 1
        }
        
        if (count % 2 == 0) {
            if values == " "{
                outPutValue.append("_")
            }else{
                outPutValue.append(values)
            }
            
        }else{
            outPutValue.append(values)
        }
    }
    return outPutValue
}


func checkString(value: String) -> String{
    var outPutString: String = ""
    var found = false
    var doubleQuotesString: String = ""
    var lastString = ""
    
    if value.lowercased().contains("identifier"){
        outPutString = "usingIdentifier("
    }
    else if value.lowercased().contains("label"){
        outPutString = "usingLabel("
    }
    
    if value.lowercased().contains("tap"){
        lastString = ")?.waitForTappableView()?.tap()"
    }else if value.contains("AbsenceOfView"){
        lastString = ")?.waitForAbsenceOfView()"
    }else if value.contains("];"){
        lastString = ")?.waitForView()"
    }

    for values in value{
        if found{
            doubleQuotesString.append(values)
        }
        if values == "@"{
            found = true
        }
    }
    
    outPutString = outPutString + doubleQuotesString + lastString
    outPutString = outPutString.replacingOccurrences(of: "];", with: "")
    return outPutString
}

func checkToContains(containString: String) -> String{
    var outPutString: String = ""
    var found = false
    var doubleQuotesString: String = ""
    
    if containString.contains("toContainText"){
        
        for values in containString{
            if found{
                doubleQuotesString.append(values)
            }
            if values == "@"{
                found = true
            }
        }
        
        outPutString = """
            )?.expect(toContainText: \(doubleQuotesString))
            """
    }
    outPutString = outPutString.replacingOccurrences(of: "];", with: "")
    return outPutString
}

func convertToSwift(inputValue: String) -> String{
    var l: [String] = []
    var outputValue: [String] = []
    
    for value in inputValue.split(separator: " "){
        l.append(String(value))
    }
    
    for (index, element) in l.enumerated() {
        if index == 0{
            outputValue.append("tester().")
        }
        if index == 1{
            outputValue.append(checkString(value: element))
        }
        if index == 2{
            outputValue.append(checkToContains(containString: element))
        }
    }
    return outputValue.joined()
}

for value in inputList.split(separator: "\n"){
    print(convertToSwift(inputValue: findDoubleQuoteString(value: String(value))).replacingOccurrences(of: "_", with: " "))
}
