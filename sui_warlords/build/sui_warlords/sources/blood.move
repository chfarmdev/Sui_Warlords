module sui_warlords::blood {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    // `Coin<sui_warlords::blood::BLOOD>`
    // One time witness
    
    struct BLOOD has drop {}

    struct WrappedBloodCap {wrapped_blood_cap: TreasuryCap<BLOOD>}

    // Create treasury cap and base BLOOD token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: BLOOD, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"BLOOD", b"BLOOD", b"Sui_Warlords BLOOD currency", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public fun admin_mint_blood(
        blood_treasury_cap: &mut TreasuryCap<BLOOD>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
        ) {
        let coin = coin::mint(blood_treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }

    fun private_mint_blood(
        blood_cap: &mut TreasuryCap<BLOOD>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coin = coin::mint(blood_cap, amount, ctx);
        transfer::public_transfer(coin, recipient)
    }
}