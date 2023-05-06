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
            did::addKYC(user1, b"did.key",true,1630565678,1730565678,x"7cd7e8e9edbf2e32386e1ad622e17851f739a1bb26b0a9ede554ff97b436f17461cedf16bac0ed0bd9699c90fd563508a91535dcddba2965df09cc2bb1cde001", x"cc62332e34bb2d5cd69f60efbb2a36cb916c7eb458301ea36636c4dbb012bd88", test_scenario::ctx(scenario));
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_issueDG() {
        //issueDG(to: address, name: vector<u8>, symbol: vector<u8>, url: vector<u8>, evidence: vector<u8>, public_key: vector<u8>, ctx: &mut TxContext)
        let user1 = @0xA1;
        let user2 = @0xA2;
        let scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, user1);
        {
            did::issueDG(user2, b"did.key", b"did", b"www.test.com", x"7cd7e8e9edbf2e32386e1ad622e17851f739a1bb26b0a9ede554ff97b436f17461cedf16bac0ed0bd9699c90fd563508a91535dcddba2965df09cc2bb1cde001", x"cc62332e34bb2d5cd69f60efbb2a36cb916c7eb458301ea36636c4dbb012bd88", test_scenario::ctx(scenario))
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_verifyDIDFormat() {
        assert!(did::verifyDIDFormat(b".key") == false, 0);
        assert!(did::verifyDIDFormat(b"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.key") == false, 0);
        assert!(did::verifyDIDFormat(b"abced.ke") == false, 0);
        assert!(did::verifyDIDFormat(b"jack.key") == true, 0);
    }
}
