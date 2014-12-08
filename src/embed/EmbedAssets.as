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
		
		// UI
		[Embed(source = "assets/timerPlusFive.png")]
		public static var TimerPlusFive:Class;
		[Embed(source = "assets/howtoplay.png")]
		public static var HowToPlay:Class;
		
		// SONGS
		[Embed(source = "assets/main.mp3")]
		public static var SongMain:Class;
		[Embed(source = "assets/muffled.mp3")]
		public static var SongMuffled:Class;
		
		public function EmbedAssets() { throw("Cannot instanciate this class"); }
	}

}