package AA {
	import org.agony2d.display.StateAA;
	import org.agony2d.events.AEvent;
	import org.agony2d.resource.FilesBundle;
	import org.agony2d.resource.ResMachine;
	import org.agony2d.resource.handlers.AtlasAA_BundleHandler;
	import org.agony2d.resource.handlers.FrameClip_BundleHandler;
	import org.agony2d.resource.handlers.TextureAA_BundleHandler;
	import org.agony2d.ui.skins.ButtonSkin;
	import org.agony2d.ui.skins.SkinManager;
	
public class Res_StateAA extends StateAA {
	
	override public function onEnter() : void {
		var AY:Vector.<String>;
		
		this.resA = new ResMachine("common/");
		
		AY = new <String>
			[
				"data/frameClip_A.xml"
			];
		this.resA.addBundle(new FilesBundle(AY), new FrameClip_BundleHandler);
		
		AY = new <String>
			[
				"temp/bg2.png",
				"temp/topBg.png",
				
				"temp/browser.png",
				"temp/calculator.png",
				"temp/camera.png",
				"temp/flashlight.png",
				"temp/folder.png",
				"temp/phone.png",
				"temp/theme.png",
				
				"temp/browser2.png",
				"temp/calculator2.png",
				"temp/camera2.png",
				"temp/flashlight2.png",
				"temp/folder2.png",
				"temp/phone2.png",
				"temp/theme2.png",
				
				"temp/browser_text.png",
				"temp/calculator_text.png",
				"temp/camera_text.png",
				"temp/flashlight_text.png",
				"temp/folder_text.png",
				"temp/phone_text.png",
				"temp/theme_text.png",
				"temp/topStatus.png",
				"temp/navigator.png",
				
				"temp/topBg_A.png",
				"temp/text_A.png",
				"temp/topRay.png",
				"temp/alertBg.png",
				
				"temp/text_determine.png",
				"temp/text_cancel.png",
				"ui/A/up.png",
				"ui/A/down.png"
			]
		this.resA.addBundle(new FilesBundle(AY), new TextureAA_BundleHandler(1.0, false, false));
		
		AY = new <String>
			[
				"temp/Sword.png",
				"temp/Shield.png",
				"temp/Skull Cross.png",
				"temp/Treasure Chest.png",
			];
		this.resA.addBundle(new FilesBundle(AY), new TextureAA_BundleHandler);
		
		AY = new <String>
			[
				"atlas/garbage.atlas"
			];
		this.resA.addBundle(new FilesBundle(AY), new AtlasAA_BundleHandler);
		
		AY = new <String>
			[
				"ui/A/up.png",
				"ui/A/down.png"
			];
		SkinManager.registerSkin("A", new ButtonSkin(AY, 0, 1, 1, 0));
		
		this.resA.addEventListener(AEvent.COMPLETE, onComplete);
	}
	
	public var resA:ResMachine;
	
	private function onComplete(e:AEvent):void {
		var AY:Array;
		var i:int;
		var l:int;
		
		this.resA.removeAllListeners();
		this.getFusion().kill();
		
		AY = this.getArg(0);
		l = AY.length;
		while (i < l) {
			this.getRoot().getView(AY[i++]).activate();
		}
	}
}
}