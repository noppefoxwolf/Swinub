// https://github.com/fedibird/mastodon/blob/main/app/serializers/rest/instance_serializer.rb#L107
public enum FedibirdCapability: String, Sendable, Codable, Equatable {
    case favouriteHashtag
    case favouriteDomain
    case favouriteList
    case statusExpire
    case followNoDelivery
    case followHashtag
    case subscribeAccount
    case subscribeDomain
    case subscribeKeyword
    case timelineHomeVisibility
    case timelineNoLocal
    case timelineDomain
    case timelineGroup
    case timelineGroupDirectory
    case visibilityMutual
    case visibilityLimited
    case visibilityPersonal
    case emojiReaction
    case misskeyBirthday
    case misskeyLocation
    case statusReference
    case searchability
    case statusCompactMode
    case accountConversations
    case enableWideEmoji
    case enableWideEmojiReaction
    case timelineBookmarkMediaOption
    case timelineFavouriteMediaOption
    case timelineEmojiReactionMediaOption
    case timelinePersonalMediaOption
    case bulkGetApiForAccounts
    case bulkGetApiForStatuses
    case sortedCustomEmojis
    case orderedMediaAttachment
    case followedMessage
    
    case fullTextSearch
    
    // kmyblue extensions
    // https://github.com/kmycode/mastodon/blob/1900a9073b3c40d96fc44fdaf99abc47bfefd7dd/app/helpers/kmyblue_capabilities_helper.rb#L31
    case kmyblueSearchability
    case kmyblueMarkdown
    case kmyblueReactionDeck
    case kmyblueVisibilityLogin
    case kmyblueLimitedScope
    case kmyblueAntenna
    case kmyblueBookmarkCategory
    case kmyblueSearchabilityLimited
    case kmyblueCircleHistory
    case kmyblueListNotification
    case kmyblueServerFeatures
    case kmyblueFavouriteAntenna
    case kmyblueVisibilityPublicUnlisted
    case kmyblueSearchabilityPublicUnlisted
    case kmyblueNoPublicVisibility
}
