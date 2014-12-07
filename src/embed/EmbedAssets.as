package embed 
{
	/**
	 * ...
	 * @author monsieurvinou
	 */
	public class EmbedAssets 
	{	
		// MAIN LEVEL
		[Embed(source = "assets/level.tmx", mimeType = "application/octet-stream")]
		public static var LevelXML:Class;
		
		// COLLECTIBLE
		[Embed(source = "assets/collectible.png")]
		public static var CollectibleView:Class;
		
		// HERO SPRITESHEET
		[Embed(source="assets/hero.xml", mimeType = "application/octet-stream")]
		public static var HeroSpriteSheetXML:Class;
		[Embed(source = "assets/hero.png")]
		public static var HeroSpriteSheetGraphics:Class;
		
		public function EmbedAssets() { throw("Cannot instanciate this class"); }
	}

}