//
//  RemindersViewController.swift
//  DesktopReminders
//
//  Created by Dominik Pich on 7/6/20.
//

import Cocoa
import CoreGraphics

class RemindersViewController: NSViewController {
  enum FlowDirection: Int {
    case flowHorizontally = 0
    case flowVertically = 1
  }

  private var currentCollectionView: NSCollectionView? {
    view as? NSCollectionView
  }

  private var currentFlowLayout: NSCollectionViewFlowLayout? {
    currentCollectionView?.collectionViewLayout as? NSCollectionViewFlowLayout
  }

  var reminders: [Reminder] = [] {
    didSet {
      currentCollectionView?.reloadData()
    }
  }

  var viewOptions = ViewOptions.default {
    didSet {
      if let currentFlowLayout {
        currentFlowLayout.itemSize = viewOptions.cellSize
        switch viewOptions.direction {
        case .flowHorizontally:
          currentFlowLayout.scrollDirection = .vertical

        case .flowVertically:
          currentFlowLayout.scrollDirection = .horizontal
        }
      }
      currentCollectionView?.reloadData()
    }
  }
  
  override func loadView() {
    // build layout
    let flowLayout = NSCollectionViewFlowLayout()

    flowLayout.itemSize = viewOptions.cellSize
    switch viewOptions.direction {
    case .flowHorizontally:
      flowLayout.scrollDirection = .vertical

    case .flowVertically:
      flowLayout.scrollDirection = .horizontal
    }

    // build collection
    let collectionView = NSCollectionView()
    collectionView.dataSource = self
    collectionView.collectionViewLayout = flowLayout
    collectionView.backgroundColors = [.clear]
    collectionView.register(NSNib(nibNamed: ReminderCell.cellIdentifier.rawValue, bundle: nil), forItemWithIdentifier: ReminderCell.cellIdentifier)
    view = collectionView
  }
}

extension RemindersViewController: NSCollectionViewDataSource {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    reminders.count
  }

  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    // swiftlint:disable force_cast
    // we cast the returned cell to our custom class which we registered before! There is no way this would be sth else
    let cell = collectionView.makeItem(withIdentifier: ReminderCell.cellIdentifier, for: indexPath) as! ReminderCell
    // swiftlint:enable force_cast
    cell.update(reminder: reminders[indexPath.item], viewOptions: viewOptions)

    return cell
  }
}
