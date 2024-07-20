use starknet::ContractAddress;

// * @notice A struct containing profile data.
// * profile_address The profile ID of a plethora profile 
// * profile_owner The address that created the profile_address
// * @param content_count The number of contents made to this profile.
// * @param metadataURI MetadataURI is used to store the profile's metadata, for example: displayed name, description, interests, etc.
#[derive(Drop, Serde, starknet::Store)]
pub struct Profile {
    profile_address: ContractAddress,
    profile_owner: ContractAddress,
    content_count: u256,
    metadata_URI: ByteArray,
}
