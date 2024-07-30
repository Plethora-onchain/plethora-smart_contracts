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

// * @notice A struct containing post data.
#[derive(Drop, Serde, starknet::Store)]
pub struct Post {
    pub id: u32,
    pub title: Option<felt252>,
    pub content: Option<felt252>,
    pub createdAt: u64,
    pub post_url: Option<felt252>,
    pub img_url: Option<felt252>,
    pub platform: Option<felt252>,
    pub creator_address: ContractAddress,
}

// * @notice A struct containing the parameters supplied to the post method
#[derive(Drop, Serde, starknet::Store, Clone)]
pub struct PostParams {
    pub title: Option<felt252>,
    pub content: Option<felt252>,
    pub post_url: Option<felt252>,
    pub img_url: Option<felt252>,
    pub platform: Option<felt252>,
}
