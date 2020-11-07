//
//  MUTableControl.swift
//
//  Created by Dmitry Smirnov on 01/02/2019.
//  Copyright © 2019 MobileUp LLC. All rights reserved.
//

import UIKit

// MARK: - MUTableControl

open class MUTableControl: NSObject {
    
    // MARK: - Event
    
    public enum Event {
        
        case move, insert, delete, update
    }
    
    // MARK: - Public properties
    
    open weak var controller: MUListController?
    
    open weak var delegate: MUListControlDelegate?
    
    open weak var tableView: UITableView?
    
    open var hasSections: Bool = false
    
    open var isAnimated: Bool = true
    
    open var animationStyle: UITableView.RowAnimation = .fade
    
    open var objects: [MUModel] = [] { didSet { updateObjects() } }
    
    // MARK: - Private properties
    
    private var sections: [String] = []
    
    private var groupedObjects: [[MUModel]] = []
    
    private var oldSections: [String] = []
    
    private var oldGroupedObjects: [[MUModel]] = []
    
    private var reservedCells: [ReserveCell] = []
    
    // MARK: - ReserveCell
    
    public struct ReserveCell {
        
        var posision: Int?
        
        var beforeCell: String? = nil
        
        var afterCell: String? = nil
        
        var alternativeCell: String? = nil
        
        let id: String
    }
    
    // MARK: - Public methods
    
    open func setup(with controller: MUListController) {
        
        tableView = controller.tableView
        
        tableView?.delegate = self
        
        tableView?.dataSource = self
        
        delegate = controller
        
        self.controller = controller
    }
    
    private func getIndexPath(row: Int?, section: Int? = nil) -> IndexPath {
        
        return IndexPath(row: row ?? 0, section: section ?? 0)
    }
    
    open func getCell(withId id: String) -> UITableViewCell? {
        
        guard let visibleCells = tableView?.visibleCells else { return nil }
        
        return visibleCells.filter { $0.reuseIdentifier ?? "" == id }.first
    }
    
    open func getCell(for object: MUModel?) -> UITableViewCell? {
        
        guard let object = object, let visibleCells = tableView?.visibleCells else { return nil }
        
        for cell in visibleCells {
            
            guard let cell = cell as? MUTableCell, let cellObject = cell.object else {
                
                continue
            }
            
            if cellObject == object {
                
                return cell
            }
        }
        
        return nil
    }
    
    open func getIndex(for targetObject: MUModel, in objects: [MUModel]? = nil) -> Int? {
        
        for (index,object) in (objects ?? self.objects).enumerated() {
            
            if object.primaryKey == targetObject.primaryKey {
                
                return index
            }
        }
        
        return nil
    }
    
    open func getIndexPath(for targetObject: MUModel, in objects: [[MUModel]]? = nil) -> IndexPath? {
        
        for (section,objects) in (objects ?? groupedObjects).enumerated() {
            
            for (row,object) in objects.enumerated() {
                
                if object.primaryKey == targetObject.primaryKey {
                    
                    return IndexPath(row: row, section: section)
                }
            }
        }
        
        return nil
    }
    
    open func didSelectRow(cell: MUTableCell, at index: IndexPath) {
        
    }
    
    open func getSection(for object: MUModel) -> String {
        
        return delegate?.getSection(for: object) ?? ""
    }
    
    open func reloadObjects(animated: Bool = true) {
        
        if animated {
            
            updateObjects()
        } else {
            tableView?.reloadData()
        }
    }
    
    open func updateObjects() {
        
        oldSections = self.sections
        
        oldGroupedObjects = self.groupedObjects
        
        groupObjects()
        
        delegate?.objectDidChanged(with: objects)
    }
    
    open func reservePosition(
        
        at position    : Int?     = nil,
        before         : String?  = nil,
        after          : String?  = nil,
        or alternative : String?  = nil,
        forCell id     : String
    
    ) {
        
        reservedCells.append(ReserveCell(
            
            posision        : position,
            beforeCell      : before,
            afterCell       : after,
            alternativeCell : alternative,
            id              : id
        ))
    }
    
    open func removeReserve(forCell id: String) {
        
        reservedCells = reservedCells.filter { $0.id != id }
    }
    
