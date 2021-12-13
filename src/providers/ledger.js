const LedgerWalletProvider = require("@ledgerhq/web3-subprovider");
// https://github.com/LedgerHQ/ledgerjs/tree/master/packages/hw-app-eth
// sign req and data are sent to usb using 
const createLedgerSubprovider = LedgerWalletProvider.default
const TransportU2F = require('@ledgerhq/hw-transport-u2f')
 // depr https://github.com/LedgerHQ/ledgerjs/blob/master/docs/migrate_webusb.md
const ProviderEngine = require('web3-provider-engine')
const RpcSubprovider = require('web3-provider-engine/subproviders/rpc')

// import Web3 from "web3";
// import createLedgerSubprovider from "@ledgerhq/web3-subprovider";
// import TransportU2F from "@ledgerhq/hw-transport-u2f";
// import ProviderEngine from "web3-provider-engine";
// import RpcSubprovider from "web3-provider-engine/subproviders/rpc";
// const engine = new ProviderEngine();
// const getTransport = () => TransportU2F.create();
// const ledger = createLedgerSubprovider(getTransport, {
// accountsLength: 5
// });
// engine.addProvider(ledger);
// engine.addProvider(new RpcSubprovider({ rpcUrl }));
// engine.start();
// const web3 = new Web3(engine);

function getLedgerProvider(rpcUrl) {
    const engine = new ProviderEngine()
    const getTransport = () => TransportU2F.create()
    const ledger = createLedgerSubprovider(getTransport, {
        accountsLength: 5
    })
    engine.addProvider(ledger)
    engine.addProvider(new RpcSubprovider({ rpcUrl }))
    engine.start()
    return engine
}

module.exports = { getLedgerProvider }
