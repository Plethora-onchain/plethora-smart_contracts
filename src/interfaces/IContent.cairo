// *************************************************************************
//                              INTERFACE of Plethora Content
// *************************************************************************
use starknet::ContractAddress;
use plethora::constants::types::{PostParams, Post};

#[starknet::interface]
pub trait IPlethoraContents<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn initialize(ref self: TState, hub_address: ContractAddress);
    fn post(ref self: TState, post_params: PostParams);
    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_post(self: @TState, post_id: felt252) -> Post;
}