    open func removeReserve(at position: Int) {
        
        reservedCells = reservedCells.filter { $0.posision == position }
    }
    
    open func removeAllReserve() {
        
        reservedCells.removeAll()
    }
    
    private func findReservedCell(position: Int) -> ReserveCell? {
        
        return reservedCells.filter { $0.posision == position }.first
    }
    
    // MARK: - Private methods
    
    private func updateSections(with oldSections: [String]) {
        
        var sectionsToDelete: [String] = oldSections
        
        for (newIndex,newSection) in sections.enumerated() {
            
            guard let index = oldSections.firstIndex(of: newSection) else {
                
                changeSection(at: newIndex, for: .insert)
                
                continue
            }
            
            if index != newIndex {
                
                changeSection(at: newIndex, for: .move)
            }
            
            if let deleteIndex = sectionsToDelete.firstIndex(of: newSection) {
                
                sectionsToDelete.remove(at: deleteIndex)
            }
        }
        
        for section in sectionsToDelete {
            
            guard let index = oldSections.firstIndex(of: section)  else { continue }
            
            changeSection(at: index, for: .delete)
        }
    }
    
    private func updateGroupedObjects(with oldGroupedObjects: [[MUModel]]) {
        
        var objectsToDelete: [[MUModel]] = oldGroupedObjects
        
        for (newSection,newObjects) in groupedObjects.enumerated() {
            
            for (newRow,newObject) in newObjects.enumerated() {
                
                let newIndexPath = IndexPath(row: newRow, section: newSection)
                
                guard let oldIndexPath = getIndexPath(for: newObject, in: oldGroupedObjects) else {
                    
                    changeRow(at: newIndexPath, for: .insert)
                    
                    continue
                }
                
                if oldIndexPath == newIndexPath {
                    
                    if delegate?.isObjectChanged(for: newObject) ?? false {
                        
                        changeRow(from: oldIndexPath, at: newIndexPath, for: .update)
                    } else {
                        updateRow(at: oldIndexPath, with: newObject)
                    }
                }
                
                if oldIndexPath != newIndexPath {
                    
                    changeRow(from: oldIndexPath, at: newIndexPath, for: .move)
                    
                    updateRow(at: oldIndexPath, with: newObject)
                }
                
                if let indexPath = getIndexPath(for: newObject, in: objectsToDelete) {
                    
                    objectsToDelete[indexPath.section].remove(at: indexPath.row)
                }
            }
        }
        
        for (_,objects) in objectsToDelete.enumerated() {
            
            for (_,object) in objects.enumerated() {
                
                if let indexPath = getIndexPath(for: object, in: oldGroupedObjects) {
                    
                    changeRow(from: indexPath, for: .delete)
                }
            }
        }
    }
    
    private func changeRow(from oldIndex: IndexPath? = nil, at index: IndexPath? = nil, for type: Event) {
        
        switch type {
        case .insert : tableView?.insertRows(at: [index!], with: animationStyle)
        case .update : tableView?.reloadRows(at: [oldIndex!], with: animationStyle)
        case .delete : tableView?.deleteRows(at: [oldIndex!], with: animationStyle)
        case .move   : tableView?.moveRow(at: oldIndex!, to: index!)
        }
    }
    
    private func changeSection(at index: Int, for type: Event) {
        
        switch type {
        case .insert : tableView?.insertSections([index], with: .top)
        case .delete : tableView?.deleteSections([index], with: .top)
        case .update : tableView?.reloadSections([index], with: .none)
        default      : break
        }
    }
    
    private func updateRow(at indexPath: IndexPath, with newObject: MUModel) {
        
        (tableView?.cellForRow(at: indexPath) as? MUTableCell)?.setup(sender: controller)
        
        (tableView?.cellForRow(at: indexPath) as? MUTableCell)?.setup(with: newObject, sender: controller)
    }
    
    private func checkAreDuplicateKeysExist(objects: [MUModel]) -> Bool {
                
        let primaryKeys = objects.map { $0.primaryKey }

        if objects.count != Set(primaryKeys).count {

            return true
        }
        
        return false
    }
    
    private func groupObjects() {
        
        if hasSections {
            
            groupObjectsWithSections()
            
        } else {
            
            groupedObjects = [objects]
            
            sections = [""]
        }
        
        addReserveCells()
        
        updateTable(animated: isAnimated)
    }
    
