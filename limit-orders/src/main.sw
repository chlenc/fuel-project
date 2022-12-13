contract;
use std::{
    auth::{AuthError, msg_sender},
    call_frames::{msg_asset_id},
    block::{timestamp},
    context::msg_amount,
    storage::StorageMap,
    tx::{tx_id},
};

enum Status {
    ACTIVE: (),
    // COMPLETED: (),
    // CANCELED: (),
}

pub struct Order {
    asset0: ContractId,
    amount0: u64,
    asset1: ContractId,
    amount1: u64,
    fulfilled0: u64,
    fulfilled1: u64,
    owner: Address,
    status: Status,
    timestamp: u64,
    id: b256,
}

storage {
    global_orders_amount: u64 = 0,
    orders: StorageMap<u64, Order> = StorageMap {},
}

abi LimitOrders {
    #[storage(write, read)]
    fn create_order(asset1: ContractId, amount1: u64) -> u64;

    #[storage(read)]
    fn orders() -> StorageMap<u64, Order>;
}

impl LimitOrders for Contract {
    #[storage(read, write)]
    fn create_order(asset1: ContractId, amount1: u64) -> u64 {
        let asset0 = msg_asset_id();
        let amount0 = msg_amount();
        let new_order_id = storage.global_orders_amount + 1;

        assert(amount0 > 0); // TODO: throw
        storage.global_orders_amount = new_order_id;
        let owner: Result<Identity, AuthError> = msg_sender();
        let owner: Address = match owner.unwrap() {
            Identity::Address(addr) => addr,
            _ => revert(0),
        };

        storage.orders.insert(new_order_id, Order {
            asset0,
            amount0,
            asset1,
            amount1,
            fulfilled0: 0,
            fulfilled1: 0,
            owner: owner,
            status: Status::ACTIVE(),
            timestamp: timestamp(),
            id: tx_id(),
        });

        new_order_id
    }

    #[storage(read)]
    fn orders() -> StorageMap<u64, Order> {
        storage.orders
    }
}
