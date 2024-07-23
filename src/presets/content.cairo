#[starknet::contract]
mod PlethoraContent {
    use starknet::{ContractAddress};
    use plethora::content::content::ContentComponent;
    use plethora::profile::profile::ProfileComponent;

    component!(path: ContentComponent, storage: content, event: ContentEvent);
    component!(path: ProfileComponent, storage: profile, event: ProfileEvent);
    #[abi(embed_v0)]
    impl contentImpl = ContentComponent::PlethoraContent<ContractState>;
    #[abi(embed_v0)]
    impl profileImpl = ProfileComponent::PlethoraProfile<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        content: ContentComponent::Storage,
        #[substorage(v0)]
        profile: ProfileComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ContentEvent: ContentComponent::Event,
        #[flat]
        ProfileEvent: ProfileComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, hub_address: ContractAddress) {
        self.content.initialize(hub_address);
    }
}
