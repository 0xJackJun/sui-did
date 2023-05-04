//import { JsonRpcProvider, devnetConnection } from '@mysten/sui.js';
import { Ed25519Keypair, JsonRpcProvider, RawSigner } from '@mysten/sui.js';

const keypair = new Ed25519Keypair();
const provider = new JsonRpcProvider();
const signer = new RawSigner(keypair, provider);
const moveCallTxn = await signer.executeMoveCall({
  packageObjectId: '0x6ca42c7ed53cc35ad1f283b1340c3a022e581984',
  module: 'did',
  function: 'claimDid',
  typeArguments: [],
  arguments: [
    'Example NFT',
    'jack.key',
    'ipfs://bafkreibngqhl3gaa7daob4i2vccziay2jjlp435cf66vhono7nrvww53ty',
  ],
  gasBudget: 10000,
});
console.log('moveCallTxn', moveCallTxn);