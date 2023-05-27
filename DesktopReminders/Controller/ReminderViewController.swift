//
//  RemindersViewController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 7/6/20.
//

import Cocoa
import CoreGraphics

class RemindersViewController: NSViewController {
  enum FlowDirection : Int {
    case flowHorizontally = 0
    case flowVertically = 1
  }
  
  override func loadView() {
    //build layout
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = viewOptions.itemSize
    switch(viewOptions.direction) {
    case .flowHorizontally:
      flowLayout.scrollDirection = .vertical
    case .flowVertically:
      flowLayout.scrollDirection = .horizontal
    }

    //build collection
    let collectionView = NSCollectionView()
    collectionView.dataSource = self
    collectionView.collectionViewLayout = flowLayout
    collectionView.backgroundColors = [.clear]
    collectionView.register(NSNib(nibNamed: ReminderCell.cellIdentifier.rawValue, bundle: nil), forItemWithIdentifier: ReminderCell.cellIdentifier)
    view = collectionView
  }
  
  private var currentCollectionView : NSCollectionView? {
    return view as? NSCollectionView
  }
  
  private var currentFlowLayout : NSCollectionViewFlowLayout? {
    return currentCollectionView?.collectionViewLayout as? NSCollectionViewFlowLayout
  }
  
  // MARK: public
  
  var reminders: [Reminder] = [] {
    didSet {
      currentCollectionView?.reloadData()
    }
  }
  
  var viewOptions: ViewOptions = ViewOptions.default {
    didSet {
      if let currentFlowLayout {
        currentFlowLayout.itemSize = viewOptions.itemSize
        switch(viewOptions.direction) {
        case .flowHorizontally:
          currentFlowLayout.scrollDirection = .vertical
        case .flowVertically:
          currentFlowLayout.scrollDirection = .horizontal
        }
      }
      currentCollectionView?.reloadData()
    }
  }
}

extension RemindersViewController: NSCollectionViewDataSource {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return reminders.count
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let cell = collectionView.makeItem(withIdentifier: ReminderCell.cellIdentifier, for: indexPath) as! ReminderCell
    cell.update(reminder: reminders[indexPath.item], viewOptions: viewOptions)
    
    return cell
  }
}
