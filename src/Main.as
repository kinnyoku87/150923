package {
	import flash.display.Sprite;
	import flash.ui.Multitouch;
	
	import initializers.Initializer150923_A;
	
	import org.agony2d.Agony;
	import org.agony2d.core.DesktopPlatform;
	import org.agony2d.core.MobilePlatform;
	import org.agony2d.logging.FlashTextLogger;
	
	[SWF(width = "450", height = "800", backgroundColor = "0x0", frameRate = "60")]
public class Main extends Sprite {
	
	public function Main() {
		var logger:FlashTextLogger;
		
//			stage.addChild(new Stats(10, 300));

			logger = new FlashTextLogger(stage, true, 300, 330, 330, true);
			Agony.getLog().logger = logger;
//			logger.visible = true;

		if(Multitouch.maxTouchPoints == 0){
			Agony.startup(1080, 1920, new DesktopPlatform, stage, Initializer150923_A);
			//			Security.allowDomain("*");
		}
		else{
			Agony.startup(1080, 1920, new MobilePlatform(false), stage, Initializer150923_A);
		}
	}
}
}