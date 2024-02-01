module sui_warlords::blood {
    friend sui_warlords::warlord_mint;
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID, UID};  
    use sui::borrow;
    
    // Coin<sui_warlords::blood::BLOOD>
    // One time witness
    
    struct BLOOD has drop {}
    
    struct WrappedBloodCap has key, store {
        id: UID,
        blood_treasury_cap: TreasuryCap<BLOOD>,
    }    
   
    // Create treasury cap and base BLOOD token for SUI Warlords
    // Syntax is witness, decimals, symbol, name, description, icon_url, ctx
    
    fun init(witness: BLOOD, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 0, b"BLOOD", b"BLOOD", b"Sui_Warlords BLOOD currency", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx));
        
        // Share the newly created WrappedBloodCap struct
        transfer::share_object(WrappedBloodCap {
            id: object::new(ctx), 
            blood_treasury_cap: treasury         
        })     
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

    public fun get_wrapped_blood_cap() {
        <WrappedBloodCap as Object>::assert_exists(<ID as From<UID>>::from(<WrappedBloodCap as Keyed>::Key::get()))
    }

    public(friend) fun secure_mint_blood(amount: u64, recipient: address, ctx: &mut TxContext) {
        let WrappedBloodCap { id, blood_treasury_cap, .. } = borrow(&get_wrapped_blood_cap(), ctx).unwrap();
        let new_blood_coin = coin::mint(&blood_treasury_cap, amount, ctx);
        transfer::public_transfer(new_blood_coin, recipient, ctx);
    }
}
