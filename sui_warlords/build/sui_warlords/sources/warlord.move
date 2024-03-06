#[lint_allow(self_transfer)]
module sui_warlords::warlord {   
    use std::string::{Self, utf8, String};    
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, sender, TxContext};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::pay;
    use sui::clock::{Clock};  
    use sui::dynamic_object_field as dof;  
    
    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display; 

    //RNG Logic and local modules
    use sui_warlords::rand;
    use sui_warlords::reservoir::{Account};
    use sui_warlords::blood::{BLOOD};
    use sui_warlords::time::{TIME};
    use sui_warlords::armorboots::{SuiWarlordArmorBoots};    
    use sui_warlords::armorchest::{SuiWarlordArmorChest}; 
    use sui_warlords::armorgauntlets::{SuiWarlordArmorGauntlets}; 
    use sui_warlords::armorhelmet::{SuiWarlordArmorHelmet}; 
    use sui_warlords::armorleggings::{SuiWarlordArmorLeggings}; 

    friend sui_warlords::class;      


    // Warlord NFT, mintable for 5 SUI, emits BLOOD & TIME from reservoir
    public struct SuiWarlordNFT has key, store {
        id: UID,
        // Name for the Hero, user configurable
        name: String,
        // Description of the Hero, user configurable
        description: String,
        // Class of the Warlord
        class: String,
        //Level of the Warlord
        level: u64,        
        // Timestamp for creation of the NFT
        createtime: u64,
        // Counters for tracking claimed BLOOD & TIME
        claimedblood: u64,
        claimedtime: u64,
        // Stats of the Warlord
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
    public struct SuiWarlordMinted has copy, drop {
        object_id: ID,
        // The creator of the warlord
        creator: address,        
        // The name of the Warlord (User defined)
        name: String,
        // The description of the Warlord (User defined)
        description: String,
        // Class of the Warlord
        class: String,
        // Level of the Warlord
        level: u64,       
        // Stats of the Warlord
        strength: u64,
        endurance: u64,
        dexterity: u64,
        agility: u64,
        intelligence: u64,
        wisdom: u64,
        vitality: u64,
        luck: u64,
    }

    // One-Time-Witness for the module.
    public struct WARLORD has drop {}

    // Init to claim publisher object and create initial display configuration
    fun init(otw: WARLORD, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"description"),
            utf8(b"link"),
            utf8(b"image_url"),            
            utf8(b"project_url"),            
        ];

        let values = vector[
            // Name references Warlord name
            utf8(b"{name}"),
            // Description references Warlord description
            utf8(b"{description}"),
            // Link references static URL + id property
            utf8(b"https://suiwarlords.com/main/warlord/{id}"),
            // image_url references class
            utf8(b"ipfs://{class}"),            
            // Project URL
            utf8(b"https://suiwarlords.com"),            
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Hero` type.
        let mut display = display::new_with_fields<SuiWarlordNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }


    // ===== Dynamic Object Fields =====

    // Equip boots on the warlord    
    public fun boots_equip(warlord: &mut SuiWarlordNFT, boots: SuiWarlordArmorBoots, ctx: &mut TxContext) {
        
        // Check if boots are equipped, if so, remove them and send to user
        if (dof::exists_(&warlord.id, b"Boots") == true) {
            boots_remove(warlord, ctx);
        };
        warlord.strength = warlord.strength + sui_warlords::armorboots::get_boots_strength(&boots);
        warlord.endurance = warlord.endurance + sui_warlords::armorboots::get_boots_endurance(&boots);
        warlord.dexterity = warlord.dexterity + sui_warlords::armorboots::get_boots_dexterity(&boots);
        warlord.agility = warlord.agility + sui_warlords::armorboots::get_boots_agility(&boots);
        warlord.intelligence = warlord.intelligence + sui_warlords::armorboots::get_boots_intelligence(&boots);
        warlord.wisdom = warlord.wisdom + sui_warlords::armorboots::get_boots_wisdom(&boots);
        warlord.vitality = warlord.vitality + sui_warlords::armorboots::get_boots_vitality(&boots);
        warlord.luck = warlord.luck + sui_warlords::armorboots::get_boots_luck(&boots);
        
        dof::add(&mut warlord.id, b"Boots", boots);
    }

    public fun boots_remove(warlord: &mut SuiWarlordNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let boots: SuiWarlordArmorBoots = dof::remove(&mut warlord.id, b"Boots");
        
        warlord.strength = warlord.strength - sui_warlords::armorboots::get_boots_strength(&boots);
        warlord.endurance = warlord.endurance - sui_warlords::armorboots::get_boots_endurance(&boots);
        warlord.dexterity = warlord.dexterity - sui_warlords::armorboots::get_boots_dexterity(&boots);
        warlord.agility = warlord.agility - sui_warlords::armorboots::get_boots_agility(&boots);
        warlord.intelligence = warlord.intelligence - sui_warlords::armorboots::get_boots_intelligence(&boots);
        warlord.wisdom = warlord.wisdom - sui_warlords::armorboots::get_boots_wisdom(&boots);
        warlord.vitality = warlord.vitality - sui_warlords::armorboots::get_boots_vitality(&boots);
        warlord.luck = warlord.luck - sui_warlords::armorboots::get_boots_luck(&boots);

        transfer::public_transfer(boots, sender);
    }


    // Equip chest on the warlord    
    public fun chest_equip(warlord: &mut SuiWarlordNFT, chest: SuiWarlordArmorChest, ctx: &mut TxContext) {
        
        // Check if chest is equipped, if so, remove them and send to user
        if (dof::exists_(&warlord.id, b"Chest") == true) {
            chest_remove(warlord, ctx);
        };
        warlord.strength = warlord.strength + sui_warlords::armorchest::get_chest_strength(&chest);
        warlord.endurance = warlord.endurance + sui_warlords::armorchest::get_chest_endurance(&chest);
        warlord.dexterity = warlord.dexterity + sui_warlords::armorchest::get_chest_dexterity(&chest);
        warlord.agility = warlord.agility + sui_warlords::armorchest::get_chest_agility(&chest);
        warlord.intelligence = warlord.intelligence + sui_warlords::armorchest::get_chest_intelligence(&chest);
        warlord.wisdom = warlord.wisdom + sui_warlords::armorchest::get_chest_wisdom(&chest);
        warlord.vitality = warlord.vitality + sui_warlords::armorchest::get_chest_vitality(&chest);
        warlord.luck = warlord.luck + sui_warlords::armorchest::get_chest_luck(&chest);
        
        dof::add(&mut warlord.id, b"Chest", chest);
    }

    public fun chest_remove(warlord: &mut SuiWarlordNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let chest: SuiWarlordArmorChest = dof::remove(&mut warlord.id, b"Chest");
        
        warlord.strength = warlord.strength - sui_warlords::armorchest::get_chest_strength(&chest);
        warlord.endurance = warlord.endurance - sui_warlords::armorchest::get_chest_endurance(&chest);
        warlord.dexterity = warlord.dexterity - sui_warlords::armorchest::get_chest_dexterity(&chest);
        warlord.agility = warlord.agility - sui_warlords::armorchest::get_chest_agility(&chest);
        warlord.intelligence = warlord.intelligence - sui_warlords::armorchest::get_chest_intelligence(&chest);
        warlord.wisdom = warlord.wisdom - sui_warlords::armorchest::get_chest_wisdom(&chest);
        warlord.vitality = warlord.vitality - sui_warlords::armorchest::get_chest_vitality(&chest);
        warlord.luck = warlord.luck - sui_warlords::armorchest::get_chest_luck(&chest);

        transfer::public_transfer(chest, sender);
    }


    // Equip gauntlets on the warlord    
    public fun gauntlets_equip(warlord: &mut SuiWarlordNFT, gauntlets: SuiWarlordArmorGauntlets, ctx: &mut TxContext) {
        
        // Check if gauntlets is equipped, if so, remove them and send to user
        if (dof::exists_(&warlord.id, b"Gauntlets") == true) {
            gauntlets_remove(warlord, ctx);
        };
        warlord.strength = warlord.strength + sui_warlords::armorgauntlets::get_gauntlets_strength(&gauntlets);
        warlord.endurance = warlord.endurance + sui_warlords::armorgauntlets::get_gauntlets_endurance(&gauntlets);
        warlord.dexterity = warlord.dexterity + sui_warlords::armorgauntlets::get_gauntlets_dexterity(&gauntlets);
        warlord.agility = warlord.agility + sui_warlords::armorgauntlets::get_gauntlets_agility(&gauntlets);
        warlord.intelligence = warlord.intelligence + sui_warlords::armorgauntlets::get_gauntlets_intelligence(&gauntlets);
        warlord.wisdom = warlord.wisdom + sui_warlords::armorgauntlets::get_gauntlets_wisdom(&gauntlets);
        warlord.vitality = warlord.vitality + sui_warlords::armorgauntlets::get_gauntlets_vitality(&gauntlets);
        warlord.luck = warlord.luck + sui_warlords::armorgauntlets::get_gauntlets_luck(&gauntlets);
        
        dof::add(&mut warlord.id, b"Gauntlets", gauntlets);
    }

    public fun gauntlets_remove(warlord: &mut SuiWarlordNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let gauntlets: SuiWarlordArmorGauntlets = dof::remove(&mut warlord.id, b"Gauntlets");
        
        warlord.strength = warlord.strength - sui_warlords::armorgauntlets::get_gauntlets_strength(&gauntlets);
        warlord.endurance = warlord.endurance - sui_warlords::armorgauntlets::get_gauntlets_endurance(&gauntlets);
        warlord.dexterity = warlord.dexterity - sui_warlords::armorgauntlets::get_gauntlets_dexterity(&gauntlets);
        warlord.agility = warlord.agility - sui_warlords::armorgauntlets::get_gauntlets_agility(&gauntlets);
        warlord.intelligence = warlord.intelligence - sui_warlords::armorgauntlets::get_gauntlets_intelligence(&gauntlets);
        warlord.wisdom = warlord.wisdom - sui_warlords::armorgauntlets::get_gauntlets_wisdom(&gauntlets);
        warlord.vitality = warlord.vitality - sui_warlords::armorgauntlets::get_gauntlets_vitality(&gauntlets);
        warlord.luck = warlord.luck - sui_warlords::armorgauntlets::get_gauntlets_luck(&gauntlets);

        transfer::public_transfer(gauntlets, sender);
    }


    // Equip helmet on the warlord    
    public fun helmet_equip(warlord: &mut SuiWarlordNFT, helmet: SuiWarlordArmorHelmet, ctx: &mut TxContext) {
        
        // Check if helmet is equipped, if so, remove them and send to user
        if (dof::exists_(&warlord.id, b"Helmet") == true) {
            helmet_remove(warlord, ctx);
        };
        warlord.strength = warlord.strength + sui_warlords::armorhelmet::get_helmet_strength(&helmet);
        warlord.endurance = warlord.endurance + sui_warlords::armorhelmet::get_helmet_endurance(&helmet);
        warlord.dexterity = warlord.dexterity + sui_warlords::armorhelmet::get_helmet_dexterity(&helmet);
        warlord.agility = warlord.agility + sui_warlords::armorhelmet::get_helmet_agility(&helmet);
        warlord.intelligence = warlord.intelligence + sui_warlords::armorhelmet::get_helmet_intelligence(&helmet);
        warlord.wisdom = warlord.wisdom + sui_warlords::armorhelmet::get_helmet_wisdom(&helmet);
        warlord.vitality = warlord.vitality + sui_warlords::armorhelmet::get_helmet_vitality(&helmet);
        warlord.luck = warlord.luck + sui_warlords::armorhelmet::get_helmet_luck(&helmet);
        
        dof::add(&mut warlord.id, b"Helmet", helmet);
    }

    public fun helmet_remove(warlord: &mut SuiWarlordNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let helmet: SuiWarlordArmorHelmet = dof::remove(&mut warlord.id, b"Helmet");
        
        warlord.strength = warlord.strength - sui_warlords::armorhelmet::get_helmet_strength(&helmet);
        warlord.endurance = warlord.endurance - sui_warlords::armorhelmet::get_helmet_endurance(&helmet);
        warlord.dexterity = warlord.dexterity - sui_warlords::armorhelmet::get_helmet_dexterity(&helmet);
        warlord.agility = warlord.agility - sui_warlords::armorhelmet::get_helmet_agility(&helmet);
        warlord.intelligence = warlord.intelligence - sui_warlords::armorhelmet::get_helmet_intelligence(&helmet);
        warlord.wisdom = warlord.wisdom - sui_warlords::armorhelmet::get_helmet_wisdom(&helmet);
        warlord.vitality = warlord.vitality - sui_warlords::armorhelmet::get_helmet_vitality(&helmet);
        warlord.luck = warlord.luck - sui_warlords::armorhelmet::get_helmet_luck(&helmet);

        transfer::public_transfer(helmet, sender);
    }


    // Equip leggings on the warlord    
    public fun leggings_equip(warlord: &mut SuiWarlordNFT, leggings: SuiWarlordArmorLeggings, ctx: &mut TxContext) {
        
        // Check if leggings is equipped, if so, remove them and send to user
        if (dof::exists_(&warlord.id, b"Leggings") == true) {
            leggings_remove(warlord, ctx);
        };
        warlord.strength = warlord.strength + sui_warlords::armorleggings::get_leggings_strength(&leggings);
        warlord.endurance = warlord.endurance + sui_warlords::armorleggings::get_leggings_endurance(&leggings);
        warlord.dexterity = warlord.dexterity + sui_warlords::armorleggings::get_leggings_dexterity(&leggings);
        warlord.agility = warlord.agility + sui_warlords::armorleggings::get_leggings_agility(&leggings);
        warlord.intelligence = warlord.intelligence + sui_warlords::armorleggings::get_leggings_intelligence(&leggings);
        warlord.wisdom = warlord.wisdom + sui_warlords::armorleggings::get_leggings_wisdom(&leggings);
        warlord.vitality = warlord.vitality + sui_warlords::armorleggings::get_leggings_vitality(&leggings);
        warlord.luck = warlord.luck + sui_warlords::armorleggings::get_leggings_luck(&leggings);
        
        dof::add(&mut warlord.id, b"Leggings", leggings);
    }

    public fun leggings_remove(warlord: &mut SuiWarlordNFT, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let leggings: SuiWarlordArmorLeggings = dof::remove(&mut warlord.id, b"Leggings");
        
        warlord.strength = warlord.strength - sui_warlords::armorleggings::get_leggings_strength(&leggings);
        warlord.endurance = warlord.endurance - sui_warlords::armorleggings::get_leggings_endurance(&leggings);
        warlord.dexterity = warlord.dexterity - sui_warlords::armorleggings::get_leggings_dexterity(&leggings);
        warlord.agility = warlord.agility - sui_warlords::armorleggings::get_leggings_agility(&leggings);
        warlord.intelligence = warlord.intelligence - sui_warlords::armorleggings::get_leggings_intelligence(&leggings);
        warlord.wisdom = warlord.wisdom - sui_warlords::armorleggings::get_leggings_wisdom(&leggings);
        warlord.vitality = warlord.vitality - sui_warlords::armorleggings::get_leggings_vitality(&leggings);
        warlord.luck = warlord.luck - sui_warlords::armorleggings::get_leggings_luck(&leggings);

        transfer::public_transfer(leggings, sender);
    }


    // ===== Setters & Getters =====   

    // Get the Warlords Name
    public fun get_name(warlord: &SuiWarlordNFT): string::String {
        warlord.name
    }

    // Set the warlords name
    public fun set_name(warlord: &mut SuiWarlordNFT, new_name: vector<u8>) {
        warlord.name = string::utf8(new_name)
    }

    // Get the Warlords Description
    public fun get_description(warlord: &SuiWarlordNFT): string::String {
        warlord.description
    }

    // Set the warlords description
    public fun set_description(nft: &mut SuiWarlordNFT, new_description: vector<u8>) {
        nft.description = string::utf8(new_description)
    }

    // Get the Warlords class 
    public fun get_class(warlord: &SuiWarlordNFT): string::String {
        warlord.class
    }

    // set the Warlords class
    public (friend) fun set_class(warlord: &mut SuiWarlordNFT, newclass: String) {
        warlord.class = newclass                        
    }
       
    // Get the Warlords Level
    public fun get_level(warlord: &SuiWarlordNFT): u64 {
        warlord.level
    }
    
    // Get the Warlords Creation Time
    public fun get_createtime(warlord: &SuiWarlordNFT): u64 {
        warlord.createtime
    }

    // Get the Warlords Claimed BLOOD
    public fun get_claimedblood(warlord: &SuiWarlordNFT): u64 {
        warlord.claimedblood
    }

    // Get the Warlords Claimed TIME
    public fun get_claimedtime(warlord: &SuiWarlordNFT): u64 {
        warlord.claimedtime
    }    

    // Get the Warlords Strength
    public fun get_strength(warlord: &SuiWarlordNFT): u64 {
        warlord.strength
    }
 
    // Get the Warlords Endurance
    public fun get_endurance(warlord: &SuiWarlordNFT): u64 {
        warlord.endurance
    }

    // Get the Warlords Dexterity
    public fun get_dexterity(warlord: &SuiWarlordNFT): u64 {
        warlord.dexterity
    }

    // Get the Warlords Agility
    public fun get_agility(warlord: &SuiWarlordNFT): u64 {
        warlord.agility
    }

    // Get the Warlords Intelligence
    public fun get_intelligence(warlord: &SuiWarlordNFT): u64 {
        warlord.intelligence
    }

    // Get the Warlords Wisdom
    public fun get_wisdom(warlord: &SuiWarlordNFT): u64 {
        warlord.wisdom
    }

    // Get the Warlords Vitality
    public fun get_vitality(warlord: &SuiWarlordNFT): u64 {
        warlord.vitality
    }

    // Get the Warlords Luck
    public fun get_luck(warlord: &SuiWarlordNFT): u64 {
        warlord.luck
    }


    const MIN_STAT: u8 = 0;
    const MAX_STAT: u8 = 32;
    const INITIAL_LEVEL: u64 = 1;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const WARLORD_MINT_COST: u64 = 5000000000;
    const ZERO: u64 = 0;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;
       
    // Create a new Sui Warlords NFT. Name, description, URL, and SUI payment are required arguments
    // Must add logic for fixed URL once art is generated and layered in IPFS
    public fun warlord_mint(
        name: vector<u8>,
        description: vector<u8>,        
        mut payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        // Check users payment and throw error if too low
        assert!(value >= WARLORD_MINT_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, WARLORD_MINT_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);        
        
        // Warlord mint logic
        let nft = SuiWarlordNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            class: string::utf8(b"Recruit"),
            level: INITIAL_LEVEL,            
            createtime: sui::clock::timestamp_ms(clock),
            claimedblood: ZERO,
            claimedtime: ZERO,
            strength: rand::rng(MIN_STAT, MAX_STAT, ctx),
            endurance: rand::rng(MIN_STAT, MAX_STAT, ctx),
            dexterity: rand::rng(MIN_STAT, MAX_STAT, ctx),
            agility: rand::rng(MIN_STAT, MAX_STAT, ctx),
            intelligence: rand::rng(MIN_STAT, MAX_STAT, ctx),
            wisdom: rand::rng(MIN_STAT, MAX_STAT, ctx),
            vitality: rand::rng(MIN_STAT, MAX_STAT, ctx),
            luck: rand::rng(MIN_STAT, MAX_STAT, ctx),            
        };

        event::emit(SuiWarlordMinted {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
            description: nft.description,
            class: nft.class,
            level: nft.level,            
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
     public fun warlord_transfer(warlord: SuiWarlordNFT, recipient: address) {
        transfer::public_transfer(warlord, recipient)
    }


    // Permanently burn Warlord & reward 5 BLOOD & 5 TIME
    // Will want to add crafting essences here as well. Perhaps that's the better "reward"
    // May want to add a scaling function against level so higher heroes produce better output
    const BLOOD_FOR_BURN: u64 = 5;
    const TIME_FOR_BURN: u64 = 5;
    
    public fun warlord_burn(warlord: SuiWarlordNFT, accobj: &mut Account, ctx: &mut TxContext) {
        let recipient = tx_context::sender(ctx);
       
        let SuiWarlordNFT {id, name: _, description: _, class: _, level: _, createtime: _, claimedblood: _, claimedtime: _, strength: _, endurance: _, dexterity: _, agility: _, intelligence: _, wisdom: _, vitality: _, luck: _} = warlord;
        object::delete(id);      
        
        // Return BLOOD to sender
        let amount = BLOOD_FOR_BURN;              
        let bloodpayout: Coin<BLOOD> = sui_warlords::reservoir::withdraw(accobj, amount, ctx);
        transfer::public_transfer(bloodpayout, recipient);
        // Return TIME to sender
        let amount2 = TIME_FOR_BURN;
        let timepayout: Coin<TIME> = sui_warlords::reservoir::withdraw(accobj, amount2, ctx);
        transfer::public_transfer(timepayout, recipient);                
    }
    

    // Claim BLOOD & TIME. Warlord NFT should emit 1 BLOOD & 1 TIME per day
    // Change back to 3600000, for hourly testing as needed

    const DAY_IN_MS: u64 = 86400000;
    
    const ONE: u64 = 1;
    const E_INSUFFICIENT_CLAIM_WAIT_24_HOURS: u64 = 1;
        
    public fun warlord_claim_emission(warlord: &mut SuiWarlordNFT, accobj: &mut Account, clock: &Clock, ctx: &mut TxContext) {
        // Establish sender as recipient of payout
        // Establish current time in ms
        let recipient = tx_context::sender(ctx);  
        let currenttime = sui::clock::timestamp_ms(clock);
        
        // Calculate BLOOD payout based on current time vs claimed BLOOD
        let bloodamount = ((currenttime - warlord.createtime) / DAY_IN_MS ) - warlord.claimedblood;
        assert!(bloodamount > ONE, E_INSUFFICIENT_CLAIM_WAIT_24_HOURS);
        
        // Calculate TIME payout based on current time vs claimed TIME
        let timeamount = ((currenttime - warlord.createtime) / DAY_IN_MS) - warlord.claimedtime;
        assert!(timeamount > ONE, E_INSUFFICIENT_CLAIM_WAIT_24_HOURS);

        // Payout the BLOOD to user and increment the claimedblood counter
        let bloodpayout: Coin<BLOOD> = sui_warlords::reservoir::withdraw(accobj, bloodamount, ctx);
        transfer::public_transfer(bloodpayout, recipient);
        warlord.claimedblood = warlord.claimedblood + bloodamount;

        // Payout the TIME to user and increment the claimedtime counter
        let timepayout: Coin<TIME> = sui_warlords::reservoir::withdraw(accobj, timeamount, ctx);
        transfer::public_transfer(timepayout, recipient);
        warlord.claimedtime = warlord.claimedtime + timeamount;
    }


    // Level up section, costs 2 SUI, and 1 BLOOD 
    // Up to 8 additional BLOOD depending on desired bonus stats 
    // Allows up to 9 level ups for a max level of 10

    const BASECLASS_LVLUP_MIN: u8 = 0;
    const BASECLASS_LVLUP_MAX: u8 = 8;
    const BASECLASS_LEVEL_UP_COST_SUI: u64 = 2000000000;
    const BASECLASS_LEVEL_UP_COST_BLOOD: u64 = 1;
    const MAX_BASECLASS_BLOODBONUS: u64 = 8;
    
    const E_WARLORD_IS_MAX_LEVEL_TEN: u64 = 2;
    const E_TOO_MUCH_BLOOD_FOR_LEVEL_UP: u64 = 3;    
    
    public fun warlord_base_levelup_sui(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= BASECLASS_LEVEL_UP_COST_SUI, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= BASECLASS_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, BASECLASS_LEVEL_UP_COST_SUI, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 9, set to 9 which is max
        if (blood_quantity >= 9) {
            blood_quantity = 9;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at max roll per level up. Which is 8 for recruit
        let bloodbonus: u64 = (blood_quantity - BASECLASS_LEVEL_UP_COST_BLOOD) / BASECLASS_LEVEL_UP_COST_BLOOD;
        if (bloodbonus > MAX_BASECLASS_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is level 10 or above, otherwise allow level up
        if (warlord.level >= 10) {
            abort E_WARLORD_IS_MAX_LEVEL_TEN
        }
        else {     
            // Increment level then increase stats. Existing + bloodbonus (Max of 8) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));            
        }
    }

    // Level up section, costs 4 TIME, and 1-9 BLOOD depending on desired bonus stats. Allows up to 9 level ups for a max level of 10.
    const BASECLASS_LEVEL_UP_COST_TIME: u64 = 4;
        
    public fun warlord_base_levelup_time(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        // Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= BASECLASS_LEVEL_UP_COST_TIME, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= BASECLASS_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, BASECLASS_LEVEL_UP_COST_TIME, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 9, set to 9 which is max.
        if (blood_quantity >= 9) {
            blood_quantity = 9;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at max roll per level up. Which is 8 for recruit
        let bloodbonus: u64 = (blood_quantity - BASECLASS_LEVEL_UP_COST_BLOOD) / BASECLASS_LEVEL_UP_COST_BLOOD;
        if (bloodbonus > MAX_BASECLASS_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is level 10 or above, otherwise allow level up.
        if (warlord.level >= 10) {
            abort E_WARLORD_IS_MAX_LEVEL_TEN
        }
        else {     
            // Increment level then increase stats. Existing + bloodbonus (Max of 8) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));            
        }
    }


    const ADVANCED_LVLUP_MIN: u8 = 0;
    const ADVANCED_LVLUP_MAX: u8 = 16;
    const ADVANCED_LEVEL_UP_COST_SUI: u64 = 4000000000;
    const ADVANCED_LEVEL_UP_COST_BLOOD: u64 = 2;
    const MAX_ADVANCED_BLOODBONUS: u64 = 10;
    const ADVANCED_ATTRIBUTE_BONUS: u64 = 16;

    const E_WARLORD_IS_MAX_LEVEL_TWENTY: u64 = 6;
    const E_WARLORD_IS_MAX_LEVEL_THIRTY: u64 = 7;
    const E_WARLORD_IS_TOO_LOW_LEVEL: u64 = 8;

    // Advanced Level up section, costs 4 SUI, and 2 BLOOD 
    // Up to 10 additional BLOOD depending on desired bonus stats 
    // Allows up to 10 additional level ups for a max level of 20    
    public fun warlord_advanced_levelup_sui(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= ADVANCED_LEVEL_UP_COST_SUI, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ADVANCED_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ADVANCED_LEVEL_UP_COST_SUI, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 12, set to 12 which is max.
        if (blood_quantity >= 12) {
            blood_quantity = 12;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at 12 for advanced level up
        let bloodbonus: u64 = (blood_quantity - ADVANCED_LEVEL_UP_COST_BLOOD);
        if (bloodbonus > MAX_ADVANCED_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is under level 10, otherwise allow level up
        if (warlord.level < 10) {
            abort E_WARLORD_IS_TOO_LOW_LEVEL
        };

        // Abort if warlord is level 20 or above, otherwise allow level up
        if (warlord.level >= 20) {
            abort E_WARLORD_IS_MAX_LEVEL_TWENTY
        };

        if (warlord.class == string::utf8(b"Knight")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + ADVANCED_ATTRIBUTE_BONUS + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warrior")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Scout")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Wizard")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Priest")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + ADVANCED_ATTRIBUTE_BONUS + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };
    }

    const ADVANCED_LEVEL_UP_COST_TIME: u64 = 8;

    // Advanced Level up section, costs 8 TIME, and 2 BLOOD 
    // Up to 10 additional BLOOD depending on desired bonus stats 
    // Allows up to 10 additional level ups for a max level of 20    
    public fun warlord_advanced_levelup_time(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= ADVANCED_LEVEL_UP_COST_TIME, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= ADVANCED_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, ADVANCED_LEVEL_UP_COST_TIME, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 12, set to 12 which is max.
        if (blood_quantity >= 12) {
            blood_quantity = 12;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at 12 for advanced level up
        let bloodbonus: u64 = (blood_quantity - ADVANCED_LEVEL_UP_COST_BLOOD);
        if (bloodbonus > MAX_ADVANCED_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is under level 10, otherwise allow level up
        if (warlord.level < 10) {
            abort E_WARLORD_IS_TOO_LOW_LEVEL
        };

        // Abort if warlord is level 20 or above, otherwise allow level up
        if (warlord.level >= 20) {
            abort E_WARLORD_IS_MAX_LEVEL_TWENTY
        };

        if (warlord.class == string::utf8(b"Knight")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + ADVANCED_ATTRIBUTE_BONUS + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warrior")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Scout")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Wizard")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Priest")) {     
            // Increment level then increase stats. Existing + advanced attribute bonus (16) + bloodbonus (Max of 10) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + ADVANCED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + ADVANCED_ATTRIBUTE_BONUS + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(ADVANCED_LVLUP_MIN, ADVANCED_LVLUP_MAX, ctx));            
        };
    }


    const SPECIALIZED_LVLUP_MIN: u8 = 0;
    const SPECIALIZED_LVLUP_MAX: u8 = 32;
    const SPECIALIZED_LEVEL_UP_COST_SUI: u64 = 6000000000;
    const SPECIALIZED_LEVEL_UP_COST_BLOOD: u64 = 3;
    const MAX_SPECIALIZED_BLOODBONUS: u64 = 12;
    const SPECIALIZED_ATTRIBUTE_BONUS: u64 = 24;

    // Specialized Level up section, costs 6 SUI, and 3 BLOOD 
    // Up to 12 additional BLOOD depending on desired bonus stats 
    // Allows up to 10 additional level ups for a max level of 30    
    public fun warlord_specialized_levelup_sui(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough SUI or BLOOD
        assert!(value >= SPECIALIZED_LEVEL_UP_COST_SUI, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= SPECIALIZED_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, SPECIALIZED_LEVEL_UP_COST_SUI, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 15, set to 15 which is max.
        if (blood_quantity >= 15) {
            blood_quantity = 15;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at 15 for specialized level up
        let bloodbonus: u64 = (blood_quantity - SPECIALIZED_LEVEL_UP_COST_BLOOD);
        if (bloodbonus > MAX_SPECIALIZED_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is under level 20, otherwise allow level up
        if (warlord.level < 20) {
            abort E_WARLORD_IS_TOO_LOW_LEVEL
        };

        // Abort if warlord is level 30 or above, otherwise allow level up
        if (warlord.level >= 30) {
            abort E_WARLORD_IS_MAX_LEVEL_THIRTY
        };

        // Tank specialized classes END & VIT

        if (warlord.class == string::utf8(b"Paladin")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warlord")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"General")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Melee DPS specialized classes STR & DEX

        if (warlord.class == string::utf8(b"Monk")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Berserker")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Samurai")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Nimble specialized classes AGI & DEX

        if (warlord.class == string::utf8(b"Ninja")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Ranger")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus +  (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Dragoon")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Magic DPS specialized classes INT & WIS

        if (warlord.class == string::utf8(b"Sorcerer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warlock")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Pyromancer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Magic Support specialized classes WIS & INT

        if (warlord.class == string::utf8(b"Cleric")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Druid")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Geomancer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };
    }

    const SPECIALIZED_LEVEL_UP_COST_TIME: u64 = 12;

    // Specialized Level up section, costs 12 TIME, and 3 BLOOD 
    // Up to 12 additional BLOOD depending on desired bonus stats 
    // Allows up to 10 additional level ups for a max level of 30    
    public fun warlord_specialized_levelup_time(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<sui_warlords::time::TIME>,
        mut payment2: Coin<sui_warlords::blood::BLOOD>,
        mut blood_quantity: u64,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let value2 = coin::value(&payment2);
        
        //Check users balance and throw error if not enough TIME or BLOOD
        assert!(value >= SPECIALIZED_LEVEL_UP_COST_TIME, E_INSUFFICIENT_PAYMENT);
        assert!(value2 >= SPECIALIZED_LEVEL_UP_COST_BLOOD, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, SPECIALIZED_LEVEL_UP_COST_TIME, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the SUI remainder back to the user/sender
        transfer::public_transfer(payment, sender);
        
        // Check BLOOD sent, if over 15, set to 15 which is max.
        if (blood_quantity >= 15) {
            blood_quantity = 15;        
        };
        
        // Transfer BLOOD to admin, and return remainder to sender
        pay::split_and_transfer(&mut payment2, blood_quantity, ADMIN_PAYOUT_ADDRESS, ctx);
        transfer::public_transfer(payment2, sender);
        
        // Calculate the bloodbonus based on blood_quantity. Capped at 15 for specialized level up
        let bloodbonus: u64 = (blood_quantity - SPECIALIZED_LEVEL_UP_COST_BLOOD);
        if (bloodbonus > MAX_SPECIALIZED_BLOODBONUS) {
            abort E_TOO_MUCH_BLOOD_FOR_LEVEL_UP
        };

        // Abort if warlord is under level 20, otherwise allow level up
        if (warlord.level < 20) {
            abort E_WARLORD_IS_TOO_LOW_LEVEL
        };

        // Abort if warlord is level 30 or above, otherwise allow level up
        if (warlord.level >= 30) {
            abort E_WARLORD_IS_MAX_LEVEL_THIRTY
        };

        // Tank specialized classes END & VIT

        if (warlord.class == string::utf8(b"Paladin")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warlord")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"General")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + SPECIALIZED_ATTRIBUTE_BONUS + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Melee DPS specialized classes STR & DEX

        if (warlord.class == string::utf8(b"Monk")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Berserker")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Samurai")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Nimble specialized classes AGI & DEX

        if (warlord.class == string::utf8(b"Ninja")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Ranger")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus +  (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Dragoon")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Magic DPS specialized classes INT & WIS

        if (warlord.class == string::utf8(b"Sorcerer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Warlock")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Pyromancer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        // Magic Support specialized classes WIS & INT

        if (warlord.class == string::utf8(b"Cleric")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Druid")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };

        if (warlord.class == string::utf8(b"Geomancer")) {     
            // Increment level then increase stats. Existing + specialized attribute bonus (24) + bloodbonus (Max of 12) + RNG
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + SPECIALIZED_ATTRIBUTE_BONUS + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + bloodbonus + (rand::rng(SPECIALIZED_LVLUP_MIN, SPECIALIZED_LVLUP_MAX, ctx));            
        };
    }
}