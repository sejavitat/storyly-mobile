//
//  STStorylyView.swift
//  storyly-react-native
//
//  Created by Haldun Melih Fadillioglu on 26.10.2022.
//

import Storyly


@objc(STStorylyView)
class STStorylyView: UIView {
    @objc(storylyView)
    let storylyView: StorylyView
    
    @objc(onStorylyLoaded)
    var onStorylyLoaded: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyLoadFailed)
    var onStorylyLoadFailed: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyEvent)
    var onStorylyEvent: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyActionClicked)
    var onStorylyActionClicked: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyStoryPresented)
    var onStorylyStoryPresented: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyStoryPresentFailed)
    var onStorylyStoryPresentFailed: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyStoryDismissed)
    var onStorylyStoryDismissed: RCTBubblingEventBlock? = nil
    
    @objc(onStorylyUserInteracted)
    var onStorylyUserInteracted: RCTBubblingEventBlock? = nil
    
    
    override init(frame: CGRect) {
        self.storylyView = StorylyView(frame: frame)
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.storylyView.rootViewController = UIApplication.shared.delegate?.window??.rootViewController
        self.storylyView.delegate = self
        self.addSubview(storylyView)
        
        self.storylyView.translatesAutoresizingMaskIntoConstraints = false
        self.storylyView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.storylyView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.storylyView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.storylyView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension STStorylyView {
    func refresh() {
        storylyView.refresh()
    }
    
    func open() {
        storylyView.present(animated: false)
        storylyView.resume()
    }
    
    func close() {
        storylyView.pause()
        storylyView.dismiss(animated: false)
    }
    
    func openStory(payload: URL) -> Bool {
        return storylyView.openStory(payload: payload)
    }
    
    func openStory(storyGroupId: String, storyId: String) -> Bool {
        return storylyView.openStory(storyGroupId: storyGroupId, storyId: storyId)
    }
    
    func setExternalData(externalData: [NSDictionary]) -> Bool {
        return storylyView.setExternalData(externalData: externalData)
    }
}

extension STStorylyView: StorylyDelegate {
    func storylyLoaded(_ storylyView: StorylyView, storyGroupList: [StoryGroup], dataSource: StorylyDataSource) {
        let map: [String : Any] = [
            "storyGroupList": storyGroupList.map { createStoryGroupMap(storyGroup: $0) },
            "dataSource": dataSource.description
        ]
        self.onStorylyLoaded?(map)
    }
    
    func storylyLoadFailed(_ storylyView: StorylyView, errorMessage: String) {
        self.onStorylyLoadFailed?(["errorMessage": errorMessage])
    }
    
    func storylyActionClicked(_ storylyView: StorylyView, rootViewController: UIViewController, story: Story) {
        self.onStorylyActionClicked?(self.createStoryMap(story: story) as [AnyHashable: Any])
    }
    
    func storylyEvent(_ storylyView: StorylyView, event: StorylyEvent, storyGroup: StoryGroup?, story: Story?, storyComponent: StoryComponent?) {
        let map: [String : Any] = [
            "event": StorylyEventHelper.storylyEventName(event: event),
            "storyGroup": createStoryGroupMap(storyGroup) as Any,
            "story": createStoryMap(story) as Any,
            "storyComponent": createStoryComponentMap(storyComponent) as Any
        ]
        self.onStorylyEvent?(map)
    }
    
    func storylyStoryPresented(_ storylyView: StorylyView) {
        self.onStorylyStoryPresented?([:])
    }
    
    func storylyStoryPresentFailed(_ storylyView: StorylyView, errorMessage: String) {
        self.onStorylyStoryPresentFailed?(["errorMessage": errorMessage])
    }
    
    func storylyStoryDismissed(_ storylyView: StorylyView) {
        self.onStorylyStoryDismissed?([:])
    }
    
    func storylyUserInteracted(_ storylyView: StorylyView, storyGroup: StoryGroup, story: Story, storyComponent: StoryComponent) {
        let map: [String : Any] = [
            "storyGroup": createStoryGroupMap(storyGroup: storyGroup),
            "story": createStoryMap(story: story),
            "storyComponent": createStoryComponentMap(storyComponent: storyComponent)
        ]
        self.onStorylyUserInteracted?(map)
    }
}

private extension STStorylyView {
    func createStoryGroupMap(_ storyGroup: StoryGroup?) -> [String: Any]? {
        guard let storyGroup = storyGroup else { return nil }
        return createStoryGroupMap(storyGroup: storyGroup)
    }
        
    func createStoryGroupMap(storyGroup: StoryGroup) -> [String: Any] {
        let storyGroupMap: [String : Any] = [
            "id": storyGroup.uniqueId,
            "index": storyGroup.index,
            "title": storyGroup.title,
            "seen": storyGroup.seen,
            "iconUrl": storyGroup.iconUrl.absoluteString,
            "stories": storyGroup.stories.map { createStoryMap(story: $0) }
        ]
        return storyGroupMap
    }
    
    func createStoryMap(_ story: Story?) -> [String: Any?]? {
        guard let story = story else { return nil }
        return createStoryMap(story: story)
    }
    
    func createStoryMap(story: Story) -> [String: Any?] {
        let storyMap: [String : Any?] = [
            "id": story.uniqueId,
            "index": story.index,
            "title": story.title,
            "name": story.name,
            "seen": story.seen,
            "currentTime": story.currentTime,
            "media": [
                "type": story.media.type.rawValue,
                "storyComponentList": story.media.storyComponentList?.map { createStoryComponentMap(storyComponent: $0) },
                "actionUrl": story.media.actionUrl,
                "previewUrl": story.media.previewUrl?.absoluteString,
                "actionUrlList": story.media.actionUrlList
            ] as [String: Any?]
        ]
        return storyMap
    }
    
    func createStoryComponentMap(_ storyComponent: StoryComponent?) -> [String: Any?]? {
        guard let storyComponent = storyComponent else { return nil }
        return createStoryComponentMap(storyComponent: storyComponent)
    }
    
    func createStoryComponentMap(storyComponent: StoryComponent) -> [String: Any?] {
        switch storyComponent {
            case let storyComponent as StoryQuizComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "title": storyComponent.title,
                "options": storyComponent.options,
                "rightAnswerIndex": storyComponent.rightAnswerIndex,
                "selectedOptionIndex": storyComponent.selectedOptionIndex,
                "customPayload": storyComponent.customPayload
            ]
            case let storyComponent as StoryPollComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "title": storyComponent.title,
                "options": storyComponent.options,
                "selectedOptionIndex": storyComponent.selectedOptionIndex,
                "customPayload": storyComponent.customPayload
            ]
            case let storyComponent as StoryEmojiComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "emojiCodes": storyComponent.emojiCodes,
                "selectedEmojiIndex": storyComponent.selectedEmojiIndex,
                "customPayload": storyComponent.customPayload
            ]
            case let storyComponent as StoryRatingComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "emojiCode": storyComponent.emojiCode,
                "rating": storyComponent.rating,
                "customPayload": storyComponent.customPayload
            ]
            case let storyComponent as StoryPromoCodeComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "text": storyComponent.text
            ]
            case let storyComponent as StoryCommentComponent: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
                "text": storyComponent.text
            ]
            default: return [
                "type": StoryComponentTypeHelper.storyComponentName(componentType:storyComponent.type).lowercased(),
                "id": storyComponent.id,
            ]
        }
    }
}