module amm::LiquidityPool {
    use std::signer;
    use std::vector;
    use std::string;
    use std::coin;
    use sui::transfer;

    struct Pool has key, store {
        token_a: coin::Coin,
        token_b: coin::Coin,
        reserve_a: u64,
        reserve_b: u64,
    }

    public fun create_pool(
        owner: &signer,
        token_a: coin::Coin,
        token_b: coin::Coin,
        amount_a: u64,
        amount_b: u64
    ): Pool {
        assert!(amount_a > 0 && amount_b > 0, 0);
        
        Pool {
            token_a,
            token_b,
            reserve_a: amount_a,
            reserve_b: amount_b,
        }
    }

    public fun swap(
        pool: &mut Pool,
        from_token: &mut coin::Coin,
        amount_in: u64
    ): u64 {
        let reserve_in = if coin::type_of(from_token) == coin::type_of(pool.token_a) {
            &mut pool.reserve_a
        } else {
            &mut pool.reserve_b
        };

        let reserve_out = if coin::type_of(from_token) == coin::type_of(pool.token_a) {
            &mut pool.reserve_b
        } else {
            &mut pool.reserve_a
        };

        let amount_out = (amount_in * *reserve_out) / (*reserve_in + amount_in);
        *reserve_in += amount_in;
        *reserve_out -= amount_out;

        amount_out
    }

    public fun add_liquidity(
        pool: &mut Pool,
        amount_a: u64,
        amount_b: u64
    ) {
        assert!(amount_a > 0 && amount_b > 0, 0);
        pool.reserve_a += amount_a;
        pool.reserve_b += amount_b;
    }

    public fun remove_liquidity(
        pool: &mut Pool,
        liquidity: u64
    ): (u64, u64) {
        let amount_a = (pool.reserve_a * liquidity) / 100;
        let amount_b = (pool.reserve_b * liquidity) / 100;
        pool.reserve_a -= amount_a;
        pool.reserve_b -= amount_b;

        (amount_a, amount_b)
    }
}

