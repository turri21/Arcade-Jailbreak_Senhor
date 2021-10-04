# JAILBREAK for [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki)
An FPGA implementation of JAILBREAK for the MiSTer platform

## Credits
- Sorgelig: MiSTer project lead
- MiSTer-X: [Original Green Beret core design](https://github.com/MiSTer-devel/Arcade-RushnAttack_MiSTer) used as a base for this game
- blackwine: [Initial JAILBREAK core design](https://github.com/blackwine/Arcade-Jailbreak_MiSTer/tree/3feee0baf62ca38cdddea546f4fb525ef23e596b)
- Ace: New JAILBREAK core design and Konami custom chip implementations
- JimmyStones: High score saving support & pause feature
- Kitrinx: ROM loader

## Features
- Logic modelled to match the original PCB design as closely as possible
- Standard joystick and keyboard controls
- High score saving (Can be saved manually or automatically - manual saving is the default)
- Greg Miller's cycle-accurate MC6809E CPU core with modifications by Sorgelig and bugfixes by Arnim Laeuger and Jotego as the basis for the KONAMI-1 custom encrypted MC6809E
- SN76489 sound core by Arnim Laeuger with fixes by Ace and Enforcer
- VLM5030 sound core by Arnim Laeuger (https://github.com/FPGAArcade/replay_common/tree/master/lib/sound/vlm5030)
- All audio filters modeled

## Installation
Place `*.rbf` into the "_Arcade/cores" folder on your SD card.  Then, place `*.mra` into the "_Arcade" folder and ROM files from MAME into "games/mame".

### ****ATTENTION****
ROMs are not included. In order to use this arcade core, you must provide the correct ROMs.

To simplify the process, .mra files are provided in the releases folder that specify the required ROMs along with their checksums.  The ROM's .zip filename refers to the corresponding file in the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for information on how to setup and use the environment.

Quick reference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/games/mame/<mame rom>.zip
/games/hbmame/<hbmame rom>.zip

## Controls
### Keyboard
| Key | Function |
| --- | --- |
| 1 | 1-Player Start |
| 2 | 2-Player Start |
| 5, 6 | Coin |
| 9 | Service Credit |
| Arrow keys | Movement |
| CTRL | Fire |
| ALT | Cycle weapons |

### Joystick (buttons follow Super NES layout)
| Joystick action | Function |
| --- | --- |
| D-Pad | Movement |
| B | Fire |
| A | Cycle weapons |

## Known Issues
1) Accuracy of video timings cannot be guaranteed yet until they are measured on an original JAILBREAK PCB
2) Audio filter accuracy cannot be guaranteed yet until the frequency response of an original JAILBREAK PCB is fully analyzed

## High Score Save/Load
Save and load of high scores is supported for this core.

- To save your high scores manually, press the 'Save Settings' option in the OSD.  Hiscores will be automatically loaded when the core is started.
- To enable automatic saving of high scores, turn on the 'Autosave Hiscores' option, press the 'Save Settings' option in the OSD, and reload the core.  High scores will then be automatically saved (if they have changed) any time the OSD is opened.

High score data is stored in /media/fat/config/nvram/ as ```<mra filename>.nvm```

