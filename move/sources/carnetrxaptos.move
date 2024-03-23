module carnet_rx_prescription::main {
    use aptos_framework::account;
    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_framework::randomness;
    use aptos_std::string_utils::{to_string};
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use std::option;
    use std::string::{String, utf8};

    /// Error codes
    const EPRESCRIPTION_NOT_EXIST: u64 = 1;
    const EINVALID_PRESCRIPTION: u64 = 2;

    /// Object seed
    const APP_OBJECT_SEED: vector<u8> = b"CARNET_RX_PRESCRIPTION";

    /// Collection details
    const CARNET_RX_COLLECTION_NAME: vector<u8> = b"CarnetRxPrescriptions";
    const CARNET_RX_COLLECTION_DESCRIPTION: vector<u8> = b"CarnetRxPrescriptions Collection Description";
    const CARNET_RX_COLLECTION_URI: vector<u8> = b"http://carnet.network";

    // Define struct for CarnetRxPrescription descriptors
    struct CarnetRxPrescription has copy, drop, key, store {
        patientname: String,
        patientage: u8,
        diagnosis: String,
        date_of_visit: u64,
        medicine_prescribed: String,
        medicine_chemical_name: String,
        prescription_id: String,
    }

    // Commented out Randomness Commitment Extension and Mint CarnetRxPrescription Events

    // struct RandomnessCommitmentExt has key {
    //     revealed: bool,
    //     value: u8,
    // }

    // struct MintCarnetRxPrescriptionEvents has key {
    //     mint_carnet_rx_prescription_events: event::EventHandle<MintCarnetRxPrescriptionEvent>,
    // }

    // struct MintCarnetRxPrescriptionEvent has drop, store {
    //     prescription_id: String,
    //     prescription_details: CarnetRxPrescription,
    // }

    // Struct for the collection capability
    struct CollectionCapability has key {
        extend_ref: ExtendRef,
    }

    // Module initialization
    fun init_module(account: &signer) {
        let constructor_ref = object::create_named_object(account, APP_OBJECT_SEED);
        let extend_ref = object::generate_extend_ref(&constructor_ref);
        let app_signer = &object::generate_signer(&constructor_ref);

        move_to(account, MintCarnetRxPrescriptionEvents {
            mint_carnet_rx_prescription_events: account::new_event_handle<MintCarnetRxPrescriptionEvent>(account),
        });

        move_to(app_signer, CollectionCapability {
            extend_ref,
        });

        create_carnet_rx_prescription_collection(app_signer);
    }

    // Function to create the CarnetRxPrescription collection
    fun create_carnet_rx_prescription_collection(creator: &signer) {
        let description = utf8(CARNET_RX_COLLECTION_DESCRIPTION);
        let name = utf8(CARNET_RX_COLLECTION_NAME);
        let uri = utf8(CARNET_RX_COLLECTION_URI);

        collection::create_unlimited_collection(
            creator,
            description,
            name,
            option::none(),
            uri,
        );
    }

    // Function to create a CarnetRxPrescription
    entry fun create_carnet_rx_prescription(
        user: &signer,
        patientname: String,
        patientage: u8,
        diagnosis: String,
        date_of_visit: u64,
        medicine_prescribed: String,
        medicine_chemical_name: String,
    ) acquires CollectionCapability, MintCarnetRxPrescriptionEvents {
        let prescription_id = generate_prescription_id();
        create_carnet_rx_prescription_internal(
            user,
            patientname,
            patientage,
            diagnosis,
            date_of_visit,
            medicine_prescribed,
            medicine_chemical_name,
            prescription_id,
        );
    }

    // Function to generate a random 16-digit alphanumeric prescription ID
    fun generate_prescription_id(): String {
        // Call the Aptos Roll API here to generate the unique ID
        // For demonstration purposes, generating a random string
        let random_string = randomness::random_string(16);
        random_string
    }

    // Function to create a CarnetRxPrescription internally
    fun create_carnet_rx_prescription_internal(
        user: &signer,
        patientname: String,
        patientage: u8,
        diagnosis: String,
        date_of_visit: u64,
        medicine_prescribed: String,
        medicine_chemical_name: String,
        prescription_id: String,
    ) acquires CollectionCapability, MintCarnetRxPrescriptionEvents {
        let collection_address = get_collection_address();
        let constructor_ref = &token::create(
            &get_collection_signer(collection_address),
            utf8(CARNET_RX_COLLECTION_NAME),
            utf8(CARNET_RX_COLLECTION_DESCRIPTION),
            prescription_id.clone(),
            option::none(),
            utf8(CARNET_RX_COLLECTION_URI),
        );

        let token_signer_ref = &object::generate_signer(constructor_ref);

        let prescription = CarnetRxPrescription {
            patientname,
            patientage,
            diagnosis,
            date_of_visit,
            medicine_prescribed,
            medicine_chemical_name,
            prescription_id,
        };

        move_to(token_signer_ref, prescription);

        event::emit_event<MintCarnetRxPrescriptionEvent>(
            &mut borrow_global_mut<MintCarnetRxPrescriptionEvents>(@carnet_rx_prescription).mint_carnet_rx_prescription_events,
            MintCarnetRxPrescriptionEvent {
                prescription_id,
                prescription_details: prescription,
            },
        );
    }

    // Function to get the collection address of CarnetRxPrescriptions
    fun get_collection_address(): address {
        object::create_object_address(&@carnet_rx_prescription, APP_OBJECT_SEED)
    }

    // Function to get the signer for extending the collection
    fun get_collection_signer(collection_address: address): signer acquires CollectionCapability {
        object::generate_signer_for_extending(&borrow_global<CollectionCapability>(collection_address).extend_ref)
    }

    // Function to check the validity of a prescription
    #[view]
    public fun check_prescription_validity(prescription_id: String): (bool, CarnetRxPrescription) {
        let prescription_opt = borrow_global_optional<CarnetRxPrescription>(prescription_id);
        match prescription_opt {
            Some(prescription) => {
                // Perform validity checks here if needed
                (true, prescription)
            }
            None => (false, CarnetRxPrescription::default()),
        }
    }

    // Function to get prescription details by ID
    #[view]
    public fun get_prescription_details(prescription_id: String): (bool, CarnetRxPrescription) {
        let prescription_opt = borrow_global_optional<CarnetRxPrescription>(prescription_id);
        match prescription_opt {
            Some(prescription) => (true, prescription),
            None => (false, CarnetRxPrescription::default()),
        }
    }
}

