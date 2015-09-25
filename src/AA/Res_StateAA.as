package AA {
	import org.agony2d.display.StateAA;
	import org.agony2d.events.AEvent;
	import org.agony2d.resource.FilesBundle;
	import org.agony2d.resource.ResMachine;
	import org.agony2d.resource.handlers.AtlasAA_BundleHandler;
	import org.agony2d.resource.handlers.FrameClip_BundleHandler;
	import org.agony2d.resource.handlers.TextureAA_BundleHandler;
	
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
				"temp/bg.png",
				"temp/topBg.png",
				
				"temp/browser.png",
				"temp/calculator.png",
				"temp/camera.png",
				"temp/flashlight.png",
				"temp/folder.png",
				"temp/phone.png",
				"temp/theme.png"
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