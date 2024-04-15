#import "../.ligo/source/i/ligo__s__fa__1.3.0__ffffffff/lib/main.mligo" "FA2"

module TOKEN = struct
  type extension = {admin : address}

  type storage = extension FA2.SingleAssetExtendable.storage

  type ret = operation list * storage

  [@entry]
  let transfer (t : FA2.SingleAssetExtendable.TZIP12.transfer) (s : storage)
  : ret = FA2.SingleAssetExtendable.transfer t s

  [@entry]
  let balance_of (b : FA2.SingleAssetExtendable.TZIP12.balance_of) (s : storage)
  : ret = FA2.SingleAssetExtendable.balance_of b s

  [@entry]
  let update_operators
    (u : FA2.SingleAssetExtendable.TZIP12.update_operators)
    (s : storage)
  : ret = FA2.SingleAssetExtendable.update_operators u s

  [@view]
  let get_balance (p : (address * nat)) (s : storage) : nat =
    FA2.SingleAssetExtendable.get_balance p s

  [@view]
  let total_supply (token_id : nat) (s : storage) : nat =
    FA2.SingleAssetExtendable.total_supply token_id s

  [@view]
  let all_tokens (_ : unit) (s : storage) : nat set =
    FA2.SingleAssetExtendable.all_tokens () s

  [@view]
  let is_operator (op : FA2.SingleAssetExtendable.TZIP12.operator) (s : storage)
  : bool = FA2.SingleAssetExtendable.is_operator op s

  [@view]
  let token_metadata (p : nat) (s : storage)
  : FA2.SingleAssetExtendable.TZIP12.tokenMetadataData =
    FA2.SingleAssetExtendable.token_metadata p s
  end
