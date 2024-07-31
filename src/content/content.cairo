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
        posts: LegacyMap<u32, Post>,
        post_ids: Array<u32>,
        post_count: u32,
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
        post_id: u32,
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
     
        fn post(ref self: ComponentState<TContractState>, 
            title:  felt252,
            content:  felt252,
            post_url:  felt252,
            img_url:  felt252,
            platform:  felt252
         ) {

            let _count = self.post_count.read();
            let _currentCount = _count+1; 

            let new_post = Post {
                id: _currentCount,
                title: title,
                content: content,
                createdAt: get_block_timestamp(),
                post_url: post_url,
                img_url: img_url,
                platform: platform,
                creator_address: get_caller_address(),
            };

            self.post_count.write(_currentCount);
            self.posts.write(new_post.id, new_post);

            self
                .emit(
                    PostCreated {
                        post_id: new_post.id,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
        }

        /// @notice retrieves a post
        /// @param post_id the ID of the post to be retrieved
        fn get_post(self: @ComponentState<TContractState>, post_id: u32) -> Post {
            self.posts.read(post_id)
        }

        /// @notice retrieves all posts
        fn get_all_posts(self: @ComponentState<TContractState>) -> Array<Post> {
            let mut all_posts: Array<Post> = ArrayTrait::new();
            let post_count = self.post_count.read();

            let mut i: u32 = 1;
    
            while i < post_count
            + 1 {
                let post = self.posts.read(i);
                all_posts.append(post);
                i += 1;
            };

            all_posts
        }
    }
}
