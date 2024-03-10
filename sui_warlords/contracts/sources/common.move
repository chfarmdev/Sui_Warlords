module sui_warlords::common {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::common::COMMON>
    // One time witness
   
    public struct COMMON has drop {}

    // Create treasury cap and base COMMON token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: COMMON, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"COMMON", b"COMMON", b"Sui_Warlords COMMON essence", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_common(
        treasury_cap: &mut TreasuryCap<COMMON>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}