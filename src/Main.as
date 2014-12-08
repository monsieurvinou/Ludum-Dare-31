package 
{
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.ViewportMode;
	import citrus.events.CitrusSoundEvent;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.sounds.CitrusSoundGroup;
	import core.states.game.GameState;
	import core.states.MainState;
	import embed.EmbedAssets;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.utils.AssetManager;
	
	[SWF(width="800", height="640", frameRate="60")]
	public class Main extends StarlingCitrusEngine
	{
		private var dossier:String;
		
		public function Main():void 
		{	
			_baseWidth = 800;
			_baseHeight = 640;
			_viewportMode = ViewportMode.LETTERBOX;
			fullScreen = true;
			setUpStarling(false, 1);
		}
		
		override public function setUpStarling(debugMode:Boolean=false, antiAliasing:uint=1,   viewPort:Rectangle=null, stage3D:Stage3D=null):void
		{
			super.setUpStarling(debugMode, antiAliasing, viewPort, stage3D);
			
			setUpFilters();
			this.starling.addEventListener("context3DCreate", function(e:*):void {
				// Set to TRUE to have the commands like "goto" & others ( for testing only )
				console.enabled = false;
				if ( console.enabled ) {
					addConsoleCommands();
				}
				
				defineSongs();
				
				loadLevel(GameState);
			});
		}
		
		private function loadLevel(level:Class, isRestart:Boolean = false):void {
			// Remove Listeners
			if (state != null) {
				if ( state is GameState ) {
					(state as GameState).restartLevel.removeAll();
				}
			}
			Starling.current.stage.alpha = 1;
			
			// Load the new Screen
			state = new level(isRestart);
			// LISTENERS
			if ( state is GameState) {
				(state as GameState).restartLevel.add( restart );
			}
		}
		
		private function restart():void
		{
			loadLevel(GameState, true);
		}
		
		private function setUpFilters():void
		{
			PhysicsCollisionCategories.Add("WhiteLevel");
		}
		
		private function defineSongs():void
		{
			
			sound.masterVolume = 0.7;
			sound.getGroup(CitrusSoundGroup.BGM).volume = 0.4;
			sound.getGroup(CitrusSoundGroup.SFX).volume = 0.5;
			
			sound.addSound("main", { 
				sound: new EmbedAssets.SongMain(),
				group: CitrusSoundGroup.BGM
			} );
			
			sound.addSound("muffled", { 
				sound: new EmbedAssets.SongMuffled(),
				group: CitrusSoundGroup.BGM
			} );
			
			sound.playSound("main");
			sound.playSound("muffled");
			sound.getSound("main").volume = 1;
			sound.getSound("muffled").volume = 0;
			
			sound.getSound("main").addEventListener(CitrusSoundEvent.SOUND_END, function():void { sound.playSound("main"); } );
			sound.getSound("muffled").addEventListener(CitrusSoundEvent.SOUND_END, function():void { sound.playSound("muffled"); } );
		}
		
		private function addConsoleCommands():void
		{
			console.addCommand("nape", function():void {
				if ( state != null && state is MainState ) {
					(state as MainState).nape.visible = !(state as MainState).nape.visible;
				}
			});
		}
		
	}
	
}