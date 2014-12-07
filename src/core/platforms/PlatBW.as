package core.platforms 
{
	import citrus.objects.platformer.nape.Platform;
	import citrus.physics.PhysicsCollisionCategories;
	import nape.dynamics.InteractionFilter;
	import starling.display.Quad;
	
	/**
	 * @author monsieurvinou
	 */
	public class PlatBW extends Platform
	{
		private var _state:String = "white";
		
		public function PlatBW(name:String, params:Object=null) 
		{
			super(name, params);
			updateView();
		}
		
		override protected function createFilter():void
		{
			super.createFilter();
			updateFilter();
		}
		
		public function change():void
		{
			if ( _state == "white" ) state = "black";
			else state = "white";
		}
		
		protected function updateView():void 
		{
			if ( _view == null && _view is Quad ) (_view as Quad).dispose();
			
			if ( _state == "black" ) _view = new Quad(_width, _height, 0x000000);
			else {
				_view = new Quad(_width, _height, 0xFFFFFF);
				_view.alpha = 0.3;
			}
		}
		
		protected function updateFilter():void
		{
			if ( _state == "black" ) {
				_body.setShapeFilters(
					new InteractionFilter(
						PhysicsCollisionCategories.Get("Level"), 
						PhysicsCollisionCategories.GetAll()
					) 
				);
			} else {
				_body.setShapeFilters(
					new InteractionFilter(
						PhysicsCollisionCategories.Get("WhiteLevel"), 
						PhysicsCollisionCategories.GetAllExcept("GoodGuys")
					) 
				);
			}
		}
		
		public function get state():String { return _state; }
		public function set state(value:String):void { 
			if ( value == "black" || value == "white" ) {
				_state = value; 
			} else _state = "white";
			
			updateView();
			updateFilter();
		}
	}

}