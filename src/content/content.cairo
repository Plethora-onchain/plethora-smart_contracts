#[starknet::component]
pub mod ContentComponent {
    // *************************************************************************
    //                              IMPORTS
    // *************************************************************************
    use core::traits::TryInto;
    use plethora::interfaces::IProfile::IProfile;
    use core::option::OptionTrait;
    use core::option::Option;
    use core::array::ArrayTrait;
    use core::traits::Into;
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
    use plethora::constants::types::{PostParams, Post};
    use plethora::profile::profile::ProfileComponent;
    use plethora::interfaces::IContent::IPlethoraContents;
    use plethora::{constants::errors::Errors::{NOT_PROFILE_OWNER, UNSUPPORTED_CONTENT_TYPE},};

    // *************************************************************************
    //                              STORAGEid: post_id.into(),
    // *************************************************************************
    #[storage]
    struct Storage {
        posts: LegacyMap<felt252, Post>,
        post_ids: Array<felt252>,
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
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>
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
                id: post_id.into(),
                title: post_params.title,
                content: post_params.content,
                createdAt: get_block_timestamp(),
                post_url: post_params.post_url,
                img_url: post_params.img_url,
                platform: post_params.platform,
                creator_address: post_params.creator_address,
            };

            self.posts.write(post_params.id, new_post);
            self.post_ids.append(post_params.id);  // Add this line to keep track of post IDs
            self
                .emit(
                    PostCreated {
                        post: post_params,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
        }

        /// @notice retrieves a post
        /// @param post_id the ID of the post to be retrieved
        fn get_post(self: @ComponentState<TContractState>, post_id: felt252) -> Post {
            self.posts.read(post_id)
        }

        /// @notice retrieves all posts
        fn get_all_posts(self: @ComponentState<TContractState>) -> Array<Post> {
            let mut all_posts: Array<Post> = ArrayTrait::new();
            let post_count = self.post_count.read();

            let mut i: u32 = 1;
            loop {
                if i > post_count {
                    break;
                }
                let post = self.posts.read(i);
                all_posts.append(post);
                i += 1;
            };

            all_posts
        }
    }
}
