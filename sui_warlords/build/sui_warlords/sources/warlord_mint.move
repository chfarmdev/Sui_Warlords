#[lint_allow(self_transfer)]
module sui_warlords::warlord_mint {
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::pay;    
    //RNG Logic
    use sui_warlords::rand;  
        
    // Hero NFT, mintable for 5 SUI
    struct SuiWarlordNFT has key, store {
        id: UID,
        // Name for the Hero
        name: string::String,
        // Description of the Hero
        description: string::String,
        // Class of the Warlord
        class: String,
        //Level of the Warlord
        level: u64,
        // URL for the Hero
        url: Url,
        // Attributes and stats of the Hero
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }
   
    // ===== Events =====

    struct SuiWarlordMinted has copy, drop {
        // The Object ID of the Warlord
        object_id: ID,
        // The creator of the warlord
        creator: address,
        // The name of the Warlord (User defined)
        name: string::String,
        // The description of the Warlord (User defined)
        description: string::String,
        // Class of the Warlord
        class: string::String,
        //Level of the Warlord
        level: u64,
        // URL of the Warlord
        url: Url,
        // Attributes and stats of the Warlord
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }

    // ===== Public view functions =====

    // Get the Heroes Name
    public fun get_name(nft: &SuiWarlordNFT): string::String {
        nft.name
    }

    // Get the Heroes Description
    public fun get_description(nft: &SuiWarlordNFT): string::String {
        nft.description
    }

    // Get the Heroes Class 
    public fun get_class(nft: &SuiWarlordNFT): string::String {
        nft.class
    }

    // Get the Heroes Level. Starts at 1, max at 10, then class mutation.
    public fun get_level(nft: &SuiWarlordNFT): u64 {
        nft.level
    }

    // Get the Heroes Url
    public fun url(nft: &SuiWarlordNFT): Url {
       nft.url
    }

    // Get the Heroes Strength
    public fun get_strength(nft: &SuiWarlordNFT): u64 {
        nft.strength
    }
 
    // Get the Heroes `Endurance'
    public fun get_endurance(nft: &SuiWarlordNFT): u64 {
        nft.endurance
    }

    // Get the Heroes `Dexterity'
    public fun get_dexterity(nft: &SuiWarlordNFT): u64 {
        nft.dexterity
    }

    // Get the Heroes `Agility'
    public fun get_agility(nft: &SuiWarlordNFT): u64 {
        nft.agility
    }

    // Get the Heroes `Intelligence'
    public fun get_intelligence(nft: &SuiWarlordNFT): u64 {
        nft.intelligence
    }

    // Get the Heroes `Wisdom'
    public fun get_wisdom(nft: &SuiWarlordNFT): u64 {
        nft.wisdom
    }

    // Get the Heroes `Vitality'
    public fun get_vitality(nft: &SuiWarlordNFT): u64 {
        nft.vitality
    }

    // Get the Heroes `Luck'
    public fun get_luck(nft: &SuiWarlordNFT): u64 {
        nft.luck
    }
      
    const MIN_STAT: u64 = 1;
    const MAX_STAT: u64 = 32;
    const INITIAL_LEVEL: u64 = 1;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const WARLORD_MINT_COST: u64 = 5000000000;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;
    
