package core.ui 
{
	import citrus.core.CitrusObject;
	import citrus.objects.CitrusSprite;
	import com.greensock.TweenLite;
	import core.states.game.GameState;
	import embed.EmbedAssets;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/**
	 * @author monsieurvinou
	 */
	public class PauseMenu extends CitrusObject
	{
		
		protected var _resume:TextField;
		protected var _restart:TextField;
		protected var _howTo:TextField;
		protected var _modal:Quad;
		protected var _howtoplay:Image;
		protected var _active:String = "resume";
		
		public function PauseMenu(name:String, params:Object=null) 
		{
			super(name, params);
		}
		
		override public function destroy():void
		{
			_resume.removeFromParent(true);
			_restart.removeFromParent(true);
			_howTo.removeFromParent(true);
			_howtoplay.removeFromParent(false);
			_modal.removeFromParent(true);
			super.destroy();
		}
		
		override public function initialize(pool:Object = null):void
		{
			super.initialize(pool);
			_resume = new TextField(800, 32, "Resume", "Verdana", 24, 0xAAAAAA, true);
			_restart = new TextField(800, 32, "Restart", "Verdana", 24, 0xAAAAAA, true);
			_howTo = new TextField(800, 32, "How To Play", "Verdana", 24, 0xAAAAAA, true);
			_modal = new Quad(800, 640, 0x000000);
			_modal.alpha = 0;
			_resume.alpha = 0;
			_restart.alpha = 0;
			_howTo.alpha = 0;
			
			_howtoplay = new Image(Texture.fromBitmap( new EmbedAssets.HowToPlay() ));
			
			_resume.y = 304;
			_restart.y = 336;
			_howTo.y = 372
			
			Starling.current.stage.addChild(_modal);
			Starling.current.stage.addChild(_resume);
			Starling.current.stage.addChild(_restart);
			Starling.current.stage.addChild(_howTo);
			Starling.current.stage.addChild(_howtoplay);
			_howtoplay.alpha = 0;
		}
		
		override public function update(delta:Number):void
		{
			if ( (_ce.state as GameState).gamePaused ) {
				super.update(delta);
				
				if ( _howtoplay.alpha == 0 ) {
					if ( _active == "resume" && _resume.color != 0xFFFFFF ) _resume.color = 0xFFFFFF;
					else if ( _active != "resume" && _resume.color == 0xFFFFFF ) _resume.color = 0xAAAAAA;
					if ( _active == "restart" && _restart.color != 0xFFFFFF ) _restart.color = 0xFFFFFF;
					else if ( _active != "restart" && _restart.color == 0xFFFFFF ) _restart.color = 0xAAAAAA;
					if ( _active == "howto" && _howTo.color != 0xFFFFFF ) _howTo.color = 0xFFFFFF;
					else if ( _active != "howto" && _howTo.color == 0xFFFFFF ) _howTo.color = 0xAAAAAA;
					
					if ( _ce.input.justDid("up") ) {
						if ( _active == "resume" ) _active = "howto";
						else if ( _active == "howto" ) _active = "restart";
						else if ( _active == "restart" ) _active = "resume";
					}
					if ( _ce.input.justDid("down") ) {
						if ( _active == "resume" ) _active = "restart";
						else if ( _active == "howto" ) _active = "resume";
						else if ( _active == "restart" ) _active = "howto";
					}
					
					if ( _ce.input.justDid("jump") ) {
						if ( _active == "howto" ) {
							TweenLite.to(_howtoplay, 1, { alpha: 1 } );
						} else if ( _active == "restart" ) {
							(_ce.state as GameState).restartLevel.dispatch();
						} else {
							(_ce.state as GameState).gamePaused = false;
						}
					}
					
					if ( _ce.input.justDid("start") ) {
						(_ce.state as GameState).gamePaused = false;
					}
				} else if ( _howtoplay.alpha == 1 ) {
					if ( _ce.input.justDid("jump") || _ce.input.justDid("start") || _ce.input.justDid("switch") ) {
						TweenLite.to(_howtoplay, 0.5, { alpha: 0 } );
					}
				}
			} else {
				if ( _ce.input.justDid("start") ) {
					(_ce.state as GameState).gamePaused = true;
				}
			}
		}
		
		public function hide():void
		{
			TweenLite.to(_resume, 0.5, { alpha: 0 } );
			TweenLite.to(_restart, 0.5, { alpha: 0 } );
			TweenLite.to(_howTo, 0.5, { alpha: 0 } );
			TweenLite.to(_modal, 0.5, { alpha: 0 } );
		}
		
		public function show():void 
		{
			bringToFront();
			TweenLite.to(_resume, 0.5, { alpha: 1 } );
			TweenLite.to(_restart, 0.5, { alpha: 1 } );
			TweenLite.to(_howTo, 0.5, { alpha: 1 } );
			TweenLite.to(_modal, 0.5, { alpha: 0.75 } );
		}
		
		protected function bringToFront():void
		{
			_modal.removeFromParent();
			_howtoplay.removeFromParent();
			_resume.removeFromParent();
			_restart.removeFromParent();
			_howTo.removeFromParent();
			
			Starling.current.stage.addChild(_modal);
			Starling.current.stage.addChild(_resume);
			Starling.current.stage.addChild(_restart);
			Starling.current.stage.addChild(_howTo);
			Starling.current.stage.addChild(_howtoplay);
		}
		
	}

}