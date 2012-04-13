import Data.Maybe
import qualified Data.Map as M

import Control.Arrow((&&&))
import Control.Monad((<=<), liftM, ap)
import Control.Concurrent(threadDelay)
import Control.Applicative

import System.IO

import XMonad
import XMonad.Util.XUtils
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.Run
import XMonad.Util.Paste

import XMonad.Layout.Accordion
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Layout.TrackFloating(trackFloating)

import XMonad.Actions.UpdatePointer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks

import XMonad.Hooks.UrgencyHook

import qualified XMonad.StackSet as W

data UrgencyFn = UrgencyFn (Window -> X())

instance Read UrgencyFn where
  readsPrec _ s = [(UrgencyFn . const . return $ (), s)]

instance Show UrgencyFn where
  show _ = ""

instance UrgencyHook UrgencyFn where
  urgencyHook (UrgencyFn f) w = f w

myWorkspaces = map getNamed [1..9]
  where named = [ (1, "web") , (2, "dev"), (8, "smp"), (9, "rok") ]
        getNamed x = fromMaybe (show x) (lookup x named)

myPP = xmobarPP { ppTitle = const ""
                }

myKeys = 
  [ ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 10%+")
  , ("<Print>"               , spawn "ksnapshot")
  , ("<XF86AudioLowerVolume>" , spawn "amixer sset Master 10%-")

  , ("M-c",   spawn "chromium-browser")
  , ("M-e",   spawn "dolphin")
  , ("M-q",   spawn respawnCmd)

  , ("M-S-p", spawn toggleComp)
  , ("M-S-i", spawn "chip")

  , ("C-S-c", spawn clipCopyCmd)
  , ("C-S-v", spawn clipPrePaste >> pasteSelection)

  , ("M-r",  withFocused $ \w -> withDisplay $ \d -> do
               io $ raiseWindow d w
               wa <- io $ getWindowAttributes d w
               io $ moveWindow d w (fromIntegral (fromIntegral (wa_x wa) + 5))
                                   (fromIntegral (fromIntegral (wa_y wa) + 5))
               float w
               )
            
  ]
  where
    respawnCmd = "~/.xmonad/respawn.sh"
    clipCopyCmd = "xclip -selection PRIMARY -o | xclip -selection CLIPBOARD -i"
    clipPrePaste = "xclip -selection CLIPBOARD -o | xclip -selection PRIMARY -i"
    toggleComp = "pkill cairo-compmgr || cairo-compmgr &"

myStatusBar = statusBar "xmobar" myPP (const (mod4Mask, xK_b))

comptonFix :: ManageHook
comptonFix = ask >>= \w -> liftX $ do
    r <- gets $ screenRect . W.screenDetail . W.current . windowset 
    fl <- snd <$> floatLocation w

    let Rectangle l t _ _ = scaleRationalRect r fl 

    float w
    d <- asks display

    -- io $ raiseWindow d w
    io $ moveWindow d w (l + 1) t
  >> idHook

-- New windows only appear as floats in the WindowSet after
-- the Query is run. Only Endo has access to the updated
-- WindowSet, so we can't have side-effects that depend on
-- it.
-- The only solution is to "guess" which windows will be floated
-- by XMonad.
willFloat w = withDisplay $ \d -> do
  sh <- io $ getWMNormalHints d w
  let isFixedSize = sh_min_size sh /= Nothing
                    && sh_min_size sh == sh_max_size sh
  isTransient <- isJust <$> io (getTransientForHint d w)
  return (isFixedSize || isTransient)

floating = (ask >>= liftX . willFloat)

main = do
  (xmonad <=< myStatusBar) $ defaultConfig
    { layoutHook = myLayout
    , logHook = updatePointer (Relative 0.5 0.5)
    , manageHook = myManageHook <+> manageHook defaultConfig  
    , terminal = "urxvt"
    , modMask = mod4Mask
    , workspaces = myWorkspaces
    , borderWidth = 1
    , focusedBorderColor = "#2090b5"
    , normalBorderColor  = "#205055"
    } `additionalKeysP` myKeys

myLayout = trackFloating . smartBorders $ layoutHook defaultConfig
myManageHook = composeAll 
  [ appName =? "smplayer" --> liftX (windows $ W.greedyView "smp") >> doShift "smp" 
  , appName =? "amarok" --> liftX (windows $ W.greedyView "rok") >> doShift "rok"
  , isDialog --> comptonFix
  , isFullscreen --> doFullFloat >> comptonFix
  , floating --> comptonFix >> idHook
  {-, doF $ \ws -> idHook <* fmap when (isFloatQ ws)
                             (void comptonFix ws) 
                             (return ())-}
  ]
