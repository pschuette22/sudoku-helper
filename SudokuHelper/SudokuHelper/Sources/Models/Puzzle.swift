//
//  Puzzle.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import CoreGraphics

struct Puzzle: Equatable {
    typealias Location = (x: Int, y: Int)
    
    let cells: [[Cell]]
    private(set) var verticalLines = [Line]()
    private(set) var horizontalLines = [Line]()
    private(set) var squares = [Square]()
    private static let validValues = Set<Int>(1...9)
    
    init(values: [[Int]]) {
        let cells = values.map {
            $0.map { value in
                Self.validValues.contains(value) ? Cell(value: value, isPredefined: true) : Cell()
            }
        }
        self.init(cells: cells)
    }
    
    
    init(cells: [[Cell]]) {
        // Setup the horizontal lines
        self.cells = cells
        for line in cells {
            let horizontalLine = Line(.horizontal, cells: line)
            horizontalLines.append(horizontalLine)
            horizontalLine.remove(possibilities: horizontalLine.solvedValues)
        }
        
        // Setup the vertical lines
        for i in 0..<9 {
            let verticalCells = cells.map { $0[i] }
            let verticalLine = Line(.vertical, cells: verticalCells)
            verticalLines.append(verticalLine)
            verticalLine.remove(possibilities: verticalLine.solvedValues)
        }
        
        // Setup the squares
        for x in 0..<3 {
            for y in 0..<3 {
                var squareCells = [[Cell]]()
                for yOffset in 0..<3 {
                    squareCells.append(Array(cells[(y*3)+yOffset][x*3...(x*3+2)]))
                }
                let square = Square(arrangedCells: squareCells)
                squares.append(square)
                square.remove(possibilities: square.solvedValues)
            }
        }
    }
}

// MARK: - Access Control
extension Puzzle {
    func cell(at location: Location) -> Cell {
        self.cells[location.y][location.x]
    }
}

// MARK: - Puzzle Factory
extension Puzzle {
    static var new: Puzzle {
        var cells = [[Cell]]()
        for _ in 0..<9 {
            var line = [Cell]()
            for _ in 0..<9 {
                line.append(Cell())
            }
            cells.append(line)
        }
        return Puzzle(cells: cells)
    }
}

// MARK: - Printing
extension Puzzle {
    private static let printDivider = "+---+---+---+"
    
    @discardableResult
    func print() -> String {
    
        var result = "\n"
        result.append(Self.printDivider)
        for i in 0..<horizontalLines.count {
            var printLine = "|"
            for j in 0..<3 {
                printLine.append(
                    horizontalLines[i].cells[(3*j)...(3*j)+2].reduce(into: "", { $0.append($1.printValue()) })
                )
                printLine.append("|")
            }
            result.append("\n")
            result.append(printLine)
            
            if i%3 == 2 {
                result.append("\n")
                result.append(Self.printDivider)
            }
        }
        Swift.print(result)
        return result
    }
}
