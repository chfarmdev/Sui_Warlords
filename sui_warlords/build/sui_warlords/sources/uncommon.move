module sui_warlords::uncommon {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::uncommon::UNCOMMON>
    // One time witness
   
    public struct UNCOMMON has drop {}

    // Create treasury cap and base UNCOMMON token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: UNCOMMON, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"UNCOMMON", b"UNCOMMON", b"Sui_Warlords UNCOMMON essence", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_uncommon(
        treasury_cap: &mut TreasuryCap<UNCOMMON>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}