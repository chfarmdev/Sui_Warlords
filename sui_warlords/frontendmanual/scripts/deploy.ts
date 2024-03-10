import "dotenv/config"

import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519"
import { fromB64 } from "@mysten/sui.js/utils"
import { SuiClient} from "@mysten/sui.js/client"

import path, { dirname } from "path"
import { execSync } from "child_process"
import { fileURLToPath } from "url"
import { process } from "nodes"


const priv_key = process.env.PRIVATE_KEY
if (!priv_key) {
    console.log("Error: PRIVATE_KEY not set in .env")
    process.exit(1)
}

const keypair = Ed25519Keypair.fromSecretKey(fromB64(priv_key).slice(1))
const client = new SuiClient({ url: RPC_URL_DEPLOY })

const path_to_contracts = path.join(dirname(fileURLToPath(import.meta.url)), "../../contracts")
console.log(JSON.parse(execSync(
    `sui move build --dump-bytecode-as-base64 --path ${path_to_contracts}`,
    { encoding: "utf-8" }
)))