import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit } from "@taquito/taquito";
import * as dotenv from "dotenv";
import Vesting from "../compiled/Vesting.mligo.json";

dotenv.config();

const SECRET_KEY = process.env.SECRET_KEY;
const ADMIN_ADDRESS = process.env.ADMIN_ADDRESS;

const RPC_ENDPOINT = "https://ghostnet.tezos.marigold.dev";

export async function DeployVesting(
    token_address: string
): Promise<string | void> {
    if (!SECRET_KEY || !ADMIN_ADDRESS) return;
    const Tezos = new TezosToolkit(RPC_ENDPOINT);


    Tezos.setProvider({
        signer: await InMemorySigner.fromSecretKey(SECRET_KEY),
    });

    const initialStorage = {
        owner_address: ADMIN_ADDRESS,
        beneficiaries: new Map([]),
        freeze_duration: 1296000,
        start_vesting_date: new Date("2024-01-01T00:00:00Z"),
        has_started: false,
        fa2_token_address: token_address,
        fa2_token_id: 0

    };

    try {
        const originated = await Tezos.contract.originate({
            code: Vesting,
            storage: initialStorage,
        });
        console.log(
            `Contract address: ${originated.contractAddress}`
        );
        await originated.confirmation(2);
        console.log("Confirmed contract: ", originated.contractAddress);
        return originated.contractAddress;
    } catch (error: any) {
        console.log(error);
    }
}
