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
    // Supra RNG Logic
    use sui_warlords::supra_contract::{Self, DkgState, Config};
    use sui::vec_map::{Self, VecMap};
    
    // Hero NFT, mintable for 5 SUI
    public struct SuiWarlordNFT has key, store {
        id: UID,
        // Name for the Hero
        name: string::String,
        // Description of the Hero
        description: string::String,
        // Class of the Warlord
        class: u64,
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

    public struct SuiWarlordMinted has copy, drop {
        // The Object ID of the Warlord
        object_id: ID,
        // The creator of the warlord
        creator: address,
        // The name of the Warlord (User defined)
        name: string::String,
        // The description of the Warlord (User defined)
        description: string::String,
        // Class of the Warlord
        class: u64,
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

    // Get the Heroes `Name`
    public fun name(nft: &SuiWarlordNFT): &string::String {
        &nft.name
    }

    // Get the Heroes `Description`
    public fun description(nft: &SuiWarlordNFT): &string::String {
        &nft.description
    }

    // Get the Heroes `Class'. Numerically encoded because strings suck.
    public fun class(nft: &SuiWarlordNFT): u64 {
        nft.class
    }

    // Get the Heroes `Level'. Starts at 1, max at 10, then class mutation.
    public fun level(nft: &SuiWarlordNFT): u64 {
        nft.level
    }

    // Get the Heroes `Url`
    //public fun url(nft: &SuiWarlordNFT): Url {
    //   nft.url()
    //}

    // Get the Heroes `Strength'
    public fun strength(nft: &SuiWarlordNFT): u64 {
        nft.strength
    }
 
    // Get the Heroes `Endurance'
    public fun endurance(nft: &SuiWarlordNFT): u64 {
        nft.endurance
    }

    // Get the Heroes `Dexterity'
    public fun dexterity(nft: &SuiWarlordNFT): u64 {
        nft.dexterity
    }

    // Get the Heroes `Agility'
    public fun agility(nft: &SuiWarlordNFT): u64 {
        nft.agility
    }

    // Get the Heroes `Intelligence'
    public fun intelligence(nft: &SuiWarlordNFT): u64 {
        nft.intelligence
    }

    // Get the Heroes `Wisdom'
    public fun wisdom(nft: &SuiWarlordNFT): u64 {
        nft.wisdom
    }

    // Get the Heroes `Vitality'
    public fun vitality(nft: &SuiWarlordNFT): u64 {
        nft.vitality
    }

    // Get the Heroes `Luck'
    public fun luck(nft: &SuiWarlordNFT): u64 {
        nft.luck
    }
      
    const MIN_STAT: u64 = 1;
    const MAX_STAT: u64 = 32;
    const INITIAL_LEVEL: u64 = 1;
    const MIN_CLASS: u64 = 1;
    const MAX_CLASS: u64 = 8;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;
    const WARLORD_MINT_COST: u64 = 5000000000;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;
    
    // ===== Entrypoints =====   

    
    // Create a new Sui Warlords NFT. Name, description, URL, and address for payment are required arguments
    public entry fun mint_warlord_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        mut payment: Coin<SUI>,
        ctx: &mut TxContext
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
            class: rand::rng(MIN_CLASS, MAX_CLASS, ctx),
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

    // Transfer 'Warlord NFT' to `recipient`
     public fun warlord_transfer(nft: SuiWarlordNFT, recipient: address) {
        transfer::public_transfer(nft, recipient)
    }

    // Update the `description` of `Warlord` to `new_description`
    public fun warlord_update_description(nft: &mut SuiWarlordNFT, new_description: vector<u8>, _: &mut TxContext) {
        nft.description = string::utf8(new_description)
    }

    // Permanently delete `Warlord`
    public fun warlord_burn(nft: SuiWarlordNFT, _: &mut TxContext) {
        let SuiWarlordNFT { id, name: _, description: _, class: _, level: _, url: _, strength: _, endurance: _, dexterity: _, agility: _, intelligence: _, wisdom: _, vitality: _, luck: _} = nft;
        object::delete(id)
    }

    const BASECLASS_LVLUP_MIN: u64 = 1;
    const BASECLASS_LVLUP_MAX: u64 = 8;
    const WARLORD_LEVEL_UP_COST: u64 = 2000000000;
    const WARLORD_IS_MAX_LEVEL: u64 = 10;
    
    public entry fun level_up_warlord(
        warlord: &mut SuiWarlordNFT,
        mut payment: Coin<SUI>,
        ctx: &mut TxContext,
        ) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        
        //Check users balance and throw error if too low
        assert!(value >= WARLORD_LEVEL_UP_COST, E_INSUFFICIENT_PAYMENT);
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, WARLORD_LEVEL_UP_COST, ADMIN_PAYOUT_ADDRESS, ctx);
        
        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);

        // Abort if warlord is level 10, otherwise allow level up.
        if (warlord.level == 10) {
            abort WARLORD_IS_MAX_LEVEL
        }
        else {     
            warlord.level = warlord.level + 1;
            warlord.strength = warlord.strength + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.endurance = warlord.endurance + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.dexterity = warlord.dexterity + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.agility = warlord.agility + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.intelligence = warlord.intelligence + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.wisdom = warlord.wisdom + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.vitality = warlord.vitality + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));
            warlord.luck = warlord.luck + (rand::rng(BASECLASS_LVLUP_MIN, BASECLASS_LVLUP_MAX, ctx));            
        }       
    }

    // Supra VRF drop in code below
    // Make struct public
    // Supra module can't be capital, otherwise it shows up as variable, not module

    public struct RandomNumberList has key {
        id: UID,
        random_numbers: VecMap<u64, vector<u64>>
    }

    fun init(ctx: &mut TxContext) {
        let random_numbers: RandomNumberList = RandomNumberList {
            id: object::new(ctx),
            random_numbers: vec_map::empty(),
        };
        transfer::share_object(random_numbers);
    }

    public entry fun rng_request(random_number_list: &mut RandomNumberList, client_address: address, supra_config: &mut Config, rng_count: u8, client_seed: u64, ctx: &mut TxContext) {
        let callback_fn: String = string::utf8(b"ExampleContract::distribute");
        let num_confirmations: u64 = 1;
        let client_obj_addr: address = object::uid_to_address(&random_number_list.id);
        supra_contract::rng_request(supra_config, client_address, callback_fn, rng_count, client_seed, num_confirmations, client_obj_addr, ctx);
    }

    public entry fun distribute(
        random_number_list: &mut RandomNumberList,
        dkg_state: &mut DkgState,
        nonce: u64,
        message: vector<u8>,
        signature: vector<u8>,
        rng_count: u8,
        client_seed: u64,
        ctx: &mut TxContext
    ) {
        let verified_num: vector<u64> = supra_contract::verify_callback(dkg_state, nonce, message, signature, rng_count, client_seed, ctx);

        if(!vec_map::contains(&random_number_list.random_numbers, &nonce)) {
            vec_map::insert(&mut random_number_list.random_numbers, nonce, verified_num);
        }
    }
}









