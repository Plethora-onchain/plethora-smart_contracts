use starknet::ContractAddress;

#[starknet::component]
pub mod ProfileComponent {
    // *************************************************************************
    //                            IMPORT
    // *************************************************************************
    use core::traits::TryInto;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use plethora::interfaces::IPlethoraNFT::{IPlethoraNFTDispatcher, IPlethoraNFTDispatcherTrait};
    use plethora::interfaces::IRegistry::{
        IRegistryDispatcher, IRegistryDispatcherTrait, IRegistryLibraryDispatcher
    };
    use plethora::interfaces::IERC721::{IERC721Dispatcher, IERC721DispatcherTrait};
    use plethora::interfaces::IProfile::IProfile;
    use plethora::constants::types::Profile;
    use plethora::constants::errors::Errors::NOT_PROFILE_OWNER;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        profile: LegacyMap<ContractAddress, Profile>,
        plethora_nft_address: ContractAddress,
    }

    // *************************************************************************
    //                            EVENT
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CreatedProfile: CreatedProfile
    }

    #[derive(Drop, starknet::Event)]
    pub struct CreatedProfile {
        #[key]
        owner: ContractAddress,
        #[key]
        profile_address: ContractAddress,
        token_id: u256,
        timestamp: u64
    }

    // *************************************************************************
    //                            EXTERNAL FUNCTIONS
    // *************************************************************************
    #[embeddable_as(PlethoraProfile)]
    impl ProfileImpl<
        TContractState, +HasComponent<TContractState>
    > of IProfile<ComponentState<TContractState>> {
        /// @notice initialize profile component
        fn initializer(
            ref self: ComponentState<TContractState>, plethora_nft_address: ContractAddress
        ) {
            self.plethora_nft_address.write(plethora_nft_address);
        }
        /// @notice creates plethora profile
        /// @param plethoranft_contract_address address of plethoranft
        /// @param registry_hash class_hash of registry contract
        /// @param implementation_hash the class hash of the reference account
        /// @param salt random salt for deployment
        fn create_profile(
            ref self: ComponentState<TContractState>,
            plethoranft_contract_address: ContractAddress,
            registry_hash: felt252,
            implementation_hash: felt252,
            salt: felt252
        ) -> ContractAddress {
            let recipient = get_caller_address();
            let owns_plethoranft = IERC721Dispatcher {
                contract_address: plethoranft_contract_address
            }
                .balance_of(recipient);
            
            if owns_plethoranft == 0 {
                IPlethoraNFTDispatcher { contract_address: plethoranft_contract_address }
                    .mint_plethoranft(recipient);
            }    

            let token_id = IPlethoraNFTDispatcher { contract_address: plethoranft_contract_address }
                .get_user_token_id(recipient);

            let profile_address = IRegistryLibraryDispatcher {
                class_hash: registry_hash.try_into().unwrap()
            }
                .create_account(implementation_hash, plethoranft_contract_address, token_id, salt);

            let new_profile = Profile {
                profile_address, profile_owner: recipient, content_count: 0, metadata_URI: "",
            };

            self.profile.write(profile_address, new_profile);
            self
                .emit(
                    CreatedProfile {
                        owner: recipient,
                        profile_address,
                        token_id,
                        timestamp: get_block_timestamp()
                    }
                );
            profile_address
        }

        /// @notice set profile metadata_uri (`banner_image, description, profile_image` to be uploaded to arweave or ipfs)
        /// @params profile_address the targeted profile address
        /// @params metadata_uri the profile CID
        fn set_profile_metadata_uri(
            ref self: ComponentState<TContractState>,
            profile_address: ContractAddress,
            metadata_uri: ByteArray
        ) {
            let mut profile: Profile = self.profile.read(profile_address);
            assert(get_caller_address() == profile.profile_owner, NOT_PROFILE_OWNER);

            profile.metadata_URI = metadata_uri;
            self.profile.write(profile_address, profile);
        }

        // *************************************************************************
        //                            GETTERS
        // *************************************************************************

        // @notice returns the Profile struct of a profile address
        // @params profile_address the targeted profile address
        fn get_profile(
            self: @ComponentState<TContractState>, profile_address: ContractAddress
        ) -> Profile {
            self.profile.read(profile_address)
        }

        /// @notice returns user profile metadata
        /// @params profile_address the targeted profile address 
        fn get_profile_metadata(
            self: @ComponentState<TContractState>, profile_address: ContractAddress
        ) -> ByteArray {
            let profile: Profile = self.profile.read(profile_address);
            profile.metadata_URI
        }

        // @notice returns the content count of a profile address
        // @params profile_address the targeted profile address
        fn get_user_content_count(
            self: @ComponentState<TContractState>, profile_address: ContractAddress
        ) -> u256 {
            let profile: Profile = self.profile.read(profile_address);
            profile.content_count
        }
    }

    #[generate_trait]
    impl Private<TContractState, +HasComponent<TContractState>> of PrivateTrait<TContractState> {
        /// @notice increments user's content count
        /// @params profile_address the targeted profile address
        fn increment_content_count(
            ref self: ComponentState<TContractState>, profile_address: ContractAddress
        ) -> u256 {
            let mut profile: Profile = self.profile.read(profile_address);
            let new_content_count = profile.content_count + 1;
            profile.content_count = new_content_count;

            self.profile.write(profile_address, profile);
            new_content_count
        }
    }
}
