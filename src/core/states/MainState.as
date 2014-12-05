package core.states 
{
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.gamepad.Gamepad;
	import citrus.input.controllers.gamepad.GamePadManager;
	import citrus.input.controllers.gamepad.maps.GamePadMap;
	import citrus.input.controllers.gamepad.maps.Xbox360GamepadMap;
	import citrus.input.controllers.Keyboard;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.Nape;
	import com.greensock.plugins.HexColorsPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import core.hero.Hero;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.geom.Vec2;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.text.TextField;
	
	public class MainState extends StarlingState
	{
		public var nape:Nape; // Nape instance
		public var isUsingGamepad:Boolean = false;
		public var transitionScreen:Quad;
		public var controlsAdded:Boolean = false;
		
		public function MainState()
		{
			super();
			// On crée l'espace physique
			nape = new Nape("nape");
			nape.gravity = new Vec2(0,100);
			nape.visible = true;
			transitionScreen = new Quad(800, 640, 0x000000);
			transitionScreen.alpha = 1;
			
			Starling.current.stage.addChild(transitionScreen);
			TweenPlugin.activate([HexColorsPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.
		}
		
		override public function initialize():void {
			super.initialize();
			
			// We add the different element for the game to work
			add(nape);
			
			// Define controls
			// var keyboard:Keyboard = _ce.input.keyboard as Keyboard;
			
			var padManager:GamePadManager = new GamePadManager(1,Xbox360GamepadMap);
			padManager.onControllerAdded.add(addGamePad);

			function addGamePad(pad:Gamepad):void {
				pad.setStickActions(GamePadMap.STICK_LEFT,"up","right","down","left");
				pad.setButtonAction(GamePadMap.BUTTON_LEFT, "fire");
				pad.setButtonAction(GamePadMap.BUTTON_BOTTOM, "jump");
				pad.setButtonAction(GamePadMap.BUTTON_TOP, "retrieve");
				pad.setButtonAction(GamePadMap.BUTTON_RIGHT, "use");
			}
			
			if ( !controlsAdded ) {
				var keyboard:Keyboard = _ce.input.keyboard;
				
				// We remove the default controls
				keyboard.removeKeyActions(Keyboard.SPACE);
				keyboard.removeKeyActions(Keyboard.LEFT);
				keyboard.removeKeyActions(Keyboard.RIGHT);
				keyboard.removeKeyActions(Keyboard.DOWN);
				
				// Add the different controls for Keyboard
				keyboard.addKeyAction("right", Keyboard.RIGHT);
				keyboard.addKeyAction("left", Keyboard.LEFT);
				keyboard.addKeyAction("up", Keyboard.UP);
				keyboard.addKeyAction("down", Keyboard.DOWN);
				
				keyboard.addKeyAction("jump", Keyboard.W);
				keyboard.addKeyAction("fire", Keyboard.C);	
				
				controlsAdded = true;
			}
			
			view.camera.setUp(null, new Rectangle(0,0, 2048, 2048), null, new Point(0.5, 0.5));
			
			TweenLite.to(transitionScreen, 0.3, { alpha : 0 } );
			
			
			add(new Platform("sol", { width: 800, height: 10, x: 400, y: 630 } ));
			var hero:Hero = new Hero();
			hero.x = 400; hero.y = 600;
			add(hero);
			
			var te:TextField = new TextField(400, 30, "COUCOUCOUCOU", "Verdana", 24, 0xFFFFFF);
			Starling.current.stage.addChild(te);
		}
	}

}