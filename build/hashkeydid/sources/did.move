
//todo function
//Deedgrean: issueDG mintDG(mintDG through DID contract)
//Did: mintDID claimDID addKYC
module hashkeydid::did {
    use sui::url::{Self, Url};
    use std::vector;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::ed25519;
    use sui::hash;

    const ENOT_ADMIN_PRIORITY: u64 = 0;
    const EINVALID_PROOF_OF_KNOWLEDGE: u64 = 1;
    const EDID_CLAIMED: u64 = 2;
    const INVALID_DIDFORMAT: u64 = 3;

    struct AdminCap has key { id: UID }

    struct GlobleStorage has key {
        id: UID,
        didClaimed: VecMap<vector<u8>,bool>,
        addrClaimed: VecMap<address,bool>,
        addrs2Did: VecMap<address,vector<u8>>,
        did2Addrs: VecMap<vector<u8>,address>,
    }

    struct KYCInfo has key, store {
        id: UID,
        did: vector<u8>,
        status: bool,
        updateTime: u64,
        expireTime: u64,
    }

    struct Did has key, store {
        id: UID,
        url: url::Url,
        did: vector<u8>
    }

    struct DeedGrant has key, store {
        id: UID,
        name: vector<u8>,
        description: vector<u8>,
        url: url::Url
    }

    struct DeedGrantEvent has copy, drop {
        object_id: ID,
        creator: address,
        name: vector<u8>,
    }

    struct MintDidEvent has copy, drop {
        object_id: ID,
        creator: address,
        name: vector<u8>,
    }

    fun init(ctx: &mut TxContext) {

        let storage = GlobleStorage {
            id: object::new(ctx),
            didClaimed: vec_map::empty(),
            addrClaimed: vec_map::empty(),
            addrs2Did: vec_map::empty(),
            did2Addrs: vec_map::empty(),
        };

        transfer::share_object(storage);
        transfer::transfer(AdminCap {id: object::new(ctx)}, tx_context::sender(ctx))
    }

    public entry fun issueDG(to: address, name: vector<u8>, symbol: vector<u8>, url: vector<u8>, evidence: vector<u8>, public_key: vector<u8>, ctx: &mut TxContext) {
        let message = vector::empty<u8>();
        let i = 0;
        while(i < vector::length(&name)){
            vector::push_back(&mut message, *vector::borrow(&name, i));
            i = i + 1;
        };
        let i = 0;
        while(i < vector::length(&symbol)){
            vector::push_back(&mut message, *vector::borrow(&symbol, i));
            i = i + 1;
        };
        ed25519::ed25519_verify(&evidence, &public_key, &message);
        let dg = DeedGrant {
            id: object::new(ctx),
            name: name,
            description: symbol,
            url: url::new_unsafe_from_bytes(url)
        };
        event::emit(DeedGrantEvent {
            object_id: object::id(&dg),
            creator: tx_context::sender(ctx),
            name: dg.name,
        });

        transfer::transfer(dg, to);
    }

    public entry fun claimDid(storage: &mut GlobleStorage, _did: vector<u8>, _url: vector<u8>, ctx: &mut TxContext) {
        let didClaimed: bool = vec_map::contains(&storage.didClaimed, &_did);
        let addrClaimed: bool = vec_map::contains(&storage.addrClaimed, &tx_context::sender(ctx));
        assert!(!didClaimed, EDID_CLAIMED);
        assert!(!addrClaimed, EDID_CLAIMED);
        assert!(verifyDIDFormat(_did), INVALID_DIDFORMAT);

        vec_map::insert(&mut storage.didClaimed, _did, true);
        vec_map::insert(&mut storage.addrClaimed, tx_context::sender(ctx), true);
        vec_map::insert(&mut storage.addrs2Did, tx_context::sender(ctx), _did);
        vec_map::insert(&mut storage.did2Addrs, _did, tx_context::sender(ctx));

        let did = Did {
            id: object::new(ctx),
            did: _did,
            url: url::new_unsafe_from_bytes(_url)
        };
        let sender = tx_context::sender(ctx);
        
        event::emit(MintDidEvent {
            object_id: object::uid_to_inner(&did.id),
            creator: sender,
            name: _did,
        });
        transfer::transfer(did, sender);
    }

    public entry fun addKYC(to: address, did: vector<u8>, status: bool, _updateTime: u64, _expireTime: u64, signature: vector<u8>, public_key: vector<u8>, ctx: &mut TxContext) {
        let message = vector::empty<u8>();
        let updateTime: vector<u8> = u64_to_vec_u8_string(_updateTime);
        let expireTime: vector<u8> = u64_to_vec_u8_string(_expireTime);
        let i = 0;
        while(i < vector::length(&updateTime)){
            vector::push_back(&mut message, *vector::borrow(&updateTime, i));
            i = i + 1;
        };
        let i = 0;
        while(i < vector::length(&expireTime)){
            vector::push_back(&mut message, *vector::borrow(&expireTime, i));
            i = i + 1;
        };
        let i = 0;
        while(i < vector::length(&signature)){
            vector::push_back(&mut message, *vector::borrow(&did, i));
            i = i + 1;
        };
        ed25519::ed25519_verify(&signature, &public_key, &message);
        let kyc = KYCInfo {
            id: object::new(ctx),
            did: did,
            status: status,
            updateTime: _updateTime,
            expireTime: _expireTime,
        };
        transfer::transfer(kyc, to);
    }

    public fun verifyDIDFormat(_did: vector<u8>): bool {
        if(vector::length(&_did) < 5 || vector::length(&_did) > 54){
            return false
        };
        let i = 0;
        while(i < vector::length(&_did) - 4){
            let c = vector::borrow(&_did, i);
            if (((*c < 48) || (*c > 122)) || ((*c > 57) && (*c < 97))) {
                return false
            };
            i = i + 1;
        };
        if(
            (*vector::borrow(&_did, vector::length(&_did) - 4) != 46) ||
            (*vector::borrow(&_did, vector::length(&_did) - 3) != 107) ||
            (*vector::borrow(&_did, vector::length(&_did) - 2) != 101) ||
            (*vector::borrow(&_did, vector::length(&_did) - 1) != 121)
        ) {
            return false
        };
        return true
    }

    public fun name(did: &Did): vector<u8> {
        return did.did
    }

    public fun url(did: &Did): Url {
        return did.url
    }

    public fun u64_to_vec_u8_string(val : u64) : vector<u8> {
      let result = vector::empty<u8>();

      if (val == 0) {
         return b"0"
      };
     
      while (val != 0) {
         vector::push_back(&mut result, ((48 + val % 10) as u8));
         val = val / 10;
      };

      vector::reverse(&mut result);
      
      result
   }

    public  fun pubkey_to_address(pk_bytes: vector<u8>): vector<u8> {
        let data = hash::keccak256(&pk_bytes);
        let result = vector::empty<u8>();

        let i = 12;
        while (i < 32) {
            let v = vector::borrow(&data, i);
            vector::push_back(&mut result, *v);
            i = i + 1
        };
        result
    }
}

// #[test_only]
// module sui::devnet_didTests {
//     use sui::did::{Self, Auth, Did, GlobleStorage,KYCInfo};
//     use sui::test_scenario as ts;
//     use sui::transfer;
//     use std::string;

//     #[test]
//     fun test_claim() {
//         let owner = @0xC0FFEE;
//         let user1 = @0xA1;

//         let scenario_val = test_scenario::begin(user1);
//         let scenario = &mut scenario_val;

//         test_scenario::next_tx(scenario, owner);
//         {
//             counter::init(test_scenario::ctx(scenario));
//         };

//         test_scenario::next_tx(scenario, user1);
//         {
//             let counter_val = test_scenario::take_shared<counter::Counter>(scenario);
//             let did = &mut GlobleStorage;

//             counter::increment(counter);
//             counter::increment(counter);
//             counter::increment(counter);
//             test_scenario::return_shared(counter_val);
//         };

//         test_scenario::end(scenario_val);
//     }
// }
