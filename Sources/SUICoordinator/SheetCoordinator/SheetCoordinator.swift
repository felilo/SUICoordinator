//
//  SheetCoordinator.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SUICoordinatorCore

/// A class representing a coordinator for managing and presenting sheets.
@available(iOS 17.0, *)
@MainActor
@Observable
final class SheetCoordinator<T> {

    public typealias Item = SheetItem<T>

    var items: [Item?]
    @ObservationIgnored
    private let itemManager = ItemManager<Item?>()
    @ObservationIgnored
    public private(set) var lastPresentationStyle: TransitionPresentationStyle?
    @ObservationIgnored
    public private(set) var isCoordinator: Bool = false
    @ObservationIgnored
    public private(set) var animated: Bool?
    @ObservationIgnored
    private var backUpItems: [Int: String]
    @ObservationIgnored
    var onRemoveItem: ((String) async -> Void)?
    @ObservationIgnored
    var onFinish: AsyncBroadcast<String> = .init()

    init(
        items: [Item?] = [],
        lastPresentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool? = nil,
        backUpItems: [Int : String] = [:],
        onRemoveItem: ((String) async -> Void)? = nil
    ) {
        self.items = items
        self.lastPresentationStyle = lastPresentationStyle
        self.animated = animated
        self.backUpItems = backUpItems
        self.onRemoveItem = onRemoveItem
    }

    private var totalItems: Int {
        get async { await itemManager.totalItems }
    }

    var areEmptyItems: Bool {
        get async { await itemManager.areItemsEmpty() }
    }

    public func presentSheet(_ sheet: Item) async -> Void {
        animated = sheet.animated
        lastPresentationStyle = sheet.presentationStyle
        isCoordinator = sheet.isCoordinator
        await itemManager.addItem(sheet)
        await backUpItems[totalItems] = sheet.id
        await updateItems()
    }

    func removeLastSheet(animated: Bool) async -> Void {
        guard !(await areEmptyItems),
              let totalItems = await itemManager.getAllItems().lastIndex(where: { $0 != nil })
        else { return await updateItems() }
        await removeSheet(at: totalItems, animated: animated)
    }

    func removeSheet(at index: Int, animated: Bool) async -> Void {
        self.animated = animated
        await updateLastPresentationStyle()
        
        if lastPresentationStyle?.isCustom == true {
            await itemManager.getItem(at: index)?.willDismiss.send()
        }
        
        await itemManager.makeItemsNil(at: index)
        await updateItems()
        
        if !isCoordinator {
            let stream = await onFinish.stream()
            for await value in stream {
                if let inComingIndex = Int(value), inComingIndex == index {
                    break
                }
            }
        }
    }

    func remove(at index: String) async {
        guard let index = Int(index),
              (await itemManager.isValid(index: index))
        else { return await updateItems() }
        let nextIndex = index + 1
        
        await removeCustomSheets(at: nextIndex)

        if let id = backUpItems[index] {
            await onRemoveItem?(id)
            backUpItems.removeValue(forKey: index)
        }

        guard (await itemManager.removeItem(at: index)) != nil else {
            await updateLastPresentationStyle()
            return await updateItems()
        }

        await handleRemove(index: nextIndex)
        await updateLastPresentationStyle()
        await removeAllNilItems()
        await onFinish.send("\(index)")
    }

    func clean(animated: Bool = true) async -> Void {
        let items = await itemManager.getAllItems()
        let paired = zip(items, [nil] + items)

        var result = zip(items.indices, paired).compactMap { index, pair in
            let (current, previous) = pair

            return (
                previous == nil ||
                (current?.presentationStyle == .fullScreenCover && previous?.presentationStyle != .fullScreenCover) ||
                (current?.presentationStyle != .fullScreenCover && previous?.presentationStyle == .fullScreenCover)
            ) ? index : nil
        }.reversed()

        for index in result {
            let animated = result.last == index ? animated : false
            await removeSheet(at: index, animated: animated)
        }
        await itemManager.removeAll()
        lastPresentationStyle = nil
        backUpItems.removeAll()
        await updateItems()
    }

    func getNextIndex(_ index: Int) -> Int {
        index + 1
    }

    func isLastIndex(_ index: Int) -> Bool {
        let totalItems = items.count - 1
        return items.isEmpty || index == totalItems
    }

    func removeAllNilItems() async {
        await itemManager.removeAllNilItems()
        await updateItems()
    }

    func updateItems() async {
        items = await itemManager.getAllItems()
    }
    
    private func removeCustomSheets(at index: Int) async {
        let items = await itemManager.getAllItems()
        guard items.indices.contains(index) else { return }
        
        let customItems = Array(items.suffix(from: index))
            .filter { $0?.presentationStyle.isCustom == true }
        
        for item in customItems {
            if let index = await itemManager.getAllItems().firstIndex(where: { $0?.id == item?.id }) {
                await remove(at: "\(index)")
            }
        }
    }

    private func updateLastPresentationStyle() async {
        let items = await itemManager.getAllItems()
        
        let presentationStyle = items.last(where: {
            $0?.presentationStyle != nil
        })??.presentationStyle
        
        if presentationStyle != lastPresentationStyle {
            lastPresentationStyle = presentationStyle
        }
        
        if let isCoordinator = items.last(where: { $0?.isCoordinator != nil })??.isCoordinator {
            self.isCoordinator = isCoordinator
        }
    }

    private func handleRemove(index: Int) async {
        guard (await itemManager.isValid(index: index)) else { return }
        let items = await itemManager.getAllItems()
        let range = index..<items.count
        for i in range {
            if let item = items[i],
               item.isCoordinator == true,
               let element = getBackupItemIndex(by: item.id)
            {
                backUpItems.removeValue(forKey: element.key)
                await onRemoveItem?(element.value)
            }
        }
    }

    private func getBackupItemIndex(by value: String) -> Dictionary<Int, String>.Element? {
        backUpItems.first(where: { $0.value == value })
    }
}
