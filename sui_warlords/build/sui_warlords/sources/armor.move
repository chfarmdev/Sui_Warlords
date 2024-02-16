#[lint_allow(self_transfer)]
module sui_warlords::armor {
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
            
    // Armor NFT
    public struct SuiWarlordArmor has key, store {
        id: UID,
        // Type of the Armor
        slot: String,
        // Tier of the Armor
        tier: u64,        
        // Level of the Armor
        level: u64,
        // Number of enhancements made to the Armor
        enhancements: u64,
        // URL for the Armor
        url: Url,
        // Attributes and stats of the Armor
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }

    public struct SuiWarlordArmorMinted has copy, drop {
        object_id: ID,
        // The creator of the Armor
        creator: address,  
        // Type of the Armor
        slot: String,
        // Tier of the Armor
        tier: u64,        
        //Level of the Armor
        level: u64,
        // Number of enhancements made to the Armor
        enhancements: u64,
        // URL for the Armor
        url: Url,
        // Attributes and stats of the Armor
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }

    const ONE: u64 = 1;
    const NINE: u64 = 9;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const ARMOR_MINT_COST: u64 = 2000000000;
    const ZERO: u64 = 0;
    const SIX: u64 = 6;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;

    // Create a new Sui Warlords Armor NFT. URL and address for payment are required arguments
    // URL will be removed and updated eventually to a Pinata IPFS address
    public fun mint_t1_armor_to_sender(
        url: vector<u8>,
        mut payment: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= ARMOR_MINT_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_MINT_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);        
        
        // Random number between 1 & 5 to derive slot type by string
        let tempslot = rand::rng(ONE, SIX, ctx);

        // Equipment mint logic
        let armor = SuiWarlordArmor {
            id: object::new(ctx),                
            slot: random_armor_type(tempslot), 
            tier: ONE,
            level: ONE,
            enhancements: ZERO,            
            url: url::new_unsafe_from_bytes(url),
            // Random stats between 1 & 9 generates numbers between 1 & 8 due to RNG logic
            strength: rand::rng(ONE, NINE, ctx),
            endurance: rand::rng(ONE, NINE, ctx),
            dexterity: rand::rng(ONE, NINE, ctx),
            agility: rand::rng(ONE, NINE, ctx),
            intelligence: rand::rng(ONE, NINE, ctx),
            wisdom: rand::rng(ONE, NINE, ctx),
            vitality: rand::rng(ONE, NINE, ctx),
            luck: rand::rng(ONE, NINE, ctx)
        };

        event::emit(SuiWarlordArmorMinted {
            object_id: object::id(&armor),
            creator: sender,
            slot: armor.slot,
            tier: armor.tier,
            level: armor.level,
            enhancements: armor.enhancements,
            url: armor.url,
            strength: armor.strength,
            endurance: armor.endurance,
            dexterity: armor.dexterity,
            agility: armor.agility,
            intelligence: armor.intelligence,
            wisdom: armor.wisdom,
            vitality: armor.vitality,
            luck: armor.luck,
        });

        transfer::public_transfer(armor, sender);
    }

    // Helper function for randomly assigning an Armor type
    public (friend) fun random_armor_type(tempslot: u64): String {
        if (tempslot == 1) {
            string::utf8(b"Helmet")
        }
        else if (tempslot == 2) {
            string::utf8(b"Chest")
        }
        else if (tempslot == 3) {
            string::utf8(b"Legs")
        }
        else if (tempslot == 4) {
            string::utf8(b"Boots")
        }
        else {
            string::utf8(b"Gloves")
        }
    }

    // Transfer Armor to recipient
     public fun armor_transfer(armor: SuiWarlordArmor, recipient: address) {
        transfer::public_transfer(armor, recipient)
    }    
}