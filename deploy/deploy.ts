
import { DeployToken } from "./deployToken";
import { DeployVesting } from "./deployVesting";

async function main() {
    try {
        const tokenAddr = await DeployToken();
        if (typeof tokenAddr === "string") {
            try {
                const vestingAddr = await DeployVesting(tokenAddr);
                if (typeof vestingAddr === "string") {
                    console.log("Deployment successful");
                } else {
                    console.error("Deployment of Vesting failed");
                }
            } catch (error) {
                console.error(error);
            }
        } else {
            console.error("Deployment of Token failed");
        }
    } catch (error) {
        console.error(error);
    }
    console.log("oui oui");
}

main();
