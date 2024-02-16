#[lint_allow(self_transfer)]
module sui_warlords::equipment {
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
            
    // Equipment NFT
    public struct SuiWarlordEquipment has key, store {
        id: UID,
        // Type of the Equipment
        slot: String,
        // Tier of the Equipment
        tier: u64,        
        // Level of the Equipment
        level: u64,
        // Number of enhancements made to the Equipment
        enhancements: u64,
        // URL for the Equipment
        url: Url,
        // Attributes and stats of the Equipment
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }

    public struct SuiWarlordEquipmentMinted has copy, drop {
        object_id: ID,
        // The creator of the Equipment
        creator: address,  
        // Type of the Equipment
        slot: String,
        // Tier of the Equipment
        tier: u64,        
        //Level of the Equipment
        level: u64,
        // Number of enhancements made to the Equipment
        enhancements: u64,
        // URL for the Equipment
        url: Url,
        // Attributes and stats of the Equipment
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
    const EIGHT: u64 = 8;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const EQUIPMENT_MINT_COST: u64 = 2000000000;
    const ZERO: u64 = 0;
    const FIVE: u64 = 5;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;

    // Create a new Sui Equipment NFT. URL and address for payment are required arguments
    // URL will be removed and updated eventually to a Pinata IPFS address
    public fun mint_t1_equipment_to_sender(
        url: vector<u8>,
        mut payment: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= EQUIPMENT_MINT_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, EQUIPMENT_MINT_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);        
        
        let tempslot = rand::rng(ONE, FIVE, ctx);

        // Equipment mint logic
        let equipment = SuiWarlordEquipment {
            id: object::new(ctx),                
            slot: random_equipment_type(tempslot), 
            tier: ONE,
            level: ONE,
            enhancements: ZERO,            
            url: url::new_unsafe_from_bytes(url),
            strength: rand::rng(ONE, EIGHT, ctx),
            endurance: rand::rng(ONE, EIGHT, ctx),
            dexterity: rand::rng(ONE, EIGHT, ctx),
            agility: rand::rng(ONE, EIGHT, ctx),
            intelligence: rand::rng(ONE, EIGHT, ctx),
            wisdom: rand::rng(ONE, EIGHT, ctx),
            vitality: rand::rng(ONE, EIGHT, ctx),
            luck: rand::rng(ONE, EIGHT, ctx)
        };

        event::emit(SuiWarlordEquipmentMinted {
            object_id: object::id(&equipment),
            creator: sender,
            slot: equipment.slot,
            tier: equipment.tier,
            level: equipment.level,
            enhancements: equipment.enhancements,
            url: equipment.url,
            strength: equipment.strength,
            endurance: equipment.endurance,
            dexterity: equipment.dexterity,
            agility: equipment.agility,
            intelligence: equipment.intelligence,
            wisdom: equipment.wisdom,
            vitality: equipment.vitality,
            luck: equipment.luck,
        });

        transfer::public_transfer(equipment, sender);
    }

    // Helper function for randomly assigning an equipment type
    public (friend) fun random_equipment_type(tempslot: u64): String {
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

    // Transfer Equipment to recipient
     public fun equipment_transfer(equipment: SuiWarlordEquipment, recipient: address) {
        transfer::public_transfer(equipment, recipient)
    }    
}