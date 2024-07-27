#[starknet::contract]
pub mod Hub {
    use starknet::ContractAddress;
    use plethora::profile::profile::ProfileComponent;
    use plethora::content::content::ContentComponent;
    use plethora::interfaces::IPlethoraNFT::{IPlethoraNFTDispatcher, IPlethoraNFTDispatcherTrait};

    // Declare components
    component!(path: ProfileComponent, storage: profile, event: ProfileEvent);
    component!(path: ContentComponent, storage: content, event: ContentEvent);

    // Embed the component's logic
    #[abi(embed_v0)]
    impl ProfileImpl = ProfileComponent::PlethoraProfile<ContractState>;
    #[abi(embed_v0)]
    impl ContentImpl = ContentComponent::PlethoraContent<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        profile: ProfileComponent::Storage,
        #[substorage(v0)]
        content: ContentComponent::Storage,
        plethoranft_address: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ProfileEvent: ProfileComponent::Event,
        #[flat]
        ContentEvent: ContentComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, plethoranft_address: ContractAddress) {
        self.plethoranft_address.write(plethoranft_address);
    }

    #[external(v0)]
    fn set_hub_address(ref self: ContractState, hub_address: ContractAddress) {
        self.profile.initializer(hub_address);
        self.content.initialize(hub_address);
    }

    #[external(v0)]
    fn mint_nft(ref self: ContractState, user_address: ContractAddress) {
        let plethoranft = IPlethoraNFTDispatcher {
            contract_address: self.plethoranft_address.read()
        };
        plethoranft.mint_plethoranft(user_address);
    }

    #[external(v0)]
    fn get_last_minted_id(self: @ContractState) -> u256 {
        let plethoranft = IPlethoraNFTDispatcher {
            contract_address: self.plethoranft_address.read()
        };
        plethoranft.get_last_minted_id()
    }

    #[external(v0)]
    fn get_user_token_id(self: @ContractState, user: ContractAddress) -> u256 {
        let plethoranft = IPlethoraNFTDispatcher {
            contract_address: self.plethoranft_address.read()
        };
        plethoranft.get_user_token_id(user)
    }
}
