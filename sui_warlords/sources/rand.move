module sui_warlords::rand {
    use std::hash;
    use std::vector;
    use sui::bcs;
    use sui::object;
    use sui::tx_context::{Self, TxContext};
    
    const EBAD_RANGE: u64 = 0;
    const ETOO_FEW_BYTES: u64 = 1;    

    // RNG function 
    // min must be zero and max must be a power of 2, adds 1 to resultant distribution to avoid returns of 0
    public fun rng(min: u8, max: u8, ctx: &mut TxContext): u64 {
        assert!(max > min, EBAD_RANGE);

        // Secure a random byte
        let rand_byte = u8_from_seed(seed(ctx));
        
        // Remap the random byte onto the specified range
        let mapped_byte = (rand_byte % max) + min;
        let passed_byte: u64 = ((mapped_byte + 1) as u64);
        passed_byte
    }    

    // Evenly distributed rng_u8 for 5 items
    public fun rng_u8_of_5(min: u8, max: u8, ctx: &mut TxContext): u8 {
    assert!(max > min, EBAD_RANGE);

    // Secure a random byte
    let rand_byte = u8_from_seed(seed(ctx));

    // Remap the random byte onto the specified range
    let mapped_byte = (rand_byte % (max - min + 1)) + min;

    mapped_byte
    }

    public fun u8_from_seed(seed: vector<u8>): u8 {
        assert!(vector::length(&seed) >= 8, ETOO_FEW_BYTES);
        bcs::peel_u8(&mut bcs::new(seed))
    } 
    
    // generates seed using the tx context (epoch, sender and a newly created uid)
    public fun seed(ctx: &mut TxContext): vector<u8> {
        let raw_seed = raw_seed(ctx);
        hash::sha3_256(raw_seed)
    }

    public fun raw_seed(ctx: &mut TxContext): vector<u8> {
        let sender = tx_context::sender(ctx);
        let sender_bytes = bcs::to_bytes(&sender);

        let epoch = tx_context::epoch(ctx);
        let epoch_bytes = bcs::to_bytes(&epoch);

        let id = object::new(ctx);
        let id_bytes = object::uid_to_bytes(&id);
        object::delete(id);

        let mut raw_seed = vector::empty<u8>();
        vector::append(&mut raw_seed, id_bytes);
        vector::append(&mut raw_seed, epoch_bytes);
        vector::append(&mut raw_seed, sender_bytes);

        raw_seed
    }
}