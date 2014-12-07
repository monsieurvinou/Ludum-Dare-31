package core.states.game 
{
	import citrus.core.CitrusObject;
	import citrus.utils.objectmakers.ObjectMaker2D;
	import core.objects.Collectible;
	import core.platforms.Limit;
	import core.platforms.PlatBW;
	import core.platforms.PlatRed;
	import core.states.MainState;
	import embed.EmbedAssets;
	
	/**
	 * @author monsieurvinou
	 */
	public class GameState extends MainState
	{
		public var listPlatforms:Array;
		public var collect:Collectible;
		
		public function GameState() 
		{
			listPlatforms = new Array();
			var objects:Array = [PlatBW, PlatRed, Limit];
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
		}
		
		protected function addNewCollectible():void
		{
			var toCollect:Collectible = new Collectible();
			add(toCollect);
			toCollect.collected.add(addNewCollectible);
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
			super.update(delta);
			if ( _ce.input.justDid("switch") ) {
				inverse();
			}
		}
		
	}

}