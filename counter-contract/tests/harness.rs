use fuels::{prelude::*, tx::ContractId};

// Load abi from json
abigen!(Counter, "out/debug/counter-contract-abi.json");

async fn get_contract_instance() -> (Counter, ContractId) {
    // Launch a local network and deploy the contract
    let mut wallets = launch_custom_provider_and_get_wallets(
        WalletsConfig::new(
            Some(1),             /* Single wallet */
            Some(1),             /* Single coin (UTXO) */
            Some(1_000_000_000), /* Amount per coin */
        ),
        None,
        None,
    )
    .await;
    let wallet = wallets.pop().unwrap();

    let id = Contract::deploy(
        "./out/debug/counter-contract.bin",
        &wallet,
        TxParameters::default(),
        StorageConfiguration::with_storage_path(Some(
            "./out/debug/counter-contract-storage_slots.json".to_string(),
        )),
    )
    .await
    .unwrap();

    let instance = Counter::new(id.clone(), wallet);

    (instance, id.into())
}

#[tokio::test]
async fn initialize_and_increment() {
    let (instance, _id) = get_contract_instance().await;
    let init_result = instance.methods().init(1).call().await.unwrap();
    println!("0️⃣ Init result: {}",init_result.value);
    let increment_result = instance.methods().increment(1).call().await.unwrap();
    println!("1️⃣ Increment result: {}",increment_result.value);
    let result = instance.methods().count().call().await.unwrap();
    println!("✅ Count: {}",result.value);
    assert_eq!(result.value, 2);
}