// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Example of objects that can be combined to create
/// new objects
module GPTutor::service {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector;

    
    struct ManagerCap has key, store {
        id: UID
    }

    struct HostCap has key, store {
        id: UID
    }

    struct UserDeposit has key, store {
        id: UID,
        user: address,
        amount: Balance<SUI>,
        eachTimeLimit: u64,
    }

    struct ActiveUserList has key {
        id: UID,
        list: vector<UserDeposit>,
    }

    struct ToWithdrawList has key {
        id: UID,
        list: vector<UserDeposit>,
    }

    // TODO
    // struct LastModifyTime has key {
    //     id: UID,
    //     time: u64,
    // }


    
    fun init(ctx: &mut TxContext) {
        transfer::transfer(ManagerCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    
    public entry fun new_host(cap: &ManagerCap, host: address, ctx: &mut TxContext) {
        transfer::transfer(HostCap {
            id: object::new(ctx)
        }, host);
    }

    public entry fun charge_from_users(cap: &HostCap, deposits: &mut ActiveUserList, charge: vector<u64>){
        let i = 0;
        let len = vector::length(&deposits.list);
        while (i < len){
            let item = vector::borrow_mut(&mut deposits.list, i);
            
            i = i+1;
        };
        
    }


    #[test]
    fun test_init() {
        use sui::test_scenario;
        use std::debug;
        // create test addresses representing users
        let admin = @0xad;
        let host = @0xac;
        let user1 = @0xCAFE;
        let user2 = @0xCAFF;
        // first transaction to emulate module initialization
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        debug::print(&admin);
        
        {
            init(test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, admin);
        {
            let managerCap = test_scenario::take_from_sender<ManagerCap>(scenario);
            new_host(&managerCap, host, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, managerCap);
            assert!(false, 1)
        };
        test_scenario::end(scenario_val);
    }
}
