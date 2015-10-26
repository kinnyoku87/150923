package initializers
{
	import flash.display.Stage;
	
	import AA.Delete_StateAA;
	import AA.Res_StateAA;
	
	import org.agony2d.Agony;
	import org.agony2d.core.Adapter;
	import org.agony2d.core.IInitializer;
	import org.agony2d.display.AACore;
	import org.agony2d.display.RootAA;
	import org.agony2d.events.AEvent;
	import org.agony2d.events.ATouchEvent;
	import org.agony2d.input.TouchType;
	import org.agony2d.resource.ResMachine;
	import org.agony2d.resource.converters.AtlasAssetConvert;
	import org.agony2d.resource.converters.SwfClassAssetConverter;
	
	public class Initializer150923_A implements IInitializer {
		
		private var _adapter:Adapter;
		private var _rootAA:RootAA;
		
		public function onInit( stage:Stage ) : void {
			//stage.quality = StageQuality.LOW;
			//stage.quality = StageQuality.MEDIUM
			//stage.quality = StageQuality.HIGH;
			
			this._adapter = Agony.createAdapter(stage, false);
//			this._adapter.getTouch().velocityEnabled = true;
			this._adapter.getTouch().touchType = TouchType.SINGLE;
			
			ResMachine.activate(SwfClassAssetConverter);
			ResMachine.activate(AtlasAssetConvert);
			
			AACore.registerView("res",    Res_StateAA);
			AACore.registerView("delete", Delete_StateAA);
			
			_rootAA = AACore.createRoot(this._adapter, 0x0, true);
			_rootAA.addEventListener(AEvent.START, onStart);
		}
		
		private function onStart(e:AEvent):void {	
			_rootAA.removeEventListener(AEvent.START, onStart);
			
			// 第一次开启delete状态AA，存在缓动bug..!!第二次开启bug自动消失..
			_rootAA.getView("res").activate([["delete", "delete"]]);
			
			_rootAA.getNode().doubleClickEnabled = true;
			_rootAA.getNode().addEventListener(ATouchEvent.DOUBLE_CLICK, function(e:ATouchEvent):void{
				_rootAA.getView("delete").activate();
			});
		}
	}
}