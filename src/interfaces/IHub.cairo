use starknet::ContractAddress;
use plethora::constants::types::{Profile, PostParams, CommentParams, ContentType, Content};

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
    fn post(ref self: TState, post_params: PostParams) -> u256;

    fn comment(ref self: TState, comment_params: CommentParams) -> u256;

    fn get_content(
        self: @TState, profile_address: ContractAddress, content_id_assigned: u256
    ) -> Content;

    fn get_content_type(
        self: @TState, profile_address: ContractAddress, content_id_assigned: u256
    ) -> ContentType;

    fn get_content_uri(
        self: @TState, profile_address: ContractAddress, content_id: u256
    ) -> ByteArray;

    // *************************************************************************
    //                            HANDLES
    // *************************************************************************
    fn get_handle_id(self: @TState, profile_address: ContractAddress) -> u256;

    fn get_handle(self: @TState, handle_id: u256) -> ByteArray;
}
