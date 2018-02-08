{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module Binance.Api where

import           Types                 (Balance (..), MarketName (..),
                                        Opts (..), Order (..), Ticker (..))
import           Utils

import           Binance.Internal
import           Binance.Types
import           Data.ByteString       (ByteString)
import qualified Data.ByteString.Char8 as B8
import           Data.Text             (Text)
import qualified Data.Text             as Text

defaultOpts = Opts mempty mempty "public" "v1" mempty mempty mempty

ping :: IO (Either String ServerTime)
ping = runGetApi defaultOpts { optPath = "time"}

getTicker :: MarketName -> IO (Either String Ticker)
getTicker mrkt = runGetApi defaultOpts
        { optApiVersion = "v3"
        , optPath       = "ticker/bookTicker"
        , optParams     = [("symbol",toText mrkt)]
        }

getBalance :: IO (Either String Balance)
getBalance = withKeys $ \ pubKey privKey -> do
        t <- timeInMilli
        runGetPrivApi defaultOpts
                { optPath = "account"
                , optApiVersion = "v3"
                , optApiPubKey = pubKey
                , optApiPrivKey = privKey
                , optParams = [ ("timestamp",Text.pack t)]
                }

placeOrder :: Text -> Order -> IO (Either String OrderResponse)
placeOrder side Order{..} = withKeys $ \ pubKey privKey -> do
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

buyLimit :: Order -> IO (Either String OrderResponse)
buyLimit = placeOrder "buy"

sellLimit :: Order -> IO (Either String OrderResponse)
sellLimit = placeOrder "sell"

--------------- KEYS ----------------------------------------------
getKeys :: IO [ByteString]
getKeys = B8.lines <$> B8.readFile "keys/binance.txt"
withKeys :: (ByteString -> ByteString -> IO b) -> IO b
withKeys f = do
        [pubKey,privKey] <- getKeys
        f pubKey privKey
