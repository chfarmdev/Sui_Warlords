#[lint_allow(self_transfer)]
module sui_warlords::armorgauntlets {    
    use std::string::{Self, utf8, String};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, sender, TxContext};
    use sui::coin::{Self, Coin};
    use sui::pay;
    
    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;    
    
    //RNG Logic and local modules
    use sui_warlords::rand;
    use sui_warlords::reservoir::{Account};
    use sui_warlords::common::{COMMON};
    use sui_warlords::uncommon::{UNCOMMON};
    use sui_warlords::rare::{RARE};
    use sui_warlords::legendary::{LEGENDARY};
    use sui_warlords::mythic::{MYTHIC};

            
    // Armor NFT
    public struct SuiWarlordArmorGauntlets has key, store {
        id: UID,
        // Armor style
        style: String,        
        // GradeString, controls display element, functionally equivalent to grade
        gradestring: String,
        // Armor grade, effects stat multiplier
        grade: u64,        
        // Primary stat bonus of the Armor, RNG based, functional rarity. Higher bonus are extremely rare.
        bonus: u64,
        // Number of enhancements made to the Armor
        enhancements: u64,
        // Armorlevel of the armor
        armorlevelphysical: u64,
        armorlevelmagical: u64,
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
    

    // Mint event for Armor
    public struct SuiWarlordArmorMintEvent has copy, drop {
        object_id: ID,
        // The creator of the Armor
        creator: address,  
        // Armor style (Cloth, Leather, Chain, Plate)
        style: String,
        // GradeString, controls display element, functionally equivalent to grade
        gradestring: String,
        // Armor grade, affects stat multiplier
        grade: u64,        
        // Primary stat bonus of the Armor, RNG based, functional rarity. Higher bonus are extremely rare.
        bonus: u64,
        // Number of enhancements made to the Armor
        enhancements: u64,        
        // Armorlevel of the armor
        armorlevelphysical: u64,
        armorlevelmagical: u64,
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

    // Enhancement event for Armor
    public struct SuiWarlordArmorEnhancementEvent has copy, drop {
        object_id: ID,        
        // Number of enhancements made to the Armor
        enhancements: u64,        
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

    // One-Time-Witness for the module
    public struct ARMORGAUNTLETS has drop {}

    // Init to claim publisher object and create initial display configuration
    fun init(otw: ARMORGAUNTLETS, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),            
            utf8(b"project_url"),            
        ];

        let values = vector[
            // Name references gradestring / style /slot properties "Common Plate Gauntlets"
            utf8(b"{gradestring} {style} Gauntlets"),
            // Link references static URL + id property
            utf8(b"https://suiwarlords.com/main/armor/gauntlets/{id}"),
            // For `image_url` use an IPFS template + `image_url` property.
            utf8(b"ipfs://{gradestring}/{enhancements}/{style}/Gauntlets"),            
            // Project URL
            utf8(b"https://suiwarlords.com"),            
        ];

        // Claim the Publisher for the module
        let publisher = package::claim(otw, ctx);

        // Get a new Display object for the Gauntlets Armor type
        let mut display = display::new_with_fields<SuiWarlordArmorGauntlets>(
            &publisher, keys, values, ctx
        );

        // Commit first version of Display to apply changes
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }


    // ===== Setters & Getters =====
    
    public fun get_gauntlets_armorlevelphysical(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.armorlevelphysical
    }

    public fun get_gauntlets_armorlevelmagical(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.armorlevelmagical
    }

    public fun get_gauntlets_strength(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.strength
    }

    public fun get_gauntlets_endurance(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.endurance
    }

    public fun get_gauntlets_dexterity(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.dexterity
    }

    public fun get_gauntlets_agility(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.agility
    }

    public fun get_gauntlets_intelligence(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.intelligence
    }

    public fun get_gauntlets_wisdom(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.wisdom
    }

    public fun get_gauntlets_vitality(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.vitality
    }

    public fun get_gauntlets_luck(armor: &SuiWarlordArmorGauntlets): u64 {
        armor.luck
    }
    

    const MIN_ARMOR_STAT: u8 = 0;
    const MAX_ARMOR_STAT: u8 = 8;
    const PRIMARY_STAT_BONUS: u64 = 8;
    
    const ZERO: u64 = 0;    
    
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    
    const ARMOR_COMMON_TIME_COST: u64 = 2;
    const ARMOR_COMMON_COST: u64 = 2;
    const ARMOR_COMMON_GRADE: u64 = 1;    
    
    const TEMPBONUSMIN: u8 = 0;
    const TEMPBONUSMAX: u8 = 255; 

    const E_INSUFFICIENT_PAYMENT: u64 = 0;

    // Create a new Sui Warlords COMMON Gauntlets Armor NFT. Style, TIME payment, and COMMON payment are required fields
    // URL will be managed by a display object   
    public fun armor_mint_common_gauntlets(
        style: String,               
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::common::COMMON>,        
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);      

        // Check users balance and throw error if too low
        assert!(value >= ARMOR_COMMON_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ARMOR_COMMON_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_COMMON_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ARMOR_COMMON_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);        
        
        // Random number between 0 & 255 to derive stat bonus
        let tempbonus = rand::rng(TEMPBONUSMIN, TEMPBONUSMAX, ctx);
        let armorstatbonus = sui_warlords::armorgauntlets::armor_random_bonus(tempbonus);

        let mut armor = SuiWarlordArmorGauntlets {
            id: object::new(ctx),
            style: style,                            
            gradestring: utf8(b"Common"),  
            grade: ARMOR_COMMON_GRADE,
            bonus: armorstatbonus,
            enhancements: ZERO,                        
            // Random stats
            armorlevelphysical: ZERO,
            armorlevelmagical: ZERO,           
            strength: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            endurance: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            dexterity: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            agility: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            intelligence: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            wisdom: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            vitality: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            luck: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx)                            
            };

            if (style == string::utf8(b"Cloth")) {
                armor.intelligence = armor.intelligence + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.wisdom = armor.wisdom + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 1 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 4 + armor.grade;
            };

            if (style == string::utf8(b"Leather")) {
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.agility = armor.agility + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 2 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 3 + armor.grade;
            };

            if (style == string::utf8(b"Mail")) {
                armor.strength = armor.strength + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 3 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 2 + armor.grade;
            };

            if (style == string::utf8(b"Plate")) {
                armor.endurance = armor.endurance + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.vitality = armor.vitality + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 4 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 1 + armor.grade;
            };

            armor.strength = armor.strength * armor.grade;
            armor.endurance = armor.endurance * armor.grade;
            armor.dexterity = armor.dexterity * armor.grade;
            armor.agility = armor.agility * armor.grade;
            armor.intelligence = armor.intelligence * armor.grade;
            armor.wisdom = armor.wisdom * armor.grade;
            armor.vitality = armor.vitality * armor.grade;
            armor.luck = armor.luck * armor.grade;

            event::emit(SuiWarlordArmorMintEvent {
            object_id: object::id(&armor),
            creator: sender,
            style: armor.style,           
            gradestring: armor.gradestring,
            grade: armor.grade,
            bonus: armor.bonus,
            enhancements: armor.enhancements,            
            armorlevelphysical: armor.armorlevelphysical,
            armorlevelmagical: armor.armorlevelmagical,
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


    const ARMOR_UNCOMMON_TIME_COST: u64 = 4;
    const ARMOR_UNCOMMON_COST: u64 = 4;
    const ARMOR_UNCOMMON_GRADE: u64 = 2;

    // Create a new Sui Warlords UNCOMMON Gauntlets Armor NFT. Style, TIME payment, and UNCOMMON payment are required fields
    // URL will be managed by a display object    
    public fun armor_mint_uncommon_gauntlets(
        style: String,              
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::uncommon::UNCOMMON>,        
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);      

        // Check users balance and throw error if too low
        assert!(value >= ARMOR_UNCOMMON_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ARMOR_UNCOMMON_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_UNCOMMON_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ARMOR_UNCOMMON_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);        
        
        // Random number between 0 & 256 to derive stat bonus
        let tempbonus = rand::rng(TEMPBONUSMIN, TEMPBONUSMAX, ctx);
        let armorstatbonus = sui_warlords::armorgauntlets::armor_random_bonus(tempbonus);

        let mut armor = SuiWarlordArmorGauntlets {
            id: object::new(ctx),
            style: style,           
            gradestring: utf8(b"Uncommon"),  
            grade: ARMOR_UNCOMMON_GRADE,
            bonus: armorstatbonus,
            enhancements: ZERO,                        
            // Random stats
            armorlevelphysical: ZERO,
            armorlevelmagical: ZERO,           
            strength: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            endurance: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            dexterity: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            agility: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            intelligence: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            wisdom: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            vitality: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            luck: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx)                            
            };

            if (style == string::utf8(b"Cloth")) {
                armor.intelligence = armor.intelligence + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.wisdom = armor.wisdom + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 1 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 4 + armor.grade;
            };

            if (style == string::utf8(b"Leather")) {
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.agility = armor.agility + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 2 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 3 + armor.grade;
            };

            if (style == string::utf8(b"Mail")) {
                armor.strength = armor.strength + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 3 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 2 + armor.grade;
            };

            if (style == string::utf8(b"Plate")) {
                armor.endurance = armor.endurance + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.vitality = armor.vitality + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 4 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 1 + armor.grade;
            };

            armor.strength = armor.strength * armor.grade;
            armor.endurance = armor.endurance * armor.grade;
            armor.dexterity = armor.dexterity * armor.grade;
            armor.agility = armor.agility * armor.grade;
            armor.intelligence = armor.intelligence * armor.grade;
            armor.wisdom = armor.wisdom * armor.grade;
            armor.vitality = armor.vitality * armor.grade;
            armor.luck = armor.luck * armor.grade;

            event::emit(SuiWarlordArmorMintEvent {
            object_id: object::id(&armor),
            creator: sender,
            style: armor.style,            
            gradestring: armor.gradestring,
            grade: armor.grade,
            bonus: armor.bonus,
            enhancements: armor.enhancements,            
            armorlevelphysical: armor.armorlevelphysical,
            armorlevelmagical: armor.armorlevelmagical,
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


    const ARMOR_RARE_TIME_COST: u64 = 6;
    const ARMOR_RARE_COST: u64 = 6;
    const ARMOR_RARE_GRADE: u64 = 3;

    // Create a new Sui Warlords RARE Gauntlets Armor NFT. Style, TIME payment, and RARE payment are required fields
    // URL will be managed by a display object     
    public fun armor_mint_rare_gauntlets(
        style: String,              
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::rare::RARE>,        
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);      

        // Check users balance and throw error if too low
        assert!(value >= ARMOR_RARE_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ARMOR_RARE_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_RARE_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ARMOR_RARE_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);        
        
        // Random number between 0 & 256 to derive stat bonus
        let tempbonus = rand::rng(TEMPBONUSMIN, TEMPBONUSMAX, ctx);
        let armorstatbonus = sui_warlords::armorgauntlets::armor_random_bonus(tempbonus);

        let mut armor = SuiWarlordArmorGauntlets {
            id: object::new(ctx),
            style: style,
            gradestring: utf8(b"Rare"),   
            grade: ARMOR_RARE_GRADE,
            bonus: armorstatbonus,
            enhancements: ZERO,                        
            // Random stats
            armorlevelphysical: ZERO,
            armorlevelmagical: ZERO,           
            strength: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            endurance: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            dexterity: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            agility: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            intelligence: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            wisdom: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            vitality: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            luck: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx)                            
            };

            if (style == string::utf8(b"Cloth")) {
                armor.intelligence = armor.intelligence + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.wisdom = armor.wisdom + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 1 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 4 + armor.grade;
            };

            if (style == string::utf8(b"Leather")) {
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.agility = armor.agility + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 2 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 3 + armor.grade;
            };

            if (style == string::utf8(b"Mail")) {
                armor.strength = armor.strength + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 3 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 2 + armor.grade;
            };

            if (style == string::utf8(b"Plate")) {
                armor.endurance = armor.endurance + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.vitality = armor.vitality + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 4 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 1 + armor.grade;
            };

            armor.strength = armor.strength * armor.grade;
            armor.endurance = armor.endurance * armor.grade;
            armor.dexterity = armor.dexterity * armor.grade;
            armor.agility = armor.agility * armor.grade;
            armor.intelligence = armor.intelligence * armor.grade;
            armor.wisdom = armor.wisdom * armor.grade;
            armor.vitality = armor.vitality * armor.grade;
            armor.luck = armor.luck * armor.grade;

            event::emit(SuiWarlordArmorMintEvent {
            object_id: object::id(&armor),
            creator: sender,
            style: armor.style,            
            gradestring: armor.gradestring,
            grade: armor.grade,
            bonus: armor.bonus,
            enhancements: armor.enhancements,            
            armorlevelphysical: armor.armorlevelphysical,
            armorlevelmagical: armor.armorlevelmagical,
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


    const ARMOR_LEGENDARY_TIME_COST: u64 = 8;
    const ARMOR_LEGENDARY_COST: u64 = 8;
    const ARMOR_LEGENDARY_GRADE: u64 = 4;

    // Create a new Sui Warlords Legendary Gauntlets Armor NFT. Style, TIME payment, and LEGENDARY payment are required fields
    // URL will be managed by a display object   
    public fun armor_mint_legendary_gauntlets(
        style: String,              
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::legendary::LEGENDARY>,        
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);      

        // Check users balance and throw error if too low
        assert!(value >= ARMOR_LEGENDARY_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ARMOR_LEGENDARY_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_LEGENDARY_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ARMOR_LEGENDARY_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);        
        
        // Random number between 0 & 256 to derive stat bonus
        let tempbonus = rand::rng(TEMPBONUSMIN, TEMPBONUSMAX, ctx);
        let armorstatbonus = sui_warlords::armorgauntlets::armor_random_bonus(tempbonus);

        let mut armor = SuiWarlordArmorGauntlets {
            id: object::new(ctx),
            style: style,
            gradestring: utf8(b"Legendary"),   
            grade: ARMOR_LEGENDARY_GRADE,
            bonus: armorstatbonus,
            enhancements: ZERO,                        
            // Random stats
            armorlevelphysical: ZERO,
            armorlevelmagical: ZERO,           
            strength: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            endurance: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            dexterity: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            agility: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            intelligence: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            wisdom: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            vitality: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            luck: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx)                            
            };

            if (style == string::utf8(b"Cloth")) {
                armor.intelligence = armor.intelligence + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.wisdom = armor.wisdom + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 1 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 4 + armor.grade;
            };

            if (style == string::utf8(b"Leather")) {
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.agility = armor.agility + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 2 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 3 + armor.grade;
            };

            if (style == string::utf8(b"Mail")) {
                armor.strength = armor.strength + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 3 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 2 + armor.grade;
            };

            if (style == string::utf8(b"Plate")) {
                armor.endurance = armor.endurance + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.vitality = armor.vitality + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 4 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 1 + armor.grade;
            };

            armor.strength = armor.strength * armor.grade;
            armor.endurance = armor.endurance * armor.grade;
            armor.dexterity = armor.dexterity * armor.grade;
            armor.agility = armor.agility * armor.grade;
            armor.intelligence = armor.intelligence * armor.grade;
            armor.wisdom = armor.wisdom * armor.grade;
            armor.vitality = armor.vitality * armor.grade;
            armor.luck = armor.luck * armor.grade;

            event::emit(SuiWarlordArmorMintEvent {
            object_id: object::id(&armor),
            creator: sender,
            style: armor.style,           
            gradestring: armor.gradestring,
            grade: armor.grade,
            bonus: armor.bonus,
            enhancements: armor.enhancements,            
            armorlevelphysical: armor.armorlevelphysical,
            armorlevelmagical: armor.armorlevelmagical,
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


    const ARMOR_MYTHIC_TIME_COST: u64 = 10;
    const ARMOR_MYTHIC_COST: u64 = 10;
    const ARMOR_MYTHIC_GRADE: u64 = 5;

    // Create a new Sui Warlords MYTHIC Gauntlets Armor NFT. Style, TIME payment, and MYTHIC payment are required fields
    // URL will be managed by a display object   
    public fun armor_mint_mythic_gauntlets(
        style: String,          
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::mythic::MYTHIC>,        
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);      

        // Check users balance and throw error if too low
        assert!(value >= ARMOR_MYTHIC_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ARMOR_MYTHIC_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ARMOR_MYTHIC_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ARMOR_MYTHIC_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);        
        
        // Random number between 0 & 256 to derive stat bonus
        let tempbonus = rand::rng(TEMPBONUSMIN, TEMPBONUSMAX, ctx);
        let armorstatbonus = sui_warlords::armorgauntlets::armor_random_bonus(tempbonus);

        let mut armor = SuiWarlordArmorGauntlets {
            id: object::new(ctx),
            style: style,
            gradestring: utf8(b"Mythic"),  
            grade: ARMOR_MYTHIC_GRADE,
            bonus: armorstatbonus,
            enhancements: ZERO,                        
            // Random stats
            armorlevelphysical: ZERO,
            armorlevelmagical: ZERO,           
            strength: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            endurance: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            dexterity: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            agility: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            intelligence: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            wisdom: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            vitality: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx),
            luck: rand::rng(MIN_ARMOR_STAT, MAX_ARMOR_STAT, ctx)                            
            };

            if (style == string::utf8(b"Cloth")) {
                armor.intelligence = armor.intelligence + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.wisdom = armor.wisdom + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 1 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 4 + armor.grade;
            };

            if (style == string::utf8(b"Leather")) {
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.agility = armor.agility + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 2 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 3 + armor.grade;
            };

            if (style == string::utf8(b"Mail")) {
                armor.strength = armor.strength + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.dexterity = armor.dexterity + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 3 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 2 + armor.grade;
            };

            if (style == string::utf8(b"Plate")) {
                armor.endurance = armor.endurance + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.vitality = armor.vitality + armorstatbonus + PRIMARY_STAT_BONUS;
                armor.armorlevelphysical = armor.armorlevelphysical + 4 + armor.grade;
                armor.armorlevelmagical = armor.armorlevelmagical + 1 + armor.grade;
            };

            armor.strength = armor.strength * armor.grade;
            armor.endurance = armor.endurance * armor.grade;
            armor.dexterity = armor.dexterity * armor.grade;
            armor.agility = armor.agility * armor.grade;
            armor.intelligence = armor.intelligence * armor.grade;
            armor.wisdom = armor.wisdom * armor.grade;
            armor.vitality = armor.vitality * armor.grade;
            armor.luck = armor.luck * armor.grade;

            event::emit(SuiWarlordArmorMintEvent {
            object_id: object::id(&armor),
            creator: sender,
            style: armor.style,          
            gradestring: armor.gradestring,
            grade: armor.grade,
            bonus: armor.bonus,
            enhancements: armor.enhancements,            
            armorlevelphysical: armor.armorlevelphysical,
            armorlevelmagical: armor.armorlevelmagical,
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


    const TWO_STAT_BONUS: u64 = 2;
    const FOUR_STAT_BONUS: u64 = 4;
    const SIX_STAT_BONUS: u64 = 6;
    const EIGHT_STAT_BONUS: u64 = 8;
    const TEN_STAT_BONUS: u64 = 10;
    const TWELVE_STAT_BONUS: u64 = 12;
    const FOURTEEN_STAT_BONUS: u64 = 14;
    const SIXTEEN_STAT_BONUS: u64 = 16;
    const TWENTY_STAT_BONUS: u64 = 20;
    const TWENTYFOUR_STAT_BONUS: u64 = 24;

    // Helper function for randomly assigning a stat bonus roughly equating to level/rarity.
    fun armor_random_bonus(tempbonus: u64): u64 {
        if (tempbonus <= 94) {
            TWO_STAT_BONUS
        }        
        else if (tempbonus <= 124) {
            FOUR_STAT_BONUS
        }
        else if (tempbonus <= 151) {
            SIX_STAT_BONUS
        }     
        else if (tempbonus <= 175) {
            EIGHT_STAT_BONUS
        }
        else if (tempbonus <= 196) {
            TEN_STAT_BONUS
        }     
        else if (tempbonus <= 214) {
            TWELVE_STAT_BONUS
        }
        else if (tempbonus <= 229) {
            FOURTEEN_STAT_BONUS
        }
        else if (tempbonus <= 241) {
            SIXTEEN_STAT_BONUS
        }
        else if (tempbonus <= 250) {
            TWENTY_STAT_BONUS
        }
        else {
            TWENTYFOUR_STAT_BONUS
        }        
    }


    // Transfer Helm Armor to recipient
     public fun gauntlets_armor_transfer(armor: SuiWarlordArmorGauntlets, recipient: address) {
        transfer::public_transfer(armor, recipient)
    }


    const ENHANCEMENT_RNG_MIN: u8 = 0;
    const ENHANCEMENT_RNG_MAX: u8 = 100;

    const ENHANCEMENT_COMMON_TIME_COST: u64 = 2;
    const ENHANCEMENT_COMMON_COST: u64 = 2; 
    const E_ARMOR_CANNOT_BE_FURTHER_ENHANCED: u64 = 9;
    const E_ARMOR_WRONG_GRADE: u64 = 10;

    // Enhance common gauntlets armor function. Chance to burn item scales with enhancement level.    
    public fun gauntlets_armor_enhance_common(
        armor: SuiWarlordArmorGauntlets,
        accobj: &mut Account,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::common::COMMON>,               
        ctx: &mut TxContext,
        ) {        
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Abort if armor has been enhanced 10 times already
        if (armor.enhancements >= 10) {
            abort E_ARMOR_CANNOT_BE_FURTHER_ENHANCED
        };
        // Abort if not grade 1, COMMON
        if (armor.grade != 1) {
            abort E_ARMOR_WRONG_GRADE
        };

        // Check users balance and throw error if not enough TIME or COMMON
        assert!(value >= ENHANCEMENT_COMMON_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ENHANCEMENT_COMMON_COST, E_INSUFFICIENT_PAYMENT);

        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ENHANCEMENT_COMMON_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ENHANCEMENT_COMMON_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);

        let random = rand::rng(ENHANCEMENT_RNG_MIN, ENHANCEMENT_RNG_MAX, ctx);
        let chancetoburn = armor.enhancements * 5;
        if (random <= chancetoburn) {
            gauntlets_armor_burn(armor, accobj, ctx);
        }
        else {
            let mut armor2 = armor;
            gauntlets_armor_enhance(&mut armor2);

            // Emit event for enhancement changes
            event::emit(SuiWarlordArmorEnhancementEvent {
            object_id: object::id(&armor2),            
            enhancements: armor2.enhancements,           
            strength: armor2.strength,
            endurance: armor2.endurance,
            dexterity: armor2.dexterity,
            agility: armor2.agility,
            intelligence: armor2.intelligence,
            wisdom: armor2.wisdom,
            vitality: armor2.vitality,
            luck: armor2.luck,
            });

            // Transfer back to user after enhancement 
            transfer::public_transfer(armor2, sender);  
        }                       
    }


    const ENHANCEMENT_UNCOMMON_TIME_COST: u64 = 2;
    const ENHANCEMENT_UNCOMMON_COST: u64 = 2;     

    // Enhance uncommon gauntlets armor function. Chance to burn item scales with enhancement level.    
    public fun gauntlets_armor_enhance_uncommon(
        armor: SuiWarlordArmorGauntlets,
        accobj: &mut Account,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::uncommon::UNCOMMON>,               
        ctx: &mut TxContext,
        ) {        
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Abort if armor has been enhanced 10 times already
        if (armor.enhancements >= 10) {
            abort E_ARMOR_CANNOT_BE_FURTHER_ENHANCED
        };
        // Abort if not grade 2, UNCOMMON
        if (armor.grade != 2) {
            abort E_ARMOR_WRONG_GRADE
        };

        // Check users balance and throw error if not enough TIME or UNCOMMON
        assert!(value >= ENHANCEMENT_UNCOMMON_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ENHANCEMENT_UNCOMMON_COST, E_INSUFFICIENT_PAYMENT);

        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ENHANCEMENT_UNCOMMON_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ENHANCEMENT_UNCOMMON_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);

        let random = rand::rng(ENHANCEMENT_RNG_MIN, ENHANCEMENT_RNG_MAX, ctx);
        let chancetoburn = armor.enhancements * 5;
        if (random <= chancetoburn) {
            gauntlets_armor_burn(armor, accobj, ctx);
        }
        else {
            let mut armor2 = armor;
            gauntlets_armor_enhance(&mut armor2);

            // Emit event for enhancement changes
            event::emit(SuiWarlordArmorEnhancementEvent {
            object_id: object::id(&armor2),            
            enhancements: armor2.enhancements,           
            strength: armor2.strength,
            endurance: armor2.endurance,
            dexterity: armor2.dexterity,
            agility: armor2.agility,
            intelligence: armor2.intelligence,
            wisdom: armor2.wisdom,
            vitality: armor2.vitality,
            luck: armor2.luck,
            });

            // Transfer back to user after enhancement 
            transfer::public_transfer(armor2, sender);  
        }                       
    }


    const ENHANCEMENT_RARE_TIME_COST: u64 = 2;
    const ENHANCEMENT_RARE_COST: u64 = 2;     

    // Enhance rare gauntlets armor function. Chance to burn item scales with enhancement level.    
    public fun gauntlets_armor_enhance_rare(
        armor: SuiWarlordArmorGauntlets,
        accobj: &mut Account,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::rare::RARE>,               
        ctx: &mut TxContext,
        ) {        
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Abort if armor has been enhanced 10 times already
        if (armor.enhancements >= 10) {
            abort E_ARMOR_CANNOT_BE_FURTHER_ENHANCED
        };
        // Abort if not grade 3, RARE
        if (armor.grade != 3) {
            abort E_ARMOR_WRONG_GRADE
        };

        // Check users balance and throw error if not enough TIME or RARE
        assert!(value >= ENHANCEMENT_RARE_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ENHANCEMENT_RARE_COST, E_INSUFFICIENT_PAYMENT);

        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ENHANCEMENT_RARE_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ENHANCEMENT_RARE_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);

        let random = rand::rng(ENHANCEMENT_RNG_MIN, ENHANCEMENT_RNG_MAX, ctx);
        let chancetoburn = armor.enhancements * 5;
        if (random <= chancetoburn) {
            gauntlets_armor_burn(armor, accobj, ctx);
        }
        else {
            let mut armor2 = armor;
            gauntlets_armor_enhance(&mut armor2);

            // Emit event for enhancement changes
            event::emit(SuiWarlordArmorEnhancementEvent {
            object_id: object::id(&armor2),            
            enhancements: armor2.enhancements,           
            strength: armor2.strength,
            endurance: armor2.endurance,
            dexterity: armor2.dexterity,
            agility: armor2.agility,
            intelligence: armor2.intelligence,
            wisdom: armor2.wisdom,
            vitality: armor2.vitality,
            luck: armor2.luck,
            });

            // Transfer back to user after enhancement 
            transfer::public_transfer(armor2, sender);  
        }                       
    }


    const ENHANCEMENT_LEGENDARY_TIME_COST: u64 = 2;
    const ENHANCEMENT_LEGENDARY_COST: u64 = 2;     

    // Enhance legendary gauntlets armor function. Chance to burn item scales with enhancement level.    
    public fun gauntlets_armor_enhance_legendary(
        armor: SuiWarlordArmorGauntlets,
        accobj: &mut Account,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::legendary::LEGENDARY>,               
        ctx: &mut TxContext,
        ) {        
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Abort if armor has been enhanced 10 times already
        if (armor.enhancements >= 10) {
            abort E_ARMOR_CANNOT_BE_FURTHER_ENHANCED
        };
        // Abort if not grade 4, LEGENDARY
        if (armor.grade != 4) {
            abort E_ARMOR_WRONG_GRADE
        };

        // Check users balance and throw error if not enough TIME or UNCOMMON
        assert!(value >= ENHANCEMENT_LEGENDARY_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ENHANCEMENT_LEGENDARY_COST, E_INSUFFICIENT_PAYMENT);

        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ENHANCEMENT_LEGENDARY_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ENHANCEMENT_LEGENDARY_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);

        let random = rand::rng(ENHANCEMENT_RNG_MIN, ENHANCEMENT_RNG_MAX, ctx);
        let chancetoburn = armor.enhancements * 5;
        if (random <= chancetoburn) {
            gauntlets_armor_burn(armor, accobj, ctx);
        }
        else {
            let mut armor2 = armor;
            gauntlets_armor_enhance(&mut armor2);

            // Emit event for enhancement changes
            event::emit(SuiWarlordArmorEnhancementEvent {
            object_id: object::id(&armor2),            
            enhancements: armor2.enhancements,           
            strength: armor2.strength,
            endurance: armor2.endurance,
            dexterity: armor2.dexterity,
            agility: armor2.agility,
            intelligence: armor2.intelligence,
            wisdom: armor2.wisdom,
            vitality: armor2.vitality,
            luck: armor2.luck,
            });

            // Transfer back to user after enhancement 
            transfer::public_transfer(armor2, sender);  
        }                       
    }
    

    const ENHANCEMENT_MYTHIC_TIME_COST: u64 = 2;
    const ENHANCEMENT_MYTHIC_COST: u64 = 2;     

    // Enhance mythic gauntlets armor function. Chance to burn item scales with enhancement level.    
    public fun gauntlets_armor_enhance_mythic(
        armor: SuiWarlordArmorGauntlets,
        accobj: &mut Account,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::mythic::MYTHIC>,               
        ctx: &mut TxContext,
        ) {        
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Abort if armor has been enhanced 10 times already
        if (armor.enhancements >= 10) {
            abort E_ARMOR_CANNOT_BE_FURTHER_ENHANCED
        };
        // Abort if not grade 5, MYTHIC
        if (armor.grade != 5) {
            abort E_ARMOR_WRONG_GRADE
        };

        // Check users balance and throw error if not enough TIME or MYTHIC
        assert!(value >= ENHANCEMENT_MYTHIC_TIME_COST, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ENHANCEMENT_MYTHIC_COST, E_INSUFFICIENT_PAYMENT);

        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ENHANCEMENT_MYTHIC_TIME_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        pay::split_and_transfer(&mut payment2, ENHANCEMENT_MYTHIC_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        transfer::public_transfer(payment2, sender);

        let random = rand::rng(ENHANCEMENT_RNG_MIN, ENHANCEMENT_RNG_MAX, ctx);
        let chancetoburn = armor.enhancements * 5;
        if (random <= chancetoburn) {
            gauntlets_armor_burn(armor, accobj, ctx);
        }
        else {
            let mut armor2 = armor;
            gauntlets_armor_enhance(&mut armor2);

            // Emit event for enhancement changes
            event::emit(SuiWarlordArmorEnhancementEvent {
            object_id: object::id(&armor2),            
            enhancements: armor2.enhancements,           
            strength: armor2.strength,
            endurance: armor2.endurance,
            dexterity: armor2.dexterity,
            agility: armor2.agility,
            intelligence: armor2.intelligence,
            wisdom: armor2.wisdom,
            vitality: armor2.vitality,
            luck: armor2.luck,
            });

            // Transfer back to user after enhancement 
            transfer::public_transfer(armor2, sender);  
        }                       
    }                    


    // Divide stat by enhancement multipler for effective 20% increase
    // Added base +1 so there's some value in enhancing lower level common items
    // Otherwise base stats of 4 or less can never progress due to enhancement
    const ENHANCEMENT_MULTIPLIER: u64 = 5;

    fun gauntlets_armor_enhance(armor: &mut SuiWarlordArmorGauntlets) {
            armor.enhancements = armor.enhancements + 1; 
            armor.strength = armor.strength + 1 + (armor.strength / ENHANCEMENT_MULTIPLIER);
            armor.endurance = armor.endurance + 1 + (armor.endurance / ENHANCEMENT_MULTIPLIER);
            armor.dexterity = armor.dexterity + 1 + (armor.dexterity / ENHANCEMENT_MULTIPLIER);
            armor.agility = armor.agility + 1 + (armor.agility / ENHANCEMENT_MULTIPLIER);
            armor.intelligence = armor.intelligence + 1 + (armor.intelligence / ENHANCEMENT_MULTIPLIER);
            armor.wisdom = armor.wisdom + 1 + (armor.wisdom / ENHANCEMENT_MULTIPLIER);
            armor.vitality = armor.vitality + 1 + (armor.vitality / ENHANCEMENT_MULTIPLIER);
            armor.luck = armor.luck + 1 + (armor.luck / ENHANCEMENT_MULTIPLIER);                   
    }


    // Need to add some scaling logic so you can't infinite mint common/uncommon items. Still gated by TIME but need to review.
    // By not adding scaling based on existing enhancements, infinite creation of common objects should be restrictive.
    // Even if theoretically possible, items are weak enough to not matter much. Will drive engagement and game transactions.
    // And may ultimately end in a meta of its own.
    public fun gauntlets_armor_burn(armor: SuiWarlordArmorGauntlets, accobj: &mut Account, ctx: &mut TxContext) {
        
        let amount = armor.bonus / 2;
        let recipient = tx_context::sender(ctx);

        if (armor.grade == 1) {
            let essencepayout: Coin<COMMON> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
            transfer::public_transfer(essencepayout, recipient);
        };
        if (armor.grade == 2) {
            let essencepayout: Coin<UNCOMMON> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
            transfer::public_transfer(essencepayout, recipient);
        };
        if (armor.grade == 3) {
            let essencepayout: Coin<RARE> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
            transfer::public_transfer(essencepayout, recipient);
        };
        if (armor.grade == 4) {
            let essencepayout: Coin<LEGENDARY> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
            transfer::public_transfer(essencepayout, recipient);
        };
        if (armor.grade == 5) {
            let essencepayout: Coin<MYTHIC> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
            transfer::public_transfer(essencepayout, recipient);
        };

        let SuiWarlordArmorGauntlets {id, style: _, gradestring: _, grade: _, bonus: _, enhancements: _, armorlevelphysical: _, armorlevelmagical: _, strength: _, endurance: _, dexterity: _, agility: _, intelligence: _, wisdom: _, vitality: _, luck: _} = armor;
        object::delete(id);                              
    }   
}