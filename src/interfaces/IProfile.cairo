use starknet::ContractAddress;
use plethora::constants::types::Profile;
// *************************************************************************
//                              INTERFACE of Plethora PROFILE
// *************************************************************************

#[starknet::interface]
pub trait IProfile<TState> {
    // *************************************************************************
    //                              EXTERNALS
    // *************************************************************************
    fn initializer(ref self: TState, plethora_nft_address: ContractAddress);
    fn create_profile(
        ref self: TState,
        plethoranft_contract_address: ContractAddress,
        registry_hash: felt252,
        implementation_hash: felt252,
        salt: felt252
    ) -> ContractAddress;
    fn set_profile_metadata_uri(
        ref self: TState, profile_address: ContractAddress, metadata_uri: ByteArray
    );

    fn increment_content_count(ref self: TState, profile_address: ContractAddress) -> u256;

    // *************************************************************************
    //                              GETTERS
    // *************************************************************************
    fn get_profile_metadata(self: @TState, profile_address: ContractAddress) -> ByteArray;
    fn get_profile(self: @TState, profile_address: ContractAddress) -> Profile;
    fn get_user_content_count(self: @TState, profile_address: ContractAddress) -> u256;
}
