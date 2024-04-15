#import "../.ligo/source/i/ligo_extendable_fa2__1.0.4__ffffffff/lib/main.mligo" "FA2"

module VESTING = struct
  type storage =
    {
     owner_address : address;
     beneficiaries : (address, bool) big_map;
     freeze_duration : nat;
     start_vesting_date : timestamp;
     has_started : bool;
     fa2_token_address : address;
     fa2_token_id : nat
    }

  type result = operation list * storage

  let one_day : int = 86400

  let claimable_amount : nat = 1000n

  let get_transfer_entrypoint (addr, name : address * string) =
    if name = "transfer"
    then
      match Tezos.get_entrypoint_opt "%transfer" addr with
        Some contract -> contract
      | None -> failwith "Transfer entrypoint not found"
    else failwith "Unsupported entrypoint"

  [@entry]
  let start_vesting (freeze_duration : nat) (storage : storage) : result =
    assert_with_error (not storage.has_started) "Vesting has already started";
    assert_with_error (Tezos.get_sender () = storage.owner_address) "Only the owner can start the vesting";
    let new_storage =
      {
        storage with
          freeze_duration = freeze_duration;
          has_started = true;
          start_vesting_date = Tezos.get_now ()
      } in
    ([], new_storage)

  [@entry]
  let add_beneficiary (beneficiary : address) (storage : storage) : result =
    assert_with_error (Tezos.get_sender () = storage.owner_address) "Only the owner can add beneficiaries";
    assert_with_error (not storage.has_started) "Vesting has already started, you can't add new beneficiaries";
    assert_with_error (not (Big_map.mem beneficiary storage.beneficiaries)) "Beneficiary already exists";
    let new_beneficiaries = Big_map.add beneficiary false storage.beneficiaries in
    let new_storage = { storage with beneficiaries = new_beneficiaries } in
    ([], new_storage)

  [@entry]
  let claim_tokens (claimer_address : address) (storage : storage) : result =
    assert_with_error (Big_map.mem claimer_address storage.beneficiaries) "Not a beneficiary";
    assert_with_error (not (Big_map.find claimer_address storage.beneficiaries)) "Tokens already claimed";
    assert_with_error (storage.start_vesting_date + storage.freeze_duration * one_day <= Tezos.get_now ()) "Tokens still frozen";
    let new_beneficiaries = Big_map.update claimer_address (Some true) storage.beneficiaries in
    let new_storage = { storage with beneficiaries = new_beneficiaries } in
    let transfer_contract = get_transfer_entrypoint (storage.fa2_token_address, "transfer") in
    let transfer_info : FA2.SingleAssetExtendable.TZIP12.transfer =
      [
        {
         from_ = Tezos.get_self_address ();
         txs =
           [
             {
              to_ = Tezos.get_sender ();
              token_id = storage.fa2_token_id;
              amount = claimable_amount
             }
           ]
        }
      ] in
    let operation = Tezos.transaction transfer_info 0mutez transfer_contract in
    ([operation], new_storage)
  end