    private func groupObjectsWithSections() {
        
        var groupedObjects: [[MUModel]] = []
        
        var sections: [String] = []
        
        for object in objects {
            
            let section = getSection(for: object)
            
            if !sections.contains(section) {
                
                sections.append(section)
                
                groupedObjects.append([object])
                
                continue
            }
            
            groupedObjects[sections.firstIndex(of: section)!].append(object)
        }
        
        self.sections = sections
        
        self.groupedObjects = groupedObjects
    }
    
    private func addReserveCells() {
        
        guard reservedCells.count > 0 else { return }
        
        if groupedObjects.count == 0 {
            
            groupedObjects = [[]]
        }
        
        for cell in reservedCells {
            
            guard cell.afterCell == nil && cell.beforeCell == nil else { continue }
            
            addReserveCell(with: cell)
        }
        
        for (index,cell) in reservedCells.enumerated() {
            
            var position: Int?
            
            if let before = cell.beforeCell {
                
                position = findPosition(for: before, or: cell.alternativeCell, last: false)
            }
            
            if let after = cell.afterCell {
                
                position = findPosition(for: after, or: cell.alternativeCell, last: true)
            }
            
            if let position = position {
                
                reservedCells[index].posision = position
                
                addReserveCell(with: reservedCells[index])
            }
        }
    }
    
    private func findPosition(for targetCell: String, or alternativeCell: String? = nil, last: Bool) -> Int? {
        
        var returnFirstDifferent: Bool = false
        
        var reserveCell = reservedCells.first(where: { $0.id == targetCell })
        
        if reserveCell == nil {
            
            reserveCell = reservedCells.first(where: { $0.id == alternativeCell })
        }
        
        if reserveCell != nil {
            
            if last {
                
                return (reserveCell?.posision ?? 0) + 1
            } else {
                return (reserveCell?.posision ?? 0)
            }
        }
        
        for (row, object) in groupedObjects[0].enumerated() {
            
            let position = IndexPath(row: row, section: 0)
            
            guard let cellId = delegate?.cellIdentifier(for: object, at: position) else {
                
                continue
            }
            
            if cellId == targetCell || cellId == alternativeCell ?? "" {
                
                if last == false {
                    
                    return row
                }
                
                returnFirstDifferent = true
                
            } else {
                
                if returnFirstDifferent {
                    
                    return row
                }
            }
        }
        
        if returnFirstDifferent {
            
            return groupedObjects[0].count
        } else {
            return nil
        }
    }
    
    private func addReserveCell(with cell: ReserveCell) {
        
        guard let position = cell.posision else { return }
        
        let object = MUReserveModel()
        
        object.cell = cell
        
        object.defaultKey = "Reserve_\(cell.id)_\(position)"
        
        if position < groupedObjects[0].count {
            
            groupedObjects[0].insert(object, at: position)
        } else {
            groupedObjects[0].append(object)
        }
    }
    
    private func checkAreAnimationAvailable() -> Bool {
        
        return animationStyle != .none && checkAreDuplicateKeysExist(objects: objects) == false
    }
    
    private func updateTable(animated: Bool) {
        
        guard animated, checkAreAnimationAvailable() else {
            
            tableView?.reloadData()
            
            return
        }
        
        for section in oldGroupedObjects {
            
            if checkAreDuplicateKeysExist(objects: section) {
                
                tableView?.reloadData()
                
                return
            }
        }
        
        let color = tableView?.separatorColor
        
        tableView?.separatorColor = .clear
        
        tableView?.beginUpdates()
        
        updateSections(with: oldSections)
        
        updateGroupedObjects(with: oldGroupedObjects)
        
        tableView?.endUpdates()
        
        tableView?.separatorColor = color
    }
    
    // MARK: - Controller reusing
    
    private func setupReusableController(
        
        inCell cell   : MUControllerTableCell,
        for indexPath : IndexPath,
        with object   : MUModel? = nil
    
    ) {
        
        guard let currentController = controller else { return }
        
        let id = cell.controllerReuseIdentifier
        
        guard id.isEmpty == false else { fatalError("Controller reuse identifier must not be empty") }
        
        let reusableController = currentController.dequeueReusableController(
             
             withIdentifier: cell.controllerReuseIdentifier,
             for: indexPath
            
        )
        
        if let controller = reusableController as? MUReusableController {
            
            controller.prepareForReuse()
            
            controller.setup(with: object, sender: controller)
        }
        
        currentController.insert(controller: reusableController, into: cell.contentView)
    }
    
