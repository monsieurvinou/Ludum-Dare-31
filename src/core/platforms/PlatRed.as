package core.platforms 
{
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.nape.NapeUtils;
	import core.hero.Hero;
	import nape.callbacks.InteractionCallback;
	import starling.display.Quad;
	
	/**
	 * @author monsieurvinou
	 */
	public class PlatRed extends Platform
	{
		public function PlatRed(name:String, params:Object=null) 
		{
			super(name, params);
			_view = new Quad(_width, _height, 0xBB6464);
			beginContactCallEnabled = true;
		}
		
		public function handleBeginCallback(callback:InteractionCallback):void
		{
			super.handleBeginContact(callback);
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			if ( collider is Hero ) {
				// (collider as Hero).die();
			}
		}
	}
}