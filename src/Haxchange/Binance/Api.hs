{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module Haxchange.Binance.Api where

import           Types                      (APIKeys (..), Balance, Error,
                                             Markets (..), Opts (..),
                                             Order (..), OrderId, ServerTime,
                                             Tickers (..))
import           Utils

import           Data.Text                  (Text)
import qualified Data.Text                  as Text
import           Haxchange.Binance.Internal
import           Haxchange.Binance.Types

defaultOpts :: Opts
defaultOpts = Opts mempty mempty "public" "v1" mempty mempty mempty

ping :: IO (Either Error ServerTime)
ping = runGetApi defaultOpts { optPath = "time"}

getMarkets :: IO (Either Error Markets)
getMarkets = runGetApi defaultOpts
        { optApiVersion = "v1"
        , optPath       = "ticker/allBookTickers"
        }

getTicker :: Markets -> IO (Either Error Tickers)
getTicker mrkts = runGetApi defaultOpts
        { optApiVersion = "v3"
        , optPath       = "ticker/bookTicker"
        , optParams     = [("symbol",toText mrkts)]
        }

getBalance :: APIKeys -> IO (Either Error Balance)
getBalance (APIKeys pubKey privKey) =  do
        t <- timeInMilli
        runGetPrivApi defaultOpts
                { optPath = "account"
                , optApiVersion = "v3"
                , optApiPubKey = pubKey
                , optApiPrivKey = privKey
                , optParams = [ ("timestamp",Text.pack t)]
                }

placeOrder :: APIKeys -> Text -> Order -> IO (Either Error OrderId)
placeOrder (APIKeys pubKey privKey) side Order{..} = do
        t <- timeInMilli
        runPostApi defaultOpts
                    {
                      optPath = "order/test"
                    , optApiVersion = "v3"
                    , optApiPubKey = pubKey
                    , optApiPrivKey = privKey
                    , optPost = [ ("symbol", toText orderMarket)
                                , ("type", "limit")
                                , ("side", side )
                                , ("quantity", orderVolume )
                                , ("price", orderPrice )
                                , ("timeInForce", "GTC")
                                , ("timestamp",Text.pack t) ]
                    }

buyLimit :: APIKeys -> Order -> IO (Either Error OrderId)
buyLimit keys = placeOrder keys "buy"

sellLimit :: APIKeys -> Order -> IO (Either Error OrderId)
sellLimit keys = placeOrder keys "sell"