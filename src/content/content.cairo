#[starknet::component]
pub mod ContentComponent {
    // *************************************************************************
    //                              IMPORTS
    // *************************************************************************
    use core::traits::TryInto;
    use plethora::interfaces::IProfile::IProfile;
    use core::option::OptionTrait;
    use starknet::{ContractAddress, get_contract_address, get_caller_address, get_block_timestamp};
    use plethora::interfaces::IContent::IPlethoraContents;
    use plethora::{
        constants::errors::Errors::{NOT_PROFILE_OWNER, UNSUPPORTED_CONTENT_TYPE},
        constants::types::{PostParams, Content, ContentType, ReferenceContentParams, CommentParams}
    };

    use plethora::profile::profile::ProfileComponent;

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        content: LegacyMap<(ContractAddress, u256), Content>,
        plethora_hub: ContractAddress
    }

    // *************************************************************************
    //                              EVENTS
    // *************************************************************************
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Post: Post,
        CommentCreated: CommentCreated
    }

    #[derive(Drop, starknet::Event)]
    pub struct Post {
        post: PostParams,
        content_id: u256,
        transaction_executor: ContractAddress,
        block_timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CommentCreated {
        commentParams: CommentParams,
        content_id: u256,
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
        +Drop<TContractState>,
        impl Profile: ProfileComponent::HasComponent<TContractState>
    > of IPlethoraContents<ComponentState<TContractState>> {
        // *************************************************************************
        //                              PUBLISHING FUNCTIONS
        // *************************************************************************
        /// @notice initialize publication component
        /// @param hub_address address of hub contract
        fn initialize(ref self: ComponentState<TContractState>, hub_address: ContractAddress) {
            self.plethora_hub.write(hub_address);
        }

        /// @notice performs post action
        /// @param contentURI uri of the content to be posted
        /// @param profile_address address of profile performing the post action
        fn post(ref self: ComponentState<TContractState>, post_params: PostParams) -> u256 {
            let ref_post_params = post_params.clone();
            let profile_owner: ContractAddress = get_dep_component!(@self, Profile)
                .get_profile(post_params.profile_address)
                .profile_owner;
            assert(profile_owner == get_caller_address(), NOT_PROFILE_OWNER);

            let mut profile_component = get_dep_component_mut!(ref self, Profile);
            let content_id_assigned = profile_component
                .increment_content_count(post_params.profile_address);

            let new_post = Content {
                pointed_profile_address: 0.try_into().unwrap(),
                pointed_content_id: 0,
                content_URI: post_params.content_URI,
                content_Type: ContentType::Post,
                root_profile_address: 0.try_into().unwrap(),
                root_content_id: 0
            };

            self.content.write((post_params.profile_address, content_id_assigned), new_post);
            self
                .emit(
                    Post {
                        post: ref_post_params,
                        content_id: content_id_assigned,
                        transaction_executor: get_caller_address(),
                        block_timestamp: get_block_timestamp(),
                    }
                );
            content_id_assigned
        }

        /// @notice performs comment action
        /// @param profile_address address of profile performing the comment action
        /// @param reference_content_type content type
        /// @param pointed_profile_address profile address comment points too
        /// @param pointed_content_id ID of initial content comment points too
        fn comment(
            ref self: ComponentState<TContractState>, comment_params: CommentParams
        ) -> u256 {
            let profile_owner: ContractAddress = get_dep_component!(@self, Profile)
                .get_profile(comment_params.profile_address)
                .profile_owner;
            assert(profile_owner == get_caller_address(), NOT_PROFILE_OWNER);

            let ref_comment_params = comment_params.clone();
            let reference_content_type = self
                ._as_reference_content_params(comment_params.reference_content_type);
            assert(reference_content_type == ContentType::Comment, UNSUPPORTED_CONTENT_TYPE);

            let content_id_assigned = self
                ._create_reference_content(
                    comment_params.profile_address,
                    comment_params.content_URI,
                    comment_params.pointed_profile_address,
                    comment_params.pointed_content_id,
                    reference_content_type
                );

            self
                .emit(
                    CommentCreated {
                        commentParams: ref_comment_params,
                        content_id: content_id_assigned,
                        transaction_executor: comment_params.profile_address,
                        block_timestamp: get_block_timestamp(),
                    }
                );
            content_id_assigned
        }

        // *************************************************************************
        //                              GETTERS
        // *************************************************************************

        /// @notice gets the contents URI
        /// @param profile_address the profile address to be queried
        /// @param content_id the ID of the content to be queried
        fn get_content_uri(
            self: @ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id: u256
        ) -> ByteArray {
            self._get_content_URI(profile_address, content_id)
        }

        /// @notice retrieves a content
        /// @param profile_address the profile address to be queried
        /// @param content_id_assigned the ID of the content to be retrieved
        fn get_content(
            self: @ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id_assigned: u256
        ) -> Content {
            self.content.read((profile_address, content_id_assigned))
        }

        /// @notice retrieves a content type
        /// @param profile_address the profile address to be queried
        /// @param content_id_assigned the ID of the content whose type is to be retrieved
        fn get_content_type(
            self: @ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id_assigned: u256
        ) -> ContentType {
            self._get_content_type(profile_address, content_id_assigned)
        }
    }
    // *************************************************************************
    //                            PRIVATE FUNCTIONS
    // *************************************************************************
    #[generate_trait]
    impl InternalImpl<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Profile: ProfileComponent::HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// @notice fill reference content
        /// @param profile_address the profile address creating the content
        /// @param content_URI uri of the content content
        /// @param pointed_profile_address the profile address being pointed to by this content
        /// @param pointed_content_id the ID of the content being pointed to by this content
        // @param reference_content_type reference content type
        fn _fill_reference_content(
            ref self: ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_URI: ByteArray,
            pointed_profile_address: ContractAddress,
            pointed_content_id: u256,
            reference_content_type: ContentType
        ) -> u256 {
            let cloned_reference_content_type = reference_content_type.clone();
            let mut profile_instance = get_dep_component_mut!(ref self, Profile);
            let content_id_assigned = profile_instance.increment_content_count(profile_address);
            let pointed_content: Content = self
                .content
                .read((pointed_profile_address, pointed_content_id));

            let mut root_profile_address: ContractAddress = 0.try_into().unwrap();
            let mut root_content_id: u256 = 0.try_into().unwrap();

            match cloned_reference_content_type {
                ContentType::Post => {
                    root_content_id = 0.try_into().unwrap();
                    root_profile_address = 0.try_into().unwrap();
                },
                ContentType::Comment => {
                    if (pointed_content.root_content_id == 0) {
                        root_content_id = pointed_content_id;
                        root_profile_address = pointed_profile_address;
                    } else {
                        root_content_id = pointed_content.root_content_id;
                        root_profile_address = pointed_content.root_profile_address;
                    }
                },
                ContentType::Nonexistent => { return 0.try_into().unwrap(); }
            };

            let updated_reference = Content {
                pointed_profile_address,
                pointed_content_id,
                content_URI,
                content_Type: reference_content_type,
                root_content_id,
                root_profile_address
            };

            self.content.write((profile_address, content_id_assigned), updated_reference);
            content_id_assigned
        }

        /// @notice create reference content
        /// @param profile_address the profile address creating the content
        /// @param content_URI uri of the content content
        /// @param pointed_profile_address the profile address being pointed to by this content
        /// @param pointed_content_id the ID of the content being pointed to by this content
        // @param reference_content_type reference content type
        fn _create_reference_content(
            ref self: ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_URI: ByteArray,
            pointed_profile_address: ContractAddress,
            pointed_content_id: u256,
            reference_content_type: ContentType
        ) -> u256 {
            self._validate_pointed_content(pointed_profile_address, pointed_content_id);

            let content_id_assigned = self
                ._fill_reference_content(
                    profile_address,
                    content_URI,
                    pointed_profile_address,
                    pointed_content_id,
                    reference_content_type
                );

            content_id_assigned
        }

        /// @notice returns the content type
        // @param reference_content_type reference content type
        fn _as_reference_content_params(
            ref self: ComponentState<TContractState>, reference_content_type: ContentType
        ) -> ContentType {
            match reference_content_type {
                ContentType::Comment => ContentType::Comment,
                _ => ContentType::Nonexistent,
            }
        }

        /// @notice validates pointed content
        /// @param profile_address the profile address that created the content
        /// @param content_id the content ID of the content to be checked
        fn _validate_pointed_content(
            ref self: ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id: u256
        ) {
            let pointedContentType = self._get_content_type(profile_address, content_id);
            if pointedContentType == ContentType::Nonexistent {
                panic!("invalid pointed content");
            }
        }

        /// @notice gets the content type
        /// @param profile_address the profile address that created the content
        /// @param content_id_assigned the content ID of the content to be queried
        fn _get_content_type(
            self: @ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id_assigned: u256
        ) -> ContentType {
            let content: Content = self.content.read((profile_address, content_id_assigned));
            content.content_Type
        }

        /// @notice gets the content URI
        /// @param profile_address the profile address that created the content
        /// @param content_id the ID of the content to be queried
        fn _get_content_URI(
            self: @ComponentState<TContractState>,
            profile_address: ContractAddress,
            content_id: u256
        ) -> ByteArray {
            let content: Content = self.content.read((profile_address, content_id));
            let content_type_option: ContentType = content.content_Type;

            if content_type_option == ContentType::Nonexistent {
                return "0";
            } else {
                let content_uri: ByteArray = content.content_URI;
                content_uri
            }
        }
    }
}
