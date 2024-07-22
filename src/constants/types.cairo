use core::option::OptionTrait;
// *************************************************************************
//                              TYPES
// *************************************************************************
use starknet::ContractAddress;

// * @notice A struct containing profile data.
// * profile_address The profile ID of a karst profile 
// * profile_owner The address that created the profile_address
// * @param content_count The number of contents made to this profile.
// * @param metadataURI MetadataURI is used to store the profile's metadata, for example: displayed name, description, interests, etc.
#[derive(Drop, Serde, starknet::Store)]
pub struct Profile {
    pub profile_address: ContractAddress,
    pub profile_owner: ContractAddress,
    pub content_count: u256,
    pub metadata_URI: ByteArray,
}

// /**
// * @notice A struct containing content data.
// *
// * @param pointed_profile_address The profile token ID to point the content to.
// * @param pointed_content_id The content ID to point the content to.
// * These are used to implement the "reference" feature of the platform and is used in:
// * - Comments
// * @param content_URI The URI to set for the content of content (can be ipfs, arweave, http, etc).
// * @param content_Type The type of content, can be Nonexistent, Post, Comment.
// * @param root_profile_address The profile ID of the root post (to determine if comments come from it).
// * @param root_content_id The content ID of the root post (to determine if comments come from it).
// */
#[derive(Debug, Drop, Serde, starknet::Store)]
pub struct Content {
    pub pointed_profile_address: ContractAddress,
    pub pointed_content_id: u256,
    pub content_URI: ByteArray,
    pub content_Type: ContentType,
    pub root_profile_address: ContractAddress,
    pub root_content_id: u256
}

// /**
// * @notice An enum specifically used in a helper function to easily retrieve the content type for integrations.
// *
// * @param Nonexistent An indicator showing the queried content does not exist.
// * @param Post A standard post, having an URI, and no pointer to another content.
// * @param Comment A comment, having an URI, and a pointer to another content.
// */
#[derive(Debug, Drop, Serde, starknet::Store, Clone, PartialEq)]
pub enum ContentType {
    Nonexistent,
    Post,
    Comment,
}

// /**
// * @notice A struct containing the parameters supplied to the post method
// * @param contentURI URI pointing to the post content
// * @param profile_address profile address that owns the post
// */
#[derive(Drop, Serde, starknet::Store, Clone)]
pub struct PostParams {
    pub content_URI: ByteArray,
    pub profile_address: ContractAddress,
}

// /**
// * @notice A struct containing the parameters supplied to the comment method
// * @param profile_address profile address that owns the comment
// * @param contentURI URI pointing to the comment content
// * @param pointed_profile_address profile address of the referenced content/comment
// * @param pointed_content_id ID of the pointed content
// */
#[derive(Drop, Serde, starknet::Store, Clone)]
pub struct CommentParams {
   pub profile_address: ContractAddress,
   pub content_URI: ByteArray,
   pub pointed_profile_address: ContractAddress,
   pub pointed_content_id: u256,
   pub reference_content_type: ContentType
}


#[derive(Drop, Serde, starknet::Store)]
pub struct ReferenceContentParams {
    profile_address: ContractAddress,
    content_URI: ByteArray,
    pointed_profile_address: ContractAddress,
    pointed_content_id: u256
}
