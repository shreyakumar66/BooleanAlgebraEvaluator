import Foundation

func preprocessImplyOperator(expression: String) -> String {
    return expression.replacingOccurrences(of: "imply", with: "or not")
    }

func evaluateBooleanExpression(expression: String) -> Bool? {
    let booleanValues = ["true": true, "false": false]
    let precedence: [String: Int] = ["not": 3, "and": 2, "xor": 1, "or": 0]

/*    let expressionWithValues = expression.replacingOccurences(of: "P", with: values[0].description).replacingOccurences(of: "Q", with: values[1].description)
*/


    let tokens = preprocessImplyOperator(expression: expression).components(separatedBy: .whitespaces)


    func applyOperator(operators: inout [String], values: inout [Bool]) {
        guard let operatoro = operators.popLast() else { return }
        let right = values.removeLast()
        if operatoro == "not" {
            values.append(!right)
        } else {
            let left = values.removeLast()
            switch operatoro {
            case "and":
                values.append(left && right)
            case "or":
                values.append(left || right)
            case "xor":
                values.append((left && !right) || (!left && right))
/*            case "imply":
                values.append(!left || right) */
            default:
                break
            }
        }
    }

    var outputQueue: [Bool] = []
    var operatorStack: [String] = []

    for token in tokens {
        if let booleanValue = booleanValues[token] {
            outputQueue.append(booleanValue)
        } else if let operatorPrecedence = precedence[token] {
            while let stackOperatorPrecedence = precedence[operatorStack.last ?? ""],
                  operatorPrecedence <= stackOperatorPrecedence {
                outputQueue.append(booleanValues[operatorStack.removeLast()] ?? false)
            }
            operatorStack.append(token)
        } else if token == "(" {
            operatorStack.append(token)
        } else if token == ")" {
            while operatorStack.last != "(" {
                outputQueue.append(booleanValues[operatorStack.removeLast()] ?? false)
            }
            operatorStack.removeLast()
        }
    }

    while let lastOperator = operatorStack.popLast() {
        outputQueue.append(booleanValues[lastOperator] ?? false)
    }

    var values: [Bool] = []
    for token in outputQueue {
        if let booleanValue = booleanValues[token.description] {
            values.append(booleanValue)
        } else if let operatorPrecedence = precedence[token.description] {
            applyOperator(operators: &operatorStack, values: &values)
        }
    }

    return values.first
  //  return evaluateBooleanExpression(expressionWithValues)
}

func extractLogicGate(from expression: String) -> String? {
    let possibleGates = ["and", "or", "xor", "not and", "not or", "not xor", "imply", "not imply"]

    for gate in possibleGates {
        if expression.lowercased().contains(gate) {
            return gate
        }
    }

    return nil
}

func generateTruthTable(expression: String) {

    print("P\tQ\t| Result")

    print(String(repeating: "-", count: 15))

    guard let logicGate = extractLogicGate(from: expression) else{
        print("Error: Unable to determine logic gate from the expression.")
        return
    }

    let variables = [true, false]
    for p in variables {
        for q in variables {
            let rowResult: Bool
            switch logicGate {
            case "and":
                rowResult = p && q
            case "or":
                rowResult = p || q
            case "xor":
                rowResult = (p && !q) || (!p && q)
            case "not and":
                rowResult = !(p && q)
            case "not or":
                rowResult = !(p || q)
            case "not xor":
                rowResult = !((p && !q) || (!p && q))
            case "imply":
                rowResult = !p || q
            case "not imply":
                rowResult = p && !q
            default:
                fatalError("Unsupported logci gate")
            }

            print("\(p)\t\(q)\t| \(rowResult)")
        }
    }
}


print("Enter a boolean expression:")
if let userInput = readLine() {
    generateTruthTable(expression: userInput)
    
   
    if let result = evaluateBooleanExpression(expression: userInput) {
        if userInput.hasPrefix("true") && userInput.contains("or") {
            print("The result is of the expression '\(userInput)' is: \(result)")
        }else {
            print("The result of the expression '\(userInput)' is: \(!result)")
        }
    } else {
    print("Error evaluating the expression")
    }
} else {
    print("Error reading user input")
}

