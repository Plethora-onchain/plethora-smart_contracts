// *************************************************************************
//                            ERRORS
// *************************************************************************
pub mod Errors {
    pub const NOT_PROFILE_OWNER: felt252 = 'Plethora: not profile owner!';
    pub const ALREADY_MINTED: felt252 = 'Plethora: user already minted!';
    pub const INITIALIZED: felt252 = 'Plethora: already initialized!';
    pub const NOT_FOLLOWING: felt252 = 'Plethora: user not following!';
    pub const BLOCKED_STATUS: felt252 = 'Plethora: user is blocked!';
    pub const INVALID_POINTED_CONTENT: felt252 = 'Plethora: invalid content!';
    pub const INVALID_OWNER: felt252 = 'Plethora: caller is not owner!';
    pub const INVALID_PROFILE: felt252 = 'Plethora: profile is not owner!';
    pub const HANDLE_ALREADY_LINKED: felt252 = 'Plethora: handle linked!';
    pub const HANDLE_DOES_NOT_EXIST: felt252 = 'Plethora: handle missing!';
    pub const INVALID_LOCAL_NAME: felt252 = 'Plethora: invalid local name!';
    pub const UNSUPPORTED_CONTENT_TYPE: felt252 = 'Plethora: unsupported type!';
    pub const HUB_RESTRICTED: felt252 = 'Plethora: caller is not Hub!';
}
