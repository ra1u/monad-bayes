-- HMM from Anglican (https://bitbucket.org/probprog/anglican-white-paper)

{-# LANGUAGE
 FlexibleContexts,
 TypeFamilies
 #-}

module HMM (
  values,
  hmm
  ) where

--Hidden Markov Models

import Data.Vector (fromList)

import Control.Monad.Bayes.Class

-- | Observed values
values :: [Double]
values = [0.9,0.8,0.7,0,-0.025,-5,-2,-0.1,0,
          0.13,0.45,6,0.2,0.3,-1,-1]

-- | The transition model.
trans :: MonadSample m => Int -> m Int
trans 0 = categorical $ fromList [0.1, 0.4, 0.5]
trans 1 = categorical $ fromList [0.2, 0.6, 0.2]
trans 2 = categorical $ fromList [0.15,0.7,0.15]

-- | The emission model.
emissionMean :: Int -> Double
emissionMean x = mean x where
  mean 0 = -1
  mean 1 = 1
  mean 2 = 0

-- | Initial state distribution
start :: MonadSample m => m [Int]
start = uniformD [[0],[1],[2]]

-- | Example HMM from http://dl.acm.org/citation.cfm?id=2804317
hmm :: (MonadInfer m) => [Double] -> m [Int]
hmm dataset = fmap reverse states where
  states = foldl expand start dataset
  --expand :: MonadBayes m => m [Int] -> Double -> m [Int]
  expand d y = do
    rest <- d
    x    <- trans $ head rest
    factor $ normalPdf (emissionMean x) 1 y
    return (x:rest)
