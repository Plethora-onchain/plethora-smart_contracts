#[starknet::component]
pub mod ContentComponent {
    // *************************************************************************
    //                              IMPORTS
    // *************************************************************************
    use core::traits::TryInto;
    use plethora::interfaces::IProfile::IProfile;
    use core::option::OptionTrait;
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
    use plethora::constants::types::{PostParams, Post};
    use plethora::profile::profile::ProfileComponent;
    use plethora::interfaces::IContent::IPlethoraContents;
    use plethora::{
        constants::errors::Errors::{NOT_PROFILE_OWNER, UNSUPPORTED_CONTENT_TYPE},
    };


    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        posts: LegacyMap<felt252, Post>,
        plethora_hub: ContractAddress
    }

    // *************************************************************************
    //                              EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        PostCreated: PostCreated
    }

    #[derive(Drop, starknet::Event)]
    pub struct PostCreated {
        post: PostParams,
        transaction_executor: ContractAddress,
        block_timestamp: u64,
    }

    // *************************************************************************
    //                              EXTERNAL FUNCTIONS
    // *************************************************************************
    #[embeddable_as(PlethoraContent)]
    impl ContentImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>
    > of IPlethoraContents<ComponentState<TContractState>> {
        /// @notice initialize publication component
        /// @param hub_address address of hub contract
        fn initialize(ref self: ComponentState<TContractState>, hub_address: ContractAddress) {
            self.plethora_hub.write(hub_address);
        }

        /// @notice performs post action
        /// @param post_params parameters for the post
        fn post(ref self: ComponentState<TContractState>, post_params: PostParams) {
            let new_post = Post {
                id: post_params.id,
                title: post_params.title,
                content: post_params.content,
                createdAt: get_block_timestamp(),
                post_url: post_params.post_url,
                img_url: post_params.img_url,
                platform: post_params.platform,
                creator_address: post_params.creator_address,
            };

            self.posts.write(post_params.id, new_post);
            self.emit(
                PostCreated {
                    post: post_params,
                    transaction_executor: get_caller_address(),
                    block_timestamp: get_block_timestamp(),
                }
            );
        }

        /// @notice retrieves a post
        /// @param post_id the ID of the post to be retrieved
        fn get_post(
            self: @ComponentState<TContractState>,
            post_id: felt252
        ) -> Post {
            self.posts.read(post_id)
        }
    }
}