module sui_warlords::legendary {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // Coin<sui_warlords::legendary::LEGENDARY>
    // One time witness
   
    public struct LEGENDARY has drop {}

    // Create treasury cap and base LEGENDARY token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: LEGENDARY, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"LEGENDARY", b"LEGENDARY", b"Sui_Warlords LEGENDARY essence", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun mint_legendary(
        treasury_cap: &mut TreasuryCap<LEGENDARY>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}