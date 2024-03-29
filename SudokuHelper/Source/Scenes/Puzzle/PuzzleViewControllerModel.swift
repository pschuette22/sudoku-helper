//
//  PuzzleViewControllerModel.swift
//  SudokuHelper
//
//  Created by Peter Schuette on 7/30/21.
//

import Foundation
import Combine

final class PuzzleViewControllerModel: ViewModel<PuzzleViewControllerState> {
    private var selectedCellLocation: Puzzle.Location?

    convenience init(puzzle: Puzzle) {
        let state = PuzzleViewControllerState(
            puzzleViewState: PuzzleViewState(cells: puzzle.cells, focused: nil)
        )
        self.init(initialState: state)
    }
    
    override init(initialState state: PuzzleViewControllerState) {
        super.init(initialState: state)
    }
}

// MARK: - PuzzleViewDelegate

extension PuzzleViewControllerModel: PuzzleUIViewDelegate {
    func didTapCell(at position: Puzzle.Location) {
        if let selectedCellLocation = selectedCellLocation, position == selectedCellLocation {
            removeGroupHighlighting()
            self.selectedCellLocation = nil
        } else {
            setGroupHighlighting(forCellAt: position)
            selectedCellLocation = position
        }
    }
}

// MARK: - Transactions

extension PuzzleViewControllerModel {
    private func setGroupHighlighting(forCellAt position: Puzzle.Location) {
        // Tapped group position
        let groupMinX = (position.x / 3) * 3
        let groupMaxX = groupMinX + 2
        let groupXRange = groupMinX...groupMaxX
        let groupMinY = (position.y / 3) * 3
        let groupMaxY = groupMinY + 2
        let groupYRange = groupMinY...groupMaxY
        
        let cellStates = state.puzzleViewState.cellStates.enumerated().map { y, cellRowStates in
            cellRowStates.enumerated().map { [y] x, cellState -> CellViewState in
                var modifiedState = cellState
                
                if position == (x: x, y: y) {
                    modifiedState.set(isFocused: true)
                    modifiedState.set(isHighlighted: false)
                } else if
                    x == position.x ||
                        y == position.y ||
                        (groupXRange.contains(x) && groupYRange.contains(y))
                {
                    modifiedState.set(isFocused: false)
                    modifiedState.set(isHighlighted: true)
                } else {
                    modifiedState.set(isFocused: false)
                    modifiedState.set(isHighlighted: false)
                }
                
                return modifiedState
            }
        }
        
        state.set(puzzleCellViewStates: cellStates)        
    }
    
    private func removeGroupHighlighting() {
        let cellStates = state.puzzleViewState.cellStates.enumerated().map { _, cellRowStates in
            cellRowStates.enumerated().map { _, cellState -> CellViewState in
                var modifiedState = cellState
                
                modifiedState.set(isFocused: false)
                modifiedState.set(isHighlighted: false)
                
                return modifiedState
            }
        }
        
        state.set(puzzleCellViewStates: cellStates)
        
    }
}
