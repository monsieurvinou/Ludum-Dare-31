package core.objects 
{
	import citrus.core.CitrusObject;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.objects.platformer.nape.Sensor;
	import citrus.physics.nape.NapeUtils;
	import citrus.physics.PhysicsCollisionCategories;
	import com.greensock.plugins.HexColorsPlugin;
	import com.greensock.TweenLite;
	import core.hero.Hero;
	import core.platforms.Limit;
	import core.platforms.PlatBW;
	import core.platforms.PlatRed;
	import core.states.game.GameState;
	import embed.EmbedAssets;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.shape.Circle;
	import org.osflash.signals.Signal;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * @author monsieurvinou
	 */
	public class Collectible extends Sensor
	{
		public var collected:Signal;
		public static var positionPossible:Array;
		protected var _isTransforming:Boolean = false;
		public var rotationFactor:Number = 0.01;
		
		
		public function Collectible() 
		{
			super("");
			collected = new Signal();
			beginContactCallEnabled = true;
			updateCallEnabled = true;
			if ( positionPossible == null ) initializePositions();
			
			var random:Number = Math.round(Math.random() * (positionPossible.length - 1));
			var position:Vec2 = positionPossible[random];
			x = position.x + 16;
			y = position.y + 16;
			
			positionPossible.splice(random, 1);
			
			_view = new Image( Texture.fromBitmap(new EmbedAssets.CollectibleView()));
		}
		
		protected function initializePositions():void
		{
			positionPossible = new Array();
			var state:GameState = _ce.state as GameState;
			var listPlatforms:Vector.<CitrusObject> = state.getObjectsByType(Platform);
			if ( listPlatforms && listPlatforms.length > 0 ) {
				for ( var i:int = 0; i < 25; i++ ) {
					for ( var j:int = 0; j < 20; j++ ) {
						var position:Vec2 = new Vec2(i * 32, j * 32);
						for each (var machin:Platform in listPlatforms ) {
						var isPossible:Boolean = true;
							if ( machin is PlatBW || machin is PlatRed || machin is Limit ) {
								if ( machin.body.contains(position) ) {
									isPossible = false;
									break;
								}
							}
						}
						if ( isPossible ) positionPossible.push(position);
					}
				}
			}
		}
		
		override protected function createShape():void
		{
			super.createShape();
			_body.shapes.clear();
			_body.shapes.add(new Circle(11, null, _material, new InteractionFilter(
				PhysicsCollisionCategories.Get("Level"),
				PhysicsCollisionCategories.GetNone(),
				PhysicsCollisionCategories.Get("Level"),
				PhysicsCollisionCategories.Get("GoodGuys")
			)));
			_body.shapes.at(0).sensorEnabled = true;
			
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
			if ( !_isTransforming ) {
				var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
				if ( collider is Hero ) {
					collected.dispatch();
					_isTransforming = true;
					TweenLite.to(_view, 2, { alpha: 0.4, onComplete: createBlock } );
					TweenLite.to(this, 1.3, { rotationFactor: 0.2 } );
					randomColor();
				}
			}
		}
		
		protected function randomColor():void
		{
			TweenLite.to(_view, 0.2, { hexColors: { color: Math.random() * 0xFFFFFF }, onComplete: randomColor } );
		}
		
		public function createBlock():void
		{
			var random:Number = Math.random();
			var block:Platform;
			if ( random < 0.2 ) { // RED BLOCK
				block = new PlatRed("", { x: x, y: y, width: 32, height: 32 })
			} else if ( random < 0.3 ) { // LIMIT
				block = new Limit("", { x: x, y: y, width: 32, height: 32 })
			} else if (random < 0.65 ) { // BLACK
				block = new PlatBW("", { x: x, y: y, width: 32, height: 32, state: "black" } )
			} else { // WHITE
				block = new PlatBW("", { x: x, y: y, width: 32, height: 32, state: "white" })
			}
			
			_ce.state.add(block);
			if ( block is PlatBW ) (_ce.state as GameState).listPlatforms.push(block);
			Starling.current.juggler.removeTweens(_view);
			this.kill = true;
		}
		
		override public function update(delta:Number):void
		{
			super.update(delta);
			_body.rotate(new Vec2(x,y), Math.PI * rotationFactor );
		}
	}

}