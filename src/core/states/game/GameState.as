package core.states.game 
{
	import citrus.core.CitrusObject;
	import citrus.utils.objectmakers.ObjectMaker2D;
	import core.objects.Collectible;
	import core.platforms.Limit;
	import core.platforms.PlatBW;
	import core.platforms.PlatRed;
	import core.states.MainState;
	import core.ui.PauseMenu;
	import core.ui.ScoreScreen;
	import embed.EmbedAssets;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import starling.core.Starling;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	/**
	 * @author monsieurvinou
	 */
	public class GameState extends MainState
	{
		public var listPlatforms:Array;
		public var collect:Collectible;
		
		public var timerTF:TextField;
		public var timerUpdate:Timer;
		public var nbSeconds:Number = 60;
		
		public var nbPoints:Number = 0;
		public var pointTF:TextField;
		
		protected var _gamePaused:Boolean = false;
		protected var _pauseScreen:PauseMenu;
		protected var _isRestart:Boolean;
		
		protected var _isDying:Boolean = false;
		protected var _isScoreScreen:Boolean = false;
		protected var _scoreScreen:ScoreScreen;
		
		public function GameState(isRestart:Boolean=false) 
		{
			listPlatforms = new Array();
			var objects:Array = [PlatBW, PlatRed, Limit];
			_isRestart = isRestart;
		}
		
		override public function initialize():void
		{
			super.initialize();
			var levelXml:XML = new XML( new EmbedAssets.LevelXML() );
			var levelObjects:Array = ObjectMaker2D.FromTiledMap(levelXml, [], false);
			for each ( var object:CitrusObject in levelObjects ) {
				if ( object is PlatBW ) listPlatforms.push(object);
				add(object);
			}
			var toCollect:Collectible = new Collectible();
			add(toCollect);
			toCollect.collected.add(addNewCollectible);
			
			// TIMER
			timerTF = new TextField(800, 42, "", "Verdana", 32, 0x222222);
			timerTF.text = formatTimer();
			Starling.current.stage.addChild(timerTF);
			
			pointTF = new TextField(800, 32, "", "Verdana", 24, 0x000000);
			pointTF.text = nbPoints + " points";
			pointTF.hAlign = HAlign.RIGHT;
			pointTF.y = 640 - 32;
			Starling.current.stage.addChild(pointTF);
			timerUpdate = new Timer(1000, 0);
			timerUpdate.start();
			timerUpdate.addEventListener(TimerEvent.TIMER, updateTimer);
			
			_ce.sound.tweenVolume("muffled", 0, 1);
			_ce.sound.tweenVolume("main", 1, 1);
			
			_pauseScreen = new PauseMenu("pauseMenu");
			_ce.state.add(_pauseScreen);
			if ( !_isRestart ) gamePaused = true;
		}
		
		override public function destroy():void
		{
			timerTF.removeFromParent(true);
			timerUpdate.stop();
			pointTF.removeFromParent(true);
			transitionScreen.removeFromParent(true);
			if ( _pauseScreen != null ) _pauseScreen.destroy();
			if ( _scoreScreen != null ) _scoreScreen.destroy();
			super.destroy();
		}
		
		protected function formatTimer():String
		{
			var timerString:String = "";
			
			var seconds:Number = nbSeconds % 60;
			var minutes:Number = (nbSeconds - seconds) / 60;
			
			if ( minutes >= 10 ) timerString += minutes;
			else timerString += "0" + minutes;
			
			timerString += ":";
			
			if ( seconds >= 10 ) timerString += seconds;
			else timerString += "0" + seconds;
			
			return timerString;
		}
		
		/**
		 * Called very second
		 */
		protected function updateTimer(e:TimerEvent):void
		{
			
			if ( nbSeconds - 1 == 0 ) {
				// END GAME
				if ( !_isScoreScreen ) isScoreScreen = true;
			} else {
				nbSeconds -= 1;
			}
			timerTF.text = formatTimer();
		}
		
		protected function addNewCollectible():void
		{
			var toCollect:Collectible = new Collectible();
			add(toCollect);
			toCollect.collected.add(addNewCollectible);
			
			nbSeconds += 5;
			nbPoints += 100 + Math.floor((nbPoints / 10));
			
			timerTF.text = formatTimer();
			pointTF.text = nbPoints + " points";
		}
		
		public function inverse():void
		{
			if ( listPlatforms != null && listPlatforms.length > 0 ) {
				for each ( var platform:PlatBW in listPlatforms ) {
					platform.change();
				}
			}
		}
		
		override public function update(delta:Number):void
		{
			if ( !_gamePaused ) {
				super.update(delta);
				if ( _ce.input.justDid("switch") ) {
					inverse();
				}
			}
			
			if ( _pauseScreen != null &&!_isDying && !_isScoreScreen ) _pauseScreen.update(delta);
		}
		
		public function set isDying(value:Boolean):void 
		{ 
			_isDying = value;
			if ( _isDying ) {
				_pauseScreen.destroy();
				timerUpdate.stop();
			}
		} 
		
		public function set isScoreScreen(value:Boolean):void 
		{
			_isScoreScreen = value;
			if ( _isScoreScreen ) {
				_ce.sound.tweenVolume("muffled", 1, 1);
				_ce.sound.tweenVolume("main", 0, 1);
				_scoreScreen = new ScoreScreen(nbPoints);
				add(_scoreScreen);
			}
		}
		
		public function get gamePaused():Boolean { return _gamePaused; }
		public function set gamePaused(value:Boolean):void { 
			_gamePaused = value;
			if (_gamePaused) {
				timerUpdate.stop();
				_pauseScreen.show();
				_ce.sound.tweenVolume("muffled", 1, 1);
				_ce.sound.tweenVolume("main", 0, 1);
				
			} else {
				timerUpdate.start();
				_pauseScreen.hide();
				_ce.sound.tweenVolume("muffled", 0, 1);
				_ce.sound.tweenVolume("main", 1, 1);
			}
		}
	}

}