#[lint_allow(self_transfer)]
// https://docs.sui.io/concepts/dynamic-fields/transfers/transfer-to-object#custom-receiving-rules

module sui_warlords::reservoir {
    use sui::transfer::{Self, Receiving};
    use sui::coin::{Self, Coin};
    use sui::object;
    use sui::dynamic_field as df;
    use sui::tx_context::TxContext;
    use sui::sui::SUI;
    use sui::pay;

    use sui_warlords::blood::{BLOOD};
    use sui_warlords::time::{TIME};

    friend sui_warlords::warlord;
    friend sui_warlords::armorchest;
    friend sui_warlords::armorleggings;
    friend sui_warlords::armorhelmet;
    friend sui_warlords::armorgauntlets;
    friend sui_warlords::armorboots;
    
    const EBalanceDONE: u64 = 1;

    /// Account object that `Coin`s can be sent to. Balances of different types
    /// are held as dynamic fields indexed by the `Coin` type's `type_name`.
    public struct Account has key {
        id: object::UID,
    }
    
    /// Dynamic field key representing a balance of a particular coin type.
    public struct AccountBalance<phantom T> has copy, drop, store { }

    fun init(ctx: &mut TxContext) {
        // Share the newly created Account object
        transfer::share_object(Account {
            id: object::new(ctx), 
        })        
    }

    /// This function will receive a coin sent to the `Account` object and then
    /// join it to the balance for each coin type.
    /// Dynamic fields are used to index the balances by their coin type.
    public fun accept_payment<T>(account: &mut Account, sent: Receiving<Coin<T>>) {
        // Receive the coin that was sent to the `account` object
        // Since `Coin` is not defined in this module, and since it has the `store`
        // ability we receive the coin object using the `transfer::public_receive` function.
        let coin = transfer::public_receive(&mut account.id, sent);
        let account_balance_type = AccountBalance<T>{};
        let account_uid = &mut account.id;

        // Check if a balance of that coin type already exists.
        // If it does then merge the coin we just received into it,
        // otherwise create new balance.
        if (df::exists_(account_uid, account_balance_type)) {
            let balance: &mut Coin<T> = df::borrow_mut(account_uid, account_balance_type);
            coin::join(balance, coin);
        } else {
            df::add(account_uid, account_balance_type, coin);
        }
    }

    /// Withdraw `amount` of coins of type `T` from `account`.
    public (friend) fun withdraw<T>(account: &mut Account, amount: u64, ctx: &mut TxContext): Coin<T> {
        let account_balance_type = AccountBalance<T>{};
        let account_uid = &mut account.id;
        // Make sure what we are withdrawing exists
        assert!(df::exists_(account_uid, account_balance_type), EBalanceDONE);
        let balance: &mut Coin<T> = df::borrow_mut(account_uid, account_balance_type);
        coin::split(balance, amount, ctx)
    }


    const TEN_TOKEN_COST_IN_SUI: u64 = 5000000000;
    const TEN_TOKEN: u64 = 10;
    const ADMIN_PAYOUT_ADDRESS: address = @adminpayout;

    const E_INSUFFICIENT_PAYMENT: u64 = 0;

    // Buy TIME and BLOOD from shop
    public fun buy_ten_tokens(accobj: &mut Account, mut payment: Coin<SUI>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let timeamount = TEN_TOKEN;
        let bloodamount = TEN_TOKEN;        
        
        // Check users balance and throw error if not enough SUI
        assert!(value >= TEN_TOKEN_COST_IN_SUI, E_INSUFFICIENT_PAYMENT);        
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, TEN_TOKEN_COST_IN_SUI, ADMIN_PAYOUT_ADDRESS, ctx);

        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);  

        let timepayout: Coin<TIME> = sui_warlords::reservoir::withdraw(accobj, timeamount, ctx);
        transfer::public_transfer(timepayout, sender);

        let bloodpayout: Coin<BLOOD> = sui_warlords::reservoir::withdraw(accobj, bloodamount, ctx);
        transfer::public_transfer(bloodpayout, sender);
    }


    const HUNDRED_TOKEN_COST_IN_SUI: u64 = 50000000000;
    const HUNDRED_TOKEN: u64 = 100;    

    // Buy TIME and BLOOD from shop
    public fun buy_hundred_tokens(accobj: &mut Account, mut payment: Coin<SUI>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let value = coin::value(&payment);
        let timeamount = HUNDRED_TOKEN;
        let bloodamount = HUNDRED_TOKEN;        
        
        // Check users balance and throw error if not enough SUI
        assert!(value >= HUNDRED_TOKEN_COST_IN_SUI, E_INSUFFICIENT_PAYMENT);        
        
        // Split and send the mint cost to admin address        
        pay::split_and_transfer(&mut payment, HUNDRED_TOKEN_COST_IN_SUI, ADMIN_PAYOUT_ADDRESS, ctx);

        // Transfer the remainder back to the user/sender
        transfer::public_transfer(payment, sender);  

        let timepayout: Coin<TIME> = sui_warlords::reservoir::withdraw(accobj, timeamount, ctx);
        transfer::public_transfer(timepayout, sender);

        let bloodpayout: Coin<BLOOD> = sui_warlords::reservoir::withdraw(accobj, bloodamount, ctx);
        transfer::public_transfer(bloodpayout, sender);
    }        
}