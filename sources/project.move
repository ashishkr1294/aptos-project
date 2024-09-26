module MyModule::SimpleAuction {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an auction.
    struct Auction has store, key {
        highest_bid: u64,       // The highest bid in the auction
        highest_bidder: address, // The address of the highest bidder
        seller: address,        // The seller of the item
    }

    /// Function to create an auction.
    public fun create_auction(seller: &signer, starting_bid: u64) {
        let auction = Auction {
            highest_bid: starting_bid,
            highest_bidder: signer::address_of(seller),
            seller: signer::address_of(seller),
        };
        move_to(seller, auction);
    }

    /// Function to place a bid in the auction.
    public fun place_bid(bidder: &signer, seller_address: address, bid_amount: u64) acquires Auction {
        let auction = borrow_global_mut<Auction>(seller_address);

        // Ensure the bid is higher than the current highest bid
        assert!(bid_amount > auction.highest_bid, 1);

        // Refund the previous highest bidder (if not the seller)
        if (auction.highest_bidder != auction.seller) {
            let refund = coin::withdraw<AptosCoin>(bidder, auction.highest_bid);
            coin::deposit<AptosCoin>(auction.highest_bidder, refund);
        };

        // Update the auction with the new highest bid and bidder
        let new_bid = coin::withdraw<AptosCoin>(bidder, bid_amount);
        coin::deposit<AptosCoin>(seller_address, new_bid);

        auction.highest_bid = bid_amount;
        auction.highest_bidder = signer::address_of(bidder);
    }
}
