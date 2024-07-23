// *************************************************************************
//                              INTERFACE of Plethora Content
// *************************************************************************
use starknet::ContractAddress;
use plethora::constants::types::{PostParams, CommentParams, ContentType, Content};

#[starknet::interface]
pub trait IPlethoraContents<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn initialize(ref self: TState, hub_address: ContractAddress);
    fn post(ref self: TState, post_params: PostParams) -> u256;
    fn comment(ref self: TState, comment_params: CommentParams) -> u256;
    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_content(
        self: @TState, profile_address: ContractAddress, content_id_assigned: u256
    ) -> Content;
    fn get_content_type(
        self: @TState, profile_address: ContractAddress, content_id_assigned: u256
    ) -> ContentType;
    fn get_content_uri(
        self: @TState, profile_address: ContractAddress, content_id: u256
    ) -> ByteArray;
}