    private func endUsingController(inCell cell: MUControllerTableCell, for indexPath: IndexPath) {
        
        guard let currentController = controller else { return }
        
        let id = cell.controllerReuseIdentifier
        
        guard id.isEmpty == false else { fatalError("Controller reuse identifier must not be empty") }
        
        if let reusedController = currentController.getUsedController(withIdentifier: id, for: indexPath) {
            
            currentController.remove(child: reusedController)
            
        } else {
            
            assertionFailure("Reused controller with reuse identifier: \(id) for indexPath: \(indexPath) not found")
        }
        
        currentController.endUsingController(withIdentifier: id, for: indexPath)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MUTableControl: UITableViewDelegate, UITableViewDataSource {
    
    public func tableViewCell(for object: MUModel, at indexPath: IndexPath) -> MUTableCell? {
        
        let cellIdentifier = delegate?.cellIdentifier(for: object, at: indexPath) ?? "Cell"
        
        return tableView?.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MUTableCell
    }
    
    public func tableViewCellSetup(cell: MUTableCell, indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = delegate?.tableView2?(tableView, cellForRowAt: indexPath) {
            
            return cell
        }
        
        let object = groupedObjects[indexPath.section][indexPath.row]
        
        if let object = object as? MUReserveModel {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: object.cell.id, for: indexPath)
            
            (cell as? MUTableCell)?.setup(sender: controller)
            
            if let cell = cell as? MUControllerTableCell {
                
                setupReusableController(inCell: cell, for: indexPath)
            }
            
            return cell
        }
        
        guard let cell = tableViewCell(for: object, at: indexPath) else {
            
            Log.error("error: could not create cell")
            
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        
        tableViewCellSetup(cell: cell, indexPath: indexPath)
        
        cell.setup(with: object, sender: controller)
        
        if let cell = cell as? MUControllerTableCell {
             
             setupReusableController(inCell: cell, for: indexPath, with: object)
         }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return delegate?.tableView?(tableView, numberOfRowsInSection: section) ?? groupedObjects.count > 0 ? groupedObjects[section].count : 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard hasSections else { return nil }
        
        let cell = tableView.dequeueReusableCell(
            
            withIdentifier : "Section",
            for            : IndexPath(row: 0, section: 0)
        )
        
        (cell as? MUTableSection)?.setup(with: sections[section])
        
        return cell.subviews[0]
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return hasSections ? UITableView.automaticDimension : 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return hasSections ? UITableView.automaticDimension : 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return delegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return groupedObjects.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let didSelect = delegate?.tableView(_:didSelectRowAt:) {
            
            didSelect(tableView, indexPath)
            
        } else {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? MUTableCell else {
                
                return Log.error("error: could not find cell for indexPath \(indexPath)")
            }
            
            guard let object = cell.object else {
                
                return Log.error("error: cell object is nil")
            }
            
            delegate?.cellDidSelected(for: object, at: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? MUControllerTableCell {
            
            endUsingController(inCell: cell, for: indexPath)
        }
        
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
}

// MARK: - UIScrollViewDelegate

extension MUTableControl: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.scrollDidScroll(scrollView)
    }
}

// MARK: - MUTableCell

open class MUTableCell: UITableViewCell {
    
    open var object: MUModel?
    
    open func setup(with object: MUModel, sender: Any? = nil) {
        
        self.object = object
    }
    
    open func setup(sender: Any? = nil) {
        
    }
}

// MARK: - MUControllerTableCell

open class MUControllerTableCell: MUTableCell {
    
    @IBInspectable var controllerReuseIdentifier: String = ""
}

// MARK: - MUTableSection

open class MUTableSection: UITableViewCell {
    
    open func setup(with section: String) {
        
    }
}

// MARK: - MUTableModel

open class MUReserveModel: MUModel {
    
    open var cell: MUTableControl.ReserveCell!
}
