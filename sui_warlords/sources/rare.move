module sui_warlords::rare {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::rare::RARE>
    // One time witness
   
    public struct RARE has drop {}

    // Create treasury cap and base RARE token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: RARE, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"RARE", b"RARE", b"Sui_Warlords RARE essence", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_rare(
        treasury_cap: &mut TreasuryCap<RARE>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}