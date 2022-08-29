{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Cardano.Api hiding (Script)
import Cardano.Api.Shelley (PlutusScript (PlutusScriptSerialised))
import Codec.Serialise (serialise)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS
import Ledger
import MuesliSwapMYield.Minting (mkScript)
import Plutus.V1.Ledger.Scripts
import System.Environment (getArgs)
import Prelude


main :: IO ()
main = do
  writePlutusScript "MYIELD minting policy" "plutus/myield_minting_policy.plutus" mkScript

writePlutusScript :: String -> FilePath -> Ledger.Script -> IO ()
writePlutusScript title filename scrpt =
  do
    let scriptSBS = SBS.toShort . LBS.toStrict . serialise $ scrpt
    let scriptSerial = PlutusScriptSerialised scriptSBS :: PlutusScript PlutusScriptV1
    result <- writeFileTextEnvelope filename Nothing scriptSerial
    case result of
      Left err -> print $ displayError err
      Right () -> return ()
