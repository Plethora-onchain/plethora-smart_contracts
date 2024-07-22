#[starknet::contract]
mod PlethoraProfile {
    use starknet::{ContractAddress, get_caller_address};
    use plethora::profile::profile::ProfileComponent;

    component!(path: ProfileComponent, storage: profile, event: ProfileEvent);

    #[abi(embed_v0)]
    impl profileImpl = ProfileComponent::PlethoraProfile<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        profile: ProfileComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ProfileEvent: ProfileComponent::Event
    }
// #[constructor]
// fn constructor(ref self: ContractState, hub_address: ContractAddress) {
//     self.profile.initializer(hub_address);
// }
}
