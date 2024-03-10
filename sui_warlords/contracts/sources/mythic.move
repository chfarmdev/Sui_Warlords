module sui_warlords::mythic {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::mythic::MYTHIC>
    // One time witness
   
    public struct MYTHIC has drop {}

    // Create treasury cap and base MYTHIC token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: MYTHIC, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"MYTHIC", b"MYTHIC", b"Sui_Warlords MYTHIC essence", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_mythic(
        treasury_cap: &mut TreasuryCap<MYTHIC>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}