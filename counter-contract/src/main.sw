// Every Sway file must start with a declaration 
// of what type of program the file contains; 
// here, we've declared that this file is a contract.
contract;

// Next, we'll define a storage value. In our case, 
// we have a single counter that we'll call counter 
// of type 64-bit unsigned integer and initialize it to 0.
storage {
    counter: u64 = 0,
}

// An ABI defines an interface, and there is no function body in the ABI. 
//A contract must either define or import an ABI declaration and implement it. 
//It is considered best practice to define your ABI in a separate library and 
//import it into your contract because this allows callers of the contract to 
//import and use the ABI in scripts to call your contract.
abi Counter {
    #[storage(write)]
    fn init(value: u64) -> u64;
    // #[storage(read, write)] is an annotation which denotes that this function 
    // has permission to read and write values in storage.
    #[storage(read, write)]
    // We're introducing the functionality to increment and denoting it shouldn't return any value.
    fn increment(amount: u64) -> u64;

    // #[storage(read)] is an annotation which denotes that this function 
    // has permission to read values in storage.
    #[storage(read)]
    // We're introducing the functionality to increment the counter and denoting the function's return value.
    fn count() -> u64;
}

impl Counter for Contract {
    #[storage(read)]
    fn count() -> u64 {
        return storage.counter
    }

    #[storage(read, write)]
    fn increment(amount: u64) -> u64 {
        let incremented = storage.counter + amount;
        storage.counter = incremented;
        incremented
    }
    #[storage(write)]
    fn init(value: u64) -> u64 {
        storage.counter = value;
        value
    }
}
