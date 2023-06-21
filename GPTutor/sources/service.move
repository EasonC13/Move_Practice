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
    use sui::table::{Self, Table};
    use std::debug;

    
    struct ManagerCap has key, store {
        id: UID
    }

    struct HostCap has key, store {
        id: UID
    }

    struct UserDeposit has key, store {
        id: UID,
        user: address,
        balance: Balance<SUI>,
        eachTimeLimit: u64,
    }

    struct UserTable has key {
        id: UID,
        table: Table<address, UserDeposit>,
        users: vector<address>,
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
        transfer::share_object(UserTable {
            id: object::new(ctx),
            table: table::new(ctx),
            users: vector::empty(),
        });
    }

    
    public entry fun new_host(_cap: &ManagerCap, host: address, ctx: &mut TxContext) {
        transfer::transfer(HostCap {
            id: object::new(ctx)
        }, host);
    }


    fun getAddressFromVector(usedUsers: &vector<address>, i: u64): &address{
        vector::borrow(usedUsers, i)        
    }

    public entry fun charge_from_users(cap: &HostCap, userTable: &mut UserTable, usedUsers: vector<address>, usedValue: vector<u64>, ctx: &mut TxContext){
        assert!(vector::length(&usedUsers) == vector::length(&usedValue), 1);
        let i = 0;
        let len = vector::length(&usedUsers);
        while (i < len){
            let userDeposit = table::borrow_mut(&mut userTable.table, getAddressFromVector(usedUsers, i));
            // // debug::print(&userDeposit);
            // userDeposit.balance = balance - vector::borrow(usedValue, i);
            i = i+1;
        };
        
    }


    #[test]
    fun test_init() {
        use sui::test_scenario;
        // create test addresses representing users
        let admin = @0xad;
        let host = @0xac;
        let user1 = @0xCAFE;
        let user2 = @0xCAFF;
        // first transaction to emulate module initialization
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        {
            init(test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, admin);
        {
            let managerCap = test_scenario::take_from_sender<ManagerCap>(scenario);
            new_host(&managerCap, host, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, managerCap);
            
        };
        test_scenario::next_tx(scenario, host);
        {
            let hostCap = test_scenario::take_from_sender<HostCap>(scenario);
            let userTable = test_scenario::take_shared<UserTable>(scenario);
            charge_from_users(&hostCap, &mut userTable, test_scenario::ctx(scenario));
            test_scenario::return_to_sender(scenario, hostCap);
            test_scenario::return_shared(userTable);
        };
        test_scenario::end(scenario_val);
    }
}