    // ===== Entrypoints =====   

    
    // Create a new Sui Warlords NFT. Name, description, URL, and address for payment are required arguments
    public fun mint_warlord_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_MINT_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, WARLORD_MINT_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);        
        
        // Hero mint logic
        let nft = SuiWarlordNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            class: string::utf8(b"Recruit"),
            level: INITIAL_LEVEL,
            url: url::new_unsafe_from_bytes(url),
            strength: rand::rng(MIN_STAT, MAX_STAT, ctx),
            endurance: rand::rng(MIN_STAT, MAX_STAT, ctx),
            dexterity: rand::rng(MIN_STAT, MAX_STAT, ctx),
            agility: rand::rng(MIN_STAT, MAX_STAT, ctx),
            intelligence: rand::rng(MIN_STAT, MAX_STAT, ctx),
            wisdom: rand::rng(MIN_STAT, MAX_STAT, ctx),
            vitality: rand::rng(MIN_STAT, MAX_STAT, ctx),
            luck: rand::rng(MIN_STAT, MAX_STAT, ctx)
        };

        event::emit(SuiWarlordMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
            description: nft.description,
            class: nft.class,
            level: nft.level,
            url: nft.url,
            strength: nft.strength,
            endurance: nft.endurance,
            dexterity: nft.dexterity,
            agility: nft.agility,
            intelligence: nft.intelligence,
            wisdom: nft.wisdom,
            vitality: nft.vitality,
            luck: nft.luck,
        });

        transfer::public_transfer(nft, sender);
    }

    // Transfer Warlord NFT to recipient
     public fun warlord_transfer(nft: SuiWarlordNFT, recipient: address) {
        transfer::public_transfer(nft, recipient)
    }

    // Update the name of Warlord to new_name
    public fun warlord_update_name(nft: &mut SuiWarlordNFT, new_name: vector<u8>, _: &mut TxContext) {
        nft.name = string::utf8(new_name)
    }

    // Update the description of Warlord to new_description
    public fun warlord_update_description(nft: &mut SuiWarlordNFT, new_description: vector<u8>, _: &mut TxContext) {
        nft.description = string::utf8(new_description)
    }

    // Permanently delete Warlord
    public fun warlord_burn(nft: SuiWarlordNFT, _: &mut TxContext) {
        let SuiWarlordNFT { id, name: _, description: _, class: _, level: _, url: _, strength: _, endurance: _, dexterity: _, agility: _, intelligence: _, wisdom: _, vitality: _, luck: _} = nft;
        object::delete(id)
    }

    // Level up section, costs 2 SUI, and 1-9 BLOOD depending on desired bonus stats. Allows up to 9 level ups for a max level of 10.
    // Will later create a secondary function that allows leveling with ingame tokens as opposed to SUI.

    const BASECLASS_LVLUP_MIN: u64 = 1;
    const BASECLASS_LVLUP_MAX: u64 = 8;
    const WARLORD_LEVEL_UP_COST: u64 = 2000000000;
    const WARLORD_IS_MAX_LEVEL: u64 = 2;
    const WARLORD_LEVEL_UP_COST_BLOOD: u64 = 1000000000;
    const TOO_MUCH_BLOOD_FOR_LEVEL_UP: u64 = 3;
    
    public fun level_up_warlord(
        warlord: &mut SuiWarlordNFT,
        payment: Coin<SUI>,
        payment2: Coin<sui_warlords::blood::BLOOD>,
        blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= WARLORD_LEVEL_UP_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= WARLORD_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, WARLORD_LEVEL_UP_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 9, set to 9 which is max.
        if (blood_quantity >=9 ) {
            blood_quantity = 9;        
        };
        
        //Trasnfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at max roll per level up. Which is 8 for recruit
    
        let bloodbonus: u64 = (blood_quantity - WARLORD_LEVEL_UP_COST_BLOOD) / WARLORD_LEVEL_UP_COST_BLOOD;
        if (bloodbonus > BASECLASS_LVLUP_MAX) {
            abort TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is level 10, otherwise allow level up.
        if (warlord.level == 10) {
            abort WARLORD_IS_MAX_LEVEL
        }
        else {     
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus  +  (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus +  (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));            
        }
    }

    // Class change section
    // BLOOD and TIME need to be added as costs

    const WARLORD_CLASS_CHANGE_COST: u64 = 10000000000;
    
    public fun class_change_warlord(
        warlord: &mut SuiWarlordNFT,
        payment: Coin<SUI>,
        newclass: string::String,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_CLASS_CHANGE_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, WARLORD_CLASS_CHANGE_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);   
        
        warlord.class = newclass;
    }   
}