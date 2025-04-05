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
        let is_token_a = coin::is_same_type(&*from_token, &pool.token_a);

        let reserve_in: &mut u64;
        let reserve_out: &mut u64;

        if (is_token_a) {
            reserve_in = &mut pool.reserve_a;
            reserve_out = &mut pool.reserve_b;
        } else {
            reserve_in = &mut pool.reserve_b;
            reserve_out = &mut pool.reserve_a;
        };


        let amount_out = (amount_in * *reserve_out) / (*reserve_in + amount_in);
        *reserve_in = *reserve_in + amount_in;
        *reserve_out = *reserve_out - amount_out;
       
        amount_out
    }

    public fun add_liquidity(
      pool: &mut Pool,
      amount_a: u64,
      amount_b: u64
    ) {
    assert!(amount_a > 0 && amount_b > 0, 0);
      pool.reserve_a = pool.reserve_a + amount_a;
      pool.reserve_b = pool.reserve_b + amount_b;
    }

    public fun remove_liquidity(
      pool: &mut Pool,
      liquidity: u64
    ): (u64, u64) {
      let amount_a = (pool.reserve_a * liquidity) / 100;
      let amount_b = (pool.reserve_b * liquidity) / 100;
      pool.reserve_a = pool.reserve_a - amount_a;
      pool.reserve_b = pool.reserve_b - amount_b;
      (amount_a, amount_b)
    }

}

