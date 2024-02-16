module sui_warlords::blood {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // `Coin<sui_warlords::time::TIME>`
    // One time witness
   
    public struct BLOOD has drop {}

    // Create treasury cap and base TIME token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: BLOOD, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"BLOOD", b"BLOOD", b"Sui_Warlords BLOOD currency", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_blood(
        treasury_cap: &mut TreasuryCap<BLOOD>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}