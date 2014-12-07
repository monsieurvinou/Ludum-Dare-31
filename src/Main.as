package 
{
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.ViewportMode;
	import citrus.physics.PhysicsCollisionCategories;
	import core.states.game.GameState;
	import core.states.MainState;
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
				loadLevel(GameState);
			});
		}
		
		private function loadLevel(level:Class, isRestart:Boolean=false):void {
			// Set to TRUE to have the commands like "goto" & others ( for testing only )
			console.enabled = true;
			if ( console.enabled ) {
				addConsoleCommands();
			}
			
			// Remove Listeners
			if (state != null) {
			}
			
			Starling.current.stage.alpha = 1;
			
			
			// Load the new Screen
			state = new level();
			// LISTENERS
			if ( state is GameState) {
				//(state as GameState).loadingEnded.add(loadLevel);
			}
		}
		
		private function ended(type:String="credit"):void
		{
			// Depending on the type, we load different screens.
		}
		
		private function setUpFilters():void
		{
			PhysicsCollisionCategories.Add("WhiteLevel");
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