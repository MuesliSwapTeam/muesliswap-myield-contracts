{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -fno-specialise #-}
{-# OPTIONS_GHC -fno-worker-wrapper #-}

module MuesliSwapMYield.Minting
  ( mkScript
  )
where

import Data.Maybe (fromJust)
import qualified PlutusTx.AssocMap as Map
import Ledger
  ( CurrencySymbol,
    MintingPolicy,
    Script,
    TokenName,
    TxId (getTxId),
    TxOutRef (TxOutRef),
    scriptCurrencySymbol,
    unMintingPolicyScript,
    after,
    POSIXTime (POSIXTime),
    txInfoValidRange,
    scriptContextTxInfo,
    ownCurrencySymbol,
    txInfoMint,
    txSignedBy,
    PubKeyHash (PubKeyHash),
  )
import qualified Plutonomy
import Plutus.V1.Ledger.Api (toBuiltin)
import Plutus.V1.Ledger.Value
  ( TokenName (TokenName),
    tokenName,
    valueOf,
    getValue
  )
import qualified PlutusTx
import PlutusTx.Prelude
import Text.Hex (decodeHex)

data MintingParams = MintingParams
  { mpTokenName :: TokenName,
    mpOwnerPkh :: PubKeyHash,
    mpDeadline :: POSIXTime
  }
PlutusTx.makeIsDataIndexed ''MintingParams [('MintingParams, 0)]
PlutusTx.makeLift ''MintingParams

{-# INLINEABLE mkTokenName #-}
mkTokenName :: TokenName
mkTokenName = tokenName $ fromJust $ decodeHex "4d5949454c44"

{-# INLINEABLE mkPolicy #-}
mkPolicy :: MintingPolicy
mkPolicy = Plutonomy.optimizeUPLC $ Plutonomy.mintingPolicyToPlutus originalPolicy

{-# INLINEABLE mkScript #-}
mkScript :: Script
mkScript = unMintingPolicyScript mkPolicy

originalPolicy :: Plutonomy.MintingPolicy
originalPolicy =
  Plutonomy.mkMintingPolicyScript
    ( $$(PlutusTx.compile [|| validateMint ||])
        `PlutusTx.applyCode` PlutusTx.liftCode params
    )
  where
    !params =
      MintingParams
        { mpTokenName = mkTokenName,
          mpOwnerPkh = "a3f48e41257bd2dcd704ae173e1d25066d23d291d0b8a69c13522274",
          mpDeadline = POSIXTime 1661612400000
        }

{-# INLINEABLE validateMint #-}
validateMint :: MintingParams -> BuiltinData -> BuiltinData -> ()
validateMint MintingParams {..} _ rawContext
    | nOfMYield < 0 = if signedByOwner then () else error ()
    | otherwise =
        if signedByOwner && after mpDeadline (txInfoValidRange info)
          then ()
        else error ()
  where
    context = PlutusTx.unsafeFromBuiltinData rawContext
    info = scriptContextTxInfo context
    ownSymbol = ownCurrencySymbol context
    mintValue = txInfoMint info

    nOfMYield :: Integer
    nOfMYield
      | Map.lookup ownSymbol (getValue mintValue) == Just (Map.fromList [(mpTokenName, n)]) = n
      | otherwise = error ()
      where
        n = valueOf mintValue ownSymbol mpTokenName

    signedByOwner :: Bool
    signedByOwner = txSignedBy info mpOwnerPkh