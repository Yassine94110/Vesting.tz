import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit } from "@taquito/taquito";
import * as dotenv from "dotenv";
import Token from "../compiled/Token.mligo.json";

dotenv.config();

const RPC_ENDPOINT = "https://ghostnet.tezos.marigold.dev";

export async function DeployToken(): Promise<string | void> {
    const SECRET_KEY: string | undefined = process.env.SECRET_KEY;
    const ADMIN_ADDRESS: string | undefined = process.env.ADMIN_ADDRESS;

    if (!SECRET_KEY || !ADMIN_ADDRESS) {
        console.log("Secret key or admin address not provided.");
        return;
    }

    try {
        const Tezos = new TezosToolkit(RPC_ENDPOINT);

        Tezos.setProvider({
            signer: await InMemorySigner.fromSecretKey(SECRET_KEY),
        });

        const initialStorage = {
            extension: {
                admin: ADMIN_ADDRESS,
            },
            ledger: new Map([]),
            metadata: new Map([]),
            operators: new Map([]),
            token_metadata: new Map([]),
        };

        const originated = await Tezos.contract.originate({
            code: Token,
            storage: initialStorage,
        });

        console.log("Contract address:", originated.contractAddress);
        await originated.confirmation(2);
        console.log("Confirmed contract:", originated.contractAddress);
        return originated.contractAddress;
    } catch (error: any) {
        console.error("An error occurred during contract deployment:", error);
    }
}
