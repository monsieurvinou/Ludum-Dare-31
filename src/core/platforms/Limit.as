package core.platforms 
{
	import citrus.objects.platformer.nape.Platform;
	import starling.display.Quad;
	/**
	 * ...
	 * @author monsieurvinou
	 */
	public class Limit extends Platform
	{
		
		public function Limit(name:String, params:Object=null) 
		{
			super(name, params);
			_view = new Quad(_width, _height, 0x5555BB);
		}
		
	}

}