#[test_only]
module sui::devnet_didTests {
    use hashkeydid::did;
    use sui::test_scenario;
    // use sui::transfer;
    // use std::debug;

    #[test]
    public fun test_claim() {
        let user1 = @0xA1;
        let user2 = @0xA2;
        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, user1);
        {   
            did::createStorage(test_scenario::ctx(scenario));

        };
        test_scenario::next_tx(scenario, user1);
        {
            let storage = test_scenario::take_shared<did::GlobleStorage>(scenario);
            did::claimDid(&mut storage, b"abc.key", b"https://www.coffee.com", test_scenario::ctx(scenario));
            test_scenario::return_shared(storage);
        };
        test_scenario::next_tx(scenario, user2);
        {
            let storage = test_scenario::take_shared<did::GlobleStorage>(scenario);
            did::claimDid(&mut storage, b"abcd.key", b"https://www.coffee.com", test_scenario::ctx(scenario));
            test_scenario::return_shared(storage);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_addKYC() {
        //public entry fun addKYC(to: address, did: vector<u8>, status: bool, _updateTime: u64, _expireTime: u64, signature: vector<u8>, public_key: vector<u8>, ctx: &mut TxContext)
        let owner = @0xC0FFEE;
        let user1 = @0xA1;

        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
            did::addKYC(user1, b"did",true,1630565678,1730565678,b"5cac8c4c9c8b047b4cea34036fe0ad7243cb5400e873719a5463e8be3b04256087c5a4c372eb38ec80572303acc0d326443f8fd43cd5e89a1e248778cf64050b", b"8b416c28de5302621f432a13091d5ef6677c35808c7908a326189b1ed79b99cc", test_scenario::ctx(scenario));
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_issueDG() {
        //issueDG(to: address, name: vector<u8>, symbol: vector<u8>, url: vector<u8>, evidence: vector<u8>, public_key: vector<u8>, ctx: &mut TxContext)
    }

    #[test]
    public fun test_verifyDIDFormat() {
        assert!(did::verifyDIDFormat(b".key") == false, 0);
        assert!(did::verifyDIDFormat(b"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.key") == false, 0);
        assert!(did::verifyDIDFormat(b"abced.ke") == false, 0);
        assert!(did::verifyDIDFormat(b"jack.key") == true, 0);
    }
}
