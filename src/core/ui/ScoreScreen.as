package core.ui 
{
	import citrus.core.CitrusObject;
	import com.greensock.TweenLite;
	import core.states.game.GameState;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.text.TextField;
	/**
	 * @author monsieurvinou
	 */
	public class ScoreScreen extends CitrusObject
	{
		
		protected var _modal:Quad;
		protected var _titleScore:TextField;
		protected var _scoreValue:TextField;
		protected var _tips:TextField;
		protected var _howtorestart:TextField;
		
		protected var _score:Number;
		
		public function ScoreScreen(score:Number) 
		{
			_score = score;
			super("");
			updateCallEnabled = true;
		}
		
		override public function initialize(pool:Object = null):void
		{
			super.initialize(pool);
			
			_modal = new Quad(800, 640, 0x000000);
			
			_titleScore = new TextField(800, 56, "SCORE", "Verdana", 48, 0xCCCCCC, true);
			_scoreValue = new TextField(800, 50, _score + " pts", "Verdana", 42, 0xEEEEEE, true);
			_tips = new TextField(800, 56, "", "Verdana", 12, 0xCCCCCC, true);
			_howtorestart = new TextField(800, 56, "Press ENTER or START(XBOX360) to restart.", "Verdana", 16, 0xCCCCCC, true);
			
			_modal.alpha = 0;
			_titleScore.alpha = 0;
			_scoreValue.alpha = 0;
			_tips.alpha = 0;
			_howtorestart.alpha = 0;
			
			_titleScore.y = 180;
			_scoreValue.y = 246;
			_tips.y = 320;
			_howtorestart.y = 582;
			
			Starling.current.stage.addChild(_modal);
			Starling.current.stage.addChild(_titleScore);
			Starling.current.stage.addChild(_scoreValue);
			Starling.current.stage.addChild(_tips);
			Starling.current.stage.addChild(_howtorestart);
			
			TweenLite.to(_modal, 1.4, {alpha: 0.75} );
			TweenLite.to(_titleScore, 1.4, {alpha: 1} );
			TweenLite.to(_scoreValue, 1.4, {alpha: 1} );
			TweenLite.to(_tips, 1.4, {alpha: 1} );
			TweenLite.to(_howtorestart, 4.6, { alpha: 1 } );
			
			setTips();
		}
		
		override public function update(delta:Number):void
		{
			super.update(delta);
			if ( _modal.alpha == 0.75 ) {
				if ( _ce.input.justDid("start") ) {
					
					(_ce.state as GameState).transitionScreen.removeFromParent();
					Starling.current.stage.addChild( (_ce.state as GameState).transitionScreen );
					TweenLite.to( (_ce.state as GameState).transitionScreen, 1, { alpha: 1, onComplete: function():void {
						(_ce.state as GameState).restartLevel.dispatch();
					} } );
				}
			}
		}
		
		override public function destroy():void
		{
			_modal.removeFromParent(true);
			_scoreValue.removeFromParent(true);
			_titleScore.removeFromParent(true);
			_tips.removeFromParent(true);
			_howtorestart.removeFromParent(true);
			super.destroy();
		}
		
		public function setTips():void
		{
			var tips:Array = [
				"If you press ALT+F4, you can close the game and stop inflicting this to yourself! Splendid!",
				"Elephants don't drink through their trumps like a straw.",
				"You can press the Switch Button and try to make your character glitch out of the level!",
				"If you score more than 10 000 000 points, you'll get no easter egg!",
				"Hey. Psst. Wanna buy some candies?",
				"Error #04729 : The class ['ProTips'] cannot be this informative.",
				"If your eggs floats when you put them underwater, they aren't good for consumption anymore.",
				"To cut onions without crying, you can man up and stop being such an emotionnal cook.",
				"Dogs have souls.",
				"What time is it?",
				"BRING HIM THE PHOTO",
				"This is the last tip. No it isn't.",
				"You know who else scored something this low? MY MUM!",
				"Pick up a good book. Throw it in the fireplace. It's cold man."
			];
			var random:Number = Math.round(Math.random() * (tips.length - 1));
			_tips.text = tips[random];
		}
		
		
		
	}

}