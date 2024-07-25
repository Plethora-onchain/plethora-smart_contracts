use starknet::ContractAddress;
use plethora::constants::types::{Profile, PostParams, Post};

// *************************************************************************
//                              INTERFACE of HUB CONTRACT
// *************************************************************************
#[starknet::interface]
pub trait IHub<TState> {
    // *************************************************************************
    //                              PROFILE
    // *************************************************************************
    fn create_profile(
        ref self: TState,
        plethoranft_contract_address: ContractAddress,
        registry_hash: felt252,
        implementation_hash: felt252,
        salt: felt252,
        recipient: ContractAddress
    ) -> ContractAddress;

    fn set_profile_metadata_uri(
        ref self: TState, profile_address: ContractAddress, metadata_uri: ByteArray
    );

    fn get_profile_metadata(self: @TState, profile_address: ContractAddress) -> ByteArray;

    fn get_profile(self: @TState, profile_address: ContractAddress) -> Profile;

    fn get_user_content_count(self: @TState, profile_address: ContractAddress) -> u256;

    // *************************************************************************
    //                            CONTENT
    // *************************************************************************
    fn post(ref self: TState, post_params: PostParams);

    fn get_post(self: @TState, post_id: felt252) -> Post;
}