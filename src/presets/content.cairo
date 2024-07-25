#[starknet::contract]
mod PlethoraContent {
    use starknet::{ContractAddress};
    use plethora::content::content::ContentComponent;

    component!(path: ContentComponent, storage: content, event: ContentEvent);
    #[abi(embed_v0)]
    impl contentImpl = ContentComponent::PlethoraContent<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        content: ContentComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ContentEvent: ContentComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, hub_address: ContractAddress) {
        self.content.initialize(hub_address);
    }
}