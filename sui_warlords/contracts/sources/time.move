module sui_warlords::time {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::time::TIME>
    // One time witness
   
    public struct TIME has drop {}

    // Create treasury cap and base TIME token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: TIME, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"TIME", b"TIME", b"Sui_Warlords TIME currency", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_time(
        treasury_cap: &mut TreasuryCap<TIME>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}