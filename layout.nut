////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////   

class UserConfig {
</ label="--------  Main theme layout  --------", help="Show or hide additional images", order=1 /> uct1="select below";
   </ label="Select wheel style", help="Select wheel style", options="curved", order=4 /> enable_list_type="curved";
   </ label="Select spinwheel art", help="The artwork to spin", options="wheel", order=5 /> orbit_art="wheel";
   </ label="Wheel transition time", help="Time in milliseconds for wheel spin.", order=6 /> transition_ms="25";  
   </ label="Wheel fade time", help="Time in milliseconds to fade the wheel.", options="Off,2500,5000,7500,10000", order=7 /> wheel_fade_ms="5000"; 
   </ label=" ", help=" ", options=" ", order=16 /> divider5="";
</ label="--------    Miscellaneous    --------", help="Miscellaneous options", order=17 /> uct6="select below";
   </ label="Wheel Sounds", help="Play sounds when navigating games wheel", options="None,Simple,Random", order=25 /> enable_random_sound="Random";
}

local my_config = fe.get_config();
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto";

//for fading of the wheel
first_tick <- 0;
stop_fading <- true;
wheel_fade_ms <- 0;
try {	wheel_fade_ms = my_config["wheel_fade_ms"].tointeger(); } catch ( e ) { }

// modules
fe.load_module("fade");
fe.load_module( "animate" );

//////////////////////////////////////////////////////////////////////////////////
// Load the background layer using the DisplayName for matching 
local b_art = fe.add_image("bg.png", 0, 0, flw, flh );
local background = fe.add_image("bez.png", 0, 0, flw, flh );

local upimage = fe.add_image("1up.png", flx*0.075, fly*0.4, flw*0.2, flh*0.2 );
local upimage = fe.add_image("1up.png", flx*0.725, fly*0.4, flw*0.2, flh*0.2 );

local background = fe.add_image("select.png", flx*0.21, fly*0.325, flw*0.58, flh*0.35 );

//////////////////////////////////////////////////////////////////////////////////
// The following section sets up what type and wheel and displays the users choice

//vertical wheel curved
if ( my_config["enable_list_type"] == "curved" )
{
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.375, flx*0.375, flx*0.375, flx*0.375, flx*0.375, flx*0.325, flx*0.375, flx*0.375, flx*0.375, flx*0.375, flx*0.375, flx*0.375, ]; 
local wheel_y = [ -fly*1.0, fly*0.03, fly*0.115, fly*0.2, fly*0.28, fly*0.4, fly*0.47, fly*0.6, fly*0.64, fly*0.77, fly*0.81, fly*1.0, ];
local wheel_w = [ flw*0.25, flw*0.25, flw*0.25, flw*0.25, flw*0.25, flw*0.35, flw*0.25, flw*0.25, flw*0.25, flw*0.25, flw*0.25, flw*0.25, ];
local wheel_h = [  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2, flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2,  flh*0.2, ];
local wheel_a = [  0,  100,  0,  150,  200,  255, 0,  200,  150,  100,  0,  0, ];
local wheel_r = [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ];
local num_arts = 5;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
                preserve_aspect_ratio = true;
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

conveyor <- Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}

// Play random sound when transitioning to next / previous game on wheel
function sound_transitions(ttype, var, ttime) 
{
	if (my_config["enable_random_sound"] == "Simple")
	{
		local sound_name = "selectclick.mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}
	if (my_config["enable_random_sound"] == "Random")
	{
		local random_num = floor(((rand() % 1000 ) / 1000.0) * (124 - (1 - 1)) + 1);
		local sound_name = "sounds/GS"+random_num+".mp3";
		switch(ttype) 
		{
		case Transition.EndNavigation:		
			local Wheelclick = fe.add_sound(sound_name);
			Wheelclick.playing=true;
			break;
		}
		return false;
	}	
}
fe.add_transition_callback("sound_transitions")

