{-# LANGUAGE OverloadedStrings #-}
module Binance.ApiSpec where

import           Binance.Api
import           Test.Hspec
import           Test.Hspec.Expectations.Contrib
import           Types

spec :: Spec
spec = do
        describe "Connectivity" $ do
                it "Pings server" $ do
                        res <- ping
                        res `shouldSatisfy` isRight
        describe "GET" $ do
                it "Account balance" $ do
                        res <- getBalance
                        res `shouldSatisfy` isRight
                it "Ticker for ETH/BTC market" $ do
                        res <- getTicker market
                        res `shouldSatisfy` isRight
        describe "POST" $ do
                it "Buy (correct info)" $ do
                        res <- buyLimit order
                        res `shouldSatisfy` isRight
                it "Buy (incorrect info)" $ do
                        res <- buyLimit badOrder
                        res `shouldSatisfy` isLeft
                it "Sell (correct info)" $ do
                        res <- sellLimit order
                        res `shouldSatisfy` isRight
                it "Sell (incorrect info)" $ do
                        res <- sellLimit badOrder
                        res `shouldSatisfy` isLeft
       where market    = MarketName (COIN ETH) (COIN BTC)
             badMarket = MarketName (COIN BTC) (COIN BTC)
             order     = Order market "100.00" "100.00"
             badOrder  = Order badMarket "100.00" "100.00"
