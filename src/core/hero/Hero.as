package core.hero 
{
	import citrus.input.controllers.gamepad.controls.StickController;
	import citrus.input.controllers.gamepad.GamePadManager;
	import citrus.input.controllers.gamepad.maps.GamePadMap;
	import citrus.input.controllers.gamepad.maps.Xbox360GamepadMap;
	import citrus.objects.CitrusSprite;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.view.starlingview.AnimationSequence;
	import flash.geom.Rectangle;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import org.osflash.signals.Signal;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import embed.EmbedAssets;
	
	public class Hero extends NapePhysicsObject
	{
		public static const HERO:CbType = new CbType();	
		protected var _controlsEnabled:Boolean = true;
		
		[Inspectable(defaultValue="4")]
		public var acceleration:Number = 6;
		[Inspectable(defaultValue="70")]
		public var maxVelocity:Number = 70;
		[Inspectable(defaultValue="90")]
		public var jumpHeight:Number = 90;
		
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;

		public var onJump:Signal;
		public var onAnimationChange:Signal;

		protected var _groundContacts:Array = [];// Used to determine if he's on ground or not.
		protected var _onGround:Boolean = false;
		protected var _dynamicFriction:Number = 2;
		protected var _staticFriction:Number = 2;
		protected var _combinedGroundAngle:Number = 0;
		protected var _playerMovingHero:Boolean = false;
		protected var _angleStick:Number;
		
		public function Hero() 
		{
			super("player");
			
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			onJump = new Signal();
			onAnimationChange = new Signal();
			
			//var heroAnimationTexture:Texture = Texture.fromBitmap(new EmbedAssetsManager.HeroAnimationSprite());
			//var heroAnimationXml:XML = new XML(new EmbedAssetsManager.HeroAnimationXml());
			//var ta:TextureAtlas = new TextureAtlas(heroAnimationTexture, heroAnimationXml);
			//var animationSeq:AnimationSequence = new AnimationSequence(ta,["idle","jump","walk"],"idle",6);
			//_view = animationSeq;
			//(_view as AnimationSequence).pivotY += 6;
			
			this.group = 30;
		}
		
		override protected function createConstraint():void 
		{
			super.createConstraint();	
			_body.cbTypes.add(HERO);
		}
		
		override public function destroy():void 
		{
			onJump.removeAll();
			onAnimationChange.removeAll();
			super.destroy();
		}
		
		public function get controlsEnabled():Boolean { return _controlsEnabled; }
		public function set controlsEnabled(value:Boolean):void {
			_controlsEnabled = value;

			 if (!_controlsEnabled) {
				_material.dynamicFriction = _dynamicFriction;
				_material.staticFriction = _staticFriction;
			 }
		}
		
		override protected function createMaterial():void
		{
			super.createMaterial();
			_material.staticFriction = 0;
			_material.elasticity = 0;
		}
		
		override protected function createFilter():void 
		{	
			_body.setShapeFilters(
				new InteractionFilter(
					PhysicsCollisionCategories.Get("GoodGuys"), 
					PhysicsCollisionCategories.GetAll()
				)
			);
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.type = BodyType.DYNAMIC;
			_body.allowRotation = false;
		}
		
		override protected function createShape():void 
		{
			super.createShape();
			_body.shapes.clear();
			
			_body.shapes.add( new Polygon(Polygon.rect(-10, -15, 20, 20), _material) );
			_body.shapes.add( new Circle(10, new Vec2(0, 5), _material));
		}
		
		override public function update(timedelta:Number):void
		{
			super.update(timedelta);
			if ( _controlsEnabled ) {
				updateMovements();
				updateJumping();
				//updateFiring();
			}
			
			updateAnimation();
		}
		
		protected function updateMovements():void
		{
			// we get a reference to the actual velocity vector
			var velocity:Vec2 = _body.velocity;
			var moveKeyPressed:Boolean = false;
			var coefPad:Number = 1;
			
			if ( !_ce.input.isDoing("fire", inputChannel) ) {
				if ( _ce.input.isDoing("left", inputChannel) ) {
					coefPad = _ce.input.isDoing("left", inputChannel).value;
					if ( isNaN(coefPad) ) coefPad = 1;
					velocity.x -= acceleration * coefPad;
					moveKeyPressed = true;
				} else if ( _ce.input.isDoing("right", inputChannel) ) {
					coefPad = _ce.input.isDoing("right", inputChannel).value;
					if ( isNaN(coefPad) ) coefPad = 1;
					velocity.x += acceleration * coefPad;
					moveKeyPressed = true;
				}
			}
			
			(_view as AnimationSequence).setAnimFps(["walk"], [6*coefPad]);
			
			
			//If player just started moving the hero this tick.
			if (moveKeyPressed && !_playerMovingHero)
			{
				_playerMovingHero = true;
				_material.dynamicFriction = 0; //Take away friction so he can accelerate.
				_material.staticFriction = 0;
			}
			//Player just stopped moving the hero this tick.
			else if (!moveKeyPressed && _playerMovingHero)
			{
				_playerMovingHero = false;
				_material.dynamicFriction = _dynamicFriction; //Add friction so that he stops running
				_material.staticFriction = _staticFriction;
			}
			
			if ( velocity.x < -acceleration ) _inverted = true;
			else if ( velocity.x > acceleration ) _inverted = false;
			
			//Cap velocities
			if (velocity.x > (maxVelocity * coefPad)) velocity.x = maxVelocity * coefPad;
			else if (velocity.x < ( -maxVelocity * coefPad)) velocity.x = -maxVelocity * coefPad;
		}
		
		protected function updateJumping():void
		{
			var velocity:Vec2 = _body.velocity;
			if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ce.input.isDoing("fire", inputChannel)) {
				velocity.y = -jumpHeight;
				onJump.dispatch();
				_onGround = false; // also removed in the handleEndContact. Useful here if permanent contact e.g. box on hero.
			}
		}
		
		protected function updateFiring():void
		{
			
		}
		
		protected function updateAnimation():void {
			
			var prevAnimation:String = _animation;
			
			if (!_onGround) _animation = "jump";
			else if (_playerMovingHero) _animation = "walk";
			else _animation = "idle";
			
			// Signal management
			if (prevAnimation != _animation) onAnimationChange.dispatch();
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void 
		{
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {	
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				if ((collisionAngle > 45 && collisionAngle < 135) || collisionAngle == 90)
				{
					if (collisionAngle > 1 || collisionAngle < -1) {
						//we don't want the Hero to be set up as onGround if it touches a cloud.
						if (collider is Platform && (collider as Platform).oneWay && collisionAngle == -90) return;
						
						_groundContacts.push(collider.body);
						_onGround = true;
					}
				}
			}
		}
		
		override public function handleEndContact(callback:InteractionCallback):void 
		{	
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);	
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0) _onGround = false;
			}
		}
		
	}

}