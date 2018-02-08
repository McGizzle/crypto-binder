{-# LANGUAGE OverloadedStrings #-}
module <newmodule>.Api where

import Types 
        ( Api
        , Ticker(..)
        , Currency(..)
        , Currency'(..)
        , MarketName(..)
        , Balance(..) 
        , Order(..)) 
import qualified Types as T

import           <newmodule>.Types
import           <newmodule>.Internal
import           Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as B8

defaultOpts = Opts mempty mempty "public" mempty mempty mempty mempty

ping :: IO (Either String String)
ping = return $ Left "Implement Me!"

getTicker :: MarketName -> IO (Either String Ticker)
getTicker mrkt = return $ Left "Implement Me!"

getBalance :: IO (Either String Balance)
getBalance = withKeys $ \ pubKey privKey -> return $ Left "Implement Me!" 

buyLimit :: Order -> IO (Either String Order)
buyLimit Order{..} = withKeys $ \ pubKey privKey -> return $ Left "Implement Me!"

sellLimit :: Order -> IO (Either String Order)
sellLimit Order{..} = withKeys $ \ pubKey privKey -> return $ Left "Implement Me!"

------ KEYS --------------------------------
getKeys :: IO [ByteString]
getKeys = B8.lines <$> B8.readFile "keys/<newmodule>.txt"
withKeys :: (ByteString -> ByteString -> IO b) -> IO b
withKeys f = do
        [pubKey,privKey] <- getKeys
        f pubKey privKey
