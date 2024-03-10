#[lint_allow(self_transfer)]
module sui_warlords::class {    
    use std::string::{String};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::pay;
    
    // Local modules
    use sui_warlords::warlord::{SuiWarlordNFT};
    use sui_warlords::time::{TIME};  
    

    // Class change with SUI    
    // Class change only available at level 10, Intended for converting a recruit into a base class archetype
    // Can change multiple times but you pay the fee each time, cannot change if you hit level 11

    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const WARLORD_CLASS_CHANGE_COST_SUI: u64 = 10000000000;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;
    const E_WARLORD_MUST_BE_LEVEL_TEN_FOR_CLASS_CHANGE: u64 = 4;
    const E_WARLORD_MUST_BE_LEVEL_TWENTY_FOR_CLASS_CHANGE: u64 = 5;
    
    public fun warlord_lvl10_class_change_sui(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        newclass: String,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_CLASS_CHANGE_COST_SUI, E_INSUFFICIENT_PAYMENT);
        
        let warlordlevel = sui_warlords::warlord::get_level(warlord);

        if (warlordlevel == 10) {

            // Split and send the mint cost to admin address        
            pay::split_and_transfer(&mut payment, WARLORD_CLASS_CHANGE_COST_SUI, ADMIN_PAYOUT_ADDRESS, ctx);
        
            // Transfer the remainder back to the user/sender
            transfer::public_transfer(payment, sender);   
        
            sui_warlords::warlord::set_class(warlord, newclass);            
        }
        else {abort E_WARLORD_MUST_BE_LEVEL_TEN_FOR_CLASS_CHANGE}
    }

    // Class change with TIME    
    // Class change only available at level 10, Intended for converting a recruit into a base class archetype
    // Can change multiple times but you pay the fee each time, cannot change if you hit level 11
    const WARLORD_CLASS_CHANGE_COST_TIME: u64 = 20;
    
    public fun warlord_lvl10_class_change_time(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<TIME>,
        newclass: String,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_CLASS_CHANGE_COST_TIME, E_INSUFFICIENT_PAYMENT);
        
        let warlordlevel = sui_warlords::warlord::get_level(warlord);

        if (warlordlevel == 10) {

            // Split and send the mint cost to admin address        
            pay::split_and_transfer(&mut payment, WARLORD_CLASS_CHANGE_COST_TIME, ADMIN_PAYOUT_ADDRESS, ctx);
        
            // Transfer the remainder back to the user/sender
            transfer::public_transfer(payment, sender);   
        
            sui_warlords::warlord::set_class(warlord, newclass)            
        }
        else {abort E_WARLORD_MUST_BE_LEVEL_TEN_FOR_CLASS_CHANGE}
    }

    // Class change with SUI    
    // Class change only available at level 20, Intended for converting a base class into a specialized class
    // Can change multiple times but you pay the fee each time, cannot change if you hit level 21

    public fun warlord_lvl20_class_change_sui(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        newclass: String,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_CLASS_CHANGE_COST_SUI, E_INSUFFICIENT_PAYMENT);
        
        let warlordlevel = sui_warlords::warlord::get_level(warlord);

        if (warlordlevel == 20) {

            // Split and send the mint cost to admin address        
            pay::split_and_transfer(&mut payment, WARLORD_CLASS_CHANGE_COST_SUI, ADMIN_PAYOUT_ADDRESS, ctx);
        
            // Transfer the remainder back to the user/sender
            transfer::public_transfer(payment, sender);   
        
            sui_warlords::warlord::set_class(warlord, newclass)  
        }
        else {abort E_WARLORD_MUST_BE_LEVEL_TWENTY_FOR_CLASS_CHANGE}
    }

    // Class change with TIME
    // Class change only available at level 20, Intended for converting a base class into a specialized class
    // Can change multiple times but you pay the fee each time, cannot change if you hit level 21
       
    public fun warlord_lvl20_class_change_time(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<TIME>,
        newclass: String,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_CLASS_CHANGE_COST_TIME, E_INSUFFICIENT_PAYMENT);
        
        let warlordlevel = sui_warlords::warlord::get_level(warlord);

        if (warlordlevel == 20) {

            // Split and send the mint cost to admin address        
            pay::split_and_transfer(&mut payment, WARLORD_CLASS_CHANGE_COST_TIME, ADMIN_PAYOUT_ADDRESS, ctx);
        
            // Transfer the remainder back to the user/sender
            transfer::public_transfer(payment, sender);   
        
            sui_warlords::warlord::set_class(warlord, newclass)  
        }
        else {abort E_WARLORD_MUST_BE_LEVEL_TWENTY_FOR_CLASS_CHANGE}
    }
}