# Muesli Yield Token 🥣🌾
The Muesli Yield (MYIELD) token is the official farming reward token of the MuesliSwap DEX. For information on its distribution policies, we refer our designated article. This repository contains the minting contract corresponding to MYield's pollicy ID. It enforces the following minting/burning logic:
1. Minting must happen before the deadline (set to August 27, 2022, 15:00:00 GMT), must be performed by the owner (i.e. having PubKeyHash `a3f48e41257bd2dcd704ae173e1d25066d23d291d0b8a69c13522274`). As can be monitored via a [blockchain explorer](https://cardanoscan.io/transaction/58ce9247c08155449f4b30736b982b06441359edfa80b106f3be56117ac8dc0b?tab=tokenmint), exactly one mint of `100,000,000` MYIELD has taken place before the deadline (hence there can never be more tokens than that in the future).
2. Burning can happen at any point in time and must also be performed by the owner with above PubKeyHash (to prevent accidental burns resulting in lost funds).

## Reproducing the MYIELD policy ID
In order to convince yourself that the contracts in this repository indeed compile to the given policy ID, proceed as follows:
- make sure `nix` is available on your machine
- checkout https://github.com/input-output-hk/plutus-apps to commit `c1c65f7873fe184ff54ab25a43aeb8548fe6ff9c`
- run `nix-shell --extra-experimental-features flakes` command
- in `nix-shell` go to the root of this repository
- run `cabal run muesliswapmyield` (results in `myield_minting_policy.plutus` file in `plutus` folder)
- run `./build-scripts.sh` and check the `myield_policyid` in `plutus` folder

## MYIELD token information
- *Number of decimal places:* 6
- *Total supply:* 100,000,000
- *Policy ID:* `8f9c32977d2bacb87836b64f7811e99734c6368373958da20172afba`
- *Asset name:* `MYIELD (4d5949454c44)`
See also the [MYIELD Cardanoscan page](https://cardanoscan.io/token/8f9c32977d2bacb87836b64f7811e99734c6368373958da20172afba4d5949454c44).