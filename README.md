# Dominos Fader

Adds [MouseOverActionSettings](https://github.com/Slothpala/MouseoverActionSettings) support to [Dominos](https://github.com/tullamods/Dominos) action bars.

## Description

This addon bridges Dominos and MouseOverActionSettings, allowing you to use MAS's powerful mouseover fading system with Dominos bars. Each Dominos bar will be automatically registered with MouseOverActionSettings, giving you full control over fade-in/fade-out behavior, transparency levels, animation speeds, and event triggers.

## Features

- **Automatic Integration**: Automatically detects and registers all Dominos bars with MouseOverActionSettings
- **Full MAS Support**: Access all MouseOverActionSettings features for your Dominos bars:
  - Customizable min/max alpha (transparency)
  - Adjustable fade-in/fade-out animation speeds
  - Mouseover delay configuration
  - Event-based visibility triggers (combat, mounted, targeting, etc.)
- **Supported Bars**:
  - Action Bars (1-10)
  - Pet Bar
  - Stance/Class Bar
  - Bag Bar
  - Menu Bar (Micro Menu)
  - Extra Ability Bar

## Requirements

- **Dominos** - The main action bar addon
- **MouseOverActionSettings** - The mouseover fading system

Both addons must be installed and enabled for Dominos_Fader to work.

## Installation

1. Download and install both Dominos and MouseOverActionSettings
2. Extract Dominos_Fader to your `World of Warcraft\_retail_\Interface\AddOns\` folder
3. Restart WoW or reload UI (`/reload`)

## Usage

Once installed, Dominos_Fader works automatically:

1. Load the game with all three addons enabled
2. Open MouseOverActionSettings options (`/mas` or `/MouseoverActionSettings`)
3. Look for your Dominos bars in the MAS interface:
   - DominosActionBar1, DominosActionBar2, etc. for action bars
   - DominosPetBar for the pet bar
   - DominosStanceBar for the stance/class bar
   - DominosBagBar for the bag bar
   - DominosMenuBar for the micro menu
   - DominosExtraBar for the extra ability bar

4. Configure each bar's fade settings as desired:
   - **Min Alpha**: Transparency when not moused over (0 = invisible, 1 = opaque)
   - **Max Alpha**: Transparency when moused over
   - **Delay**: How long to wait before fading out after mouse leaves
   - **Animation Speed**: How fast the fade transition occurs
   - **Triggers**: Which events should show the bar (combat, mounted, etc.)

## Configuration

All configuration is done through the MouseOverActionSettings interface. Each Dominos bar appears as a separate module that can be independently configured.

### Example Configurations

**Combat-Only Action Bar:**
- Min Alpha: 0 (invisible)
- Max Alpha: 1 (fully visible)
- Enable "Combat" trigger
- Result: Bar only shows during combat or when moused over

**Subtle Fade:**
- Min Alpha: 0.3 (slightly visible)
- Max Alpha: 1
- Delay: 0.5 seconds
- Result: Bar is always somewhat visible but becomes opaque on mouseover

## How It Works

Dominos_Fader acts as a bridge between the two addons:

1. It monitors Dominos for bar creation/destruction
2. When a Dominos bar is created, it:
   - Collects all buttons from that bar
   - Creates a MouseOverActionSettings "mouseover unit" 
   - Registers it as a MAS module
   - Enables the module so it appears in MAS options

3. Each bar gets its own settings profile in MAS's saved variables

## Troubleshooting

**Bars not fading:**
- Ensure both Dominos and MouseOverActionSettings are loaded
- Check that the specific bar module is enabled in MAS options
- Verify min/max alpha values are different
- Make sure you're not in Dominos config mode (fading is disabled during config)

**Bars missing from MAS options:**
- Check that the bar exists in Dominos (some bars like stance bar only exist for certain classes)
- Try `/reload` to force re-registration
- Check your WoW version matches the addon's TOC interface version

**Performance issues:**
- If experiencing lag, try:
  - Increasing animation speeds (faster = less CPU time)
  - Reducing the number of active status event triggers
  - Disabling fading for bars you don't actively use

## Known Limitations

- Dominos config mode overrides fading behavior
- Some special bars (like the possess bar) may not be supported
- Changes to Dominos bar structure (adding/removing bars) may require a `/reload` to update MAS registration

## Credits

- **Tuller** - Creator of Dominos
- **Slothpala** - Creator of MouseOverActionSettings
- This addon simply bridges the two excellent addons together

## Support

For issues with:
- **Dominos functionality**: Visit the [Dominos GitHub](https://github.com/tullamods/Dominos)
- **MouseOverActionSettings features**: Visit the [MAS GitHub](https://github.com/Slothpala/MouseoverActionSettings)
- **This integration addon**: Report issues on this addon's page

## License

This addon follows the same license as its dependencies.

Support me on [Ko-Fi](https://ko-fi.com/burntorangejedi)
