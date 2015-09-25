package AA
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	
	import flash.geom.Point;
	
	import org.agony2d.display.AnimeAA;
	import org.agony2d.display.DragFusionAA;
	import org.agony2d.display.FusionAA;
	import org.agony2d.display.ImageAA;
	import org.agony2d.display.StateAA;
	import org.agony2d.events.AEvent;
	import org.agony2d.events.ATouchEvent;
	import org.agony2d.input.Touch;
	import org.agony2d.utils.AMath;

	public class Delete_StateAA extends StateAA {
		
		override public function onEnter():void
		{
			var imgA:ImageAA;
			
			imgA = new ImageAA;
			imgA.textureId = "temp/bg.png";
			this.getFusion().addNode(imgA);
			
			this.____doInitTop();
			this.____doInitBottom();
			
		}
		
		
		private const _topTweenTime_B:Number = 0.15;
		private const _topTweenTime_A:Number = 0.3;
		private const g_dragDelayStartupTime:Number = 0.3;
		private const DRAG_OFFSET_Y:int = -70;
		private const PRESS_SCALE:Number = 0.9;
		private const _g_flyToGarbageTime:Number = 0.55;
		private const _pressIconScale:Number = 1.3;
		private const _pressIconAlpha:Number = 0.9;
		
		
		private const FLAG_O_A:int = 1; // O -> A
		private const FLAG_AB_O:int = 2; // A -> O
		private const FLAG_A_B:int = 3; // A -> B
		private const FLAG_B_A:int = 4; // B -> A
		
		private var HIGH_A:int; // 50
		private var HIGH_B:int; // 190
		private var HIGH_C:int; // 270
		
		
		private var _wasteImg:AnimeAA;
		private var _topFusion:FusionAA;
		private var _bottomFusion:FusionAA;
		private var _pressIcon:DragFusionAA;
		private var _currTouch:Touch;
		private var _dragging:Boolean;
		private var _readyToWaste:Boolean;
	
		
		private var _iconTextureList:Array = 
			[
				"temp/browser.png",
				"temp/calculator.png",
				"temp/phone.png",
				"temp/theme.png",
				"temp/flashlight.png",
				"temp/theme.png",
				"temp/camera.png",
				"temp/folder.png"
			]
		
		
		private function ____doInitTop() : void {
			var imgA:ImageAA;
			
			_topFusion = new FusionAA;
			this.getFusion().addNode(_topFusion);
			
			imgA = new ImageAA;
			imgA.textureId = "temp/topBg.png";
			_topFusion.addNode(imgA);
			HIGH_B = imgA.sourceHeight;
			HIGH_A = 50;
			HIGH_C = HIGH_B + 80;
			
			// template
			_wasteImg = new AnimeAA();
			_wasteImg.textureId = "atlas/garbage0";
			_wasteImg.pivotX = _wasteImg.sourceWidth / 2;
			_wasteImg.pivotY = _wasteImg.sourceHeight / 2;
			
			_wasteImg.x = this.getRoot().getAdapter().rootWidth / 2;
			_wasteImg.y = HIGH_B - 65;
			_topFusion.addNode(_wasteImg);
			
			_topFusion.y = -HIGH_B;
			
//			this.getRoot().getAdapter().getTouch().addEventListener(ATouchEvent.PRESS, function(e:ATouchEvent):void {
//				trace(e.touch.rootX, e.touch.rootY);
//			}, 10000);
		}
		
		private function ____doInitBottom() : void {
			var i:int;
			var l:int;
			var dragFusion:FusionAA;
			
			_bottomFusion = new FusionAA;
			this.getFusion().addNode(_bottomFusion);
			
			l = _iconTextureList.length;
			while(i < l){
				dragFusion = ____doCreateDragIcon(i);
				_bottomFusion.addNode(dragFusion);
				
				i++;
			}
		}
		
		////////////////////////////////////////////
		// Create
		////////////////////////////////////////////
		
		private function ____doCreateDragIcon( index:int ) : FusionAA {
			var dragFusion:DragFusionAA;
			var imgA:ImageAA;
			
			dragFusion = new DragFusionAA;
			dragFusion.touchMerged = true;
			dragFusion.userData = index;
			
			// template
			imgA = AAUtil.createScaleImg(_iconTextureList[index]);
			
			dragFusion.addNode(imgA);
			this.____doLayoutIcon(dragFusion, index);
			
			dragFusion.addEventListener(ATouchEvent.PRESS, onPressIcon);
			return dragFusion;
		}
		
		
		private const paddingW:int = 160;
		private function ____doLayoutIcon( dragFusion:FusionAA, index:int ) : void {
			var gapW:Number;
			
			gapW = (this.getRoot().getAdapter().rootWidth - paddingW * 2) / 3;
			dragFusion.x = (index % 4) * gapW + paddingW;
			dragFusion.y = int(index / 4) * 280 + 1100;
		}
		
		////////////////////////////////////////////
		// Event
		////////////////////////////////////////////
		
		private function onUnbindingIcon(e:ATouchEvent) : void {
			_pressIcon.removeEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
			
			_pressIcon.scaleX = 1.0;
			_pressIcon.scaleY = 1.0;
			TweenLite.killTweensOf(_pressIcon);
			_pressIcon = null;
			_currTouch = null;
			
			//			TweenLite.to(_pressIcon, DELAY_TIME, {scaleX:1, scaleY:1, ease:Linear.easeNone});
		}
		
		// 1. press
		private function onPressIcon(e:ATouchEvent):void {
			_currTouch = e.touch;
			_pressIcon = e.target as DragFusionAA;
			
			//trace(_pressIcon.userData, _pressIcon.globalToLocal(_currTouch.rootX, _currTouch.rootY));
			
			TweenLite.to(_pressIcon, g_dragDelayStartupTime, {scaleX:PRESS_SCALE, scaleY:PRESS_SCALE, onComplete:onStartDragIcon, ease:Linear.easeNone});
			
			_pressIcon.addEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
		}
		
		private function onStartDragIcon() : void {
			_pressIcon.removeEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
			
			_dragging = true;
			
			_pressIcon.scaleX = _pressIconScale;
			_pressIcon.scaleY = _pressIconScale;
			_pressIcon.alpha = _pressIconAlpha;
			
			_pressIcon.startDrag(_currTouch, null, 0, DRAG_OFFSET_Y, true);
			_currTouch.addEventListener(AEvent.CHANGE,   onMoveIcon);
			_currTouch.addEventListener(AEvent.COMPLETE, onReleaseIcon);
			_currTouch = null;
			
			this.doTweenGarbage(FLAG_O_A);
		}
		
		// 2. drag
		private function onMoveIcon(e:AEvent):void{
			var touch:Touch;
			
			touch = e.target as Touch;
//			Agony.getLog().simplify("{0}, {1}",touch.rootX, touch.rootY);
			if(_pressIcon.y <= HIGH_C && !_readyToWaste) {
				_readyToWaste = true;
				this.doTweenGarbage(FLAG_A_B);
			}
			else if(_pressIcon.y > HIGH_C && _readyToWaste) {
				_readyToWaste = false;
				this.doTweenGarbage(FLAG_B_A);
			}
		}
		
		// 3. release
		private function onReleaseIcon(e:AEvent) :void{
			var index:int;
			var touch:Touch;
			var controlX:Number;
			var controlY:Number;
			var rotation:Number;
			
			touch = e.target as Touch;
			
			if(_readyToWaste) {
				controlX = _wasteImg.x + (_pressIcon.x - _wasteImg.x) * 1 / 4;
				controlY = -150;
				rotation = _pressIcon.x - _wasteImg.x < 0 ? 540 : -540;
				
				this.getRoot().getAdapter().getTouch().touchEnabled = false;
				
				TweenMax.to(_pressIcon, _g_flyToGarbageTime, {scaleX:0.2, scaleY:0.2, alpha:0.2, rotation:rotation,
						bezier:[{x:controlX, y:controlY}, {x:_wasteImg.x, y:_wasteImg.y}], 
						 ease:Linear.easeNone, 
						 onComplete:function():void{
							 _pressIcon.kill();
							 _pressIcon = null;
							 
							 _wasteImg.getAnimation().start("atlas/garbage", "garbage.shake", 1, 
							 function():void{
							 	 
								 doTweenGarbage(FLAG_AB_O);
								 
								 
								 getRoot().getAdapter().getTouch().touchEnabled = true;
								 
							 });
							 
						 }});
			}
			else {
				index = int(_pressIcon.userData);
				_pressIcon.scaleX = 1.0;
				_pressIcon.scaleY = 1.0;
				_pressIcon.alpha = 1.0;
				this.____doLayoutIcon(_pressIcon, index);
				_pressIcon = null;
				
				this.doTweenGarbage(FLAG_AB_O);
			}
			
			_dragging = _readyToWaste = false;
			
//			Agony.getLog().simplify(touch.getHoveringNode());
		}
		
		////////////////////////////////////////////
		// Interaction
		////////////////////////////////////////////
		
		private function doTweenGarbage( tweenFlag:int ) : void {
			if(tweenFlag == FLAG_O_A){
				TweenLite.to(_topFusion, _topTweenTime_B, {y:-HIGH_A, ease:Linear.easeNone});
			}
			else if(tweenFlag == FLAG_AB_O){
				TweenLite.to(_topFusion, _topTweenTime_A, {y:-HIGH_B, ease:Linear.easeNone});
			}
			else if(tweenFlag == FLAG_A_B){
				TweenLite.to(_topFusion, _topTweenTime_B, {y:0, ease:Linear.easeNone, onComplete:function():void{
					_wasteImg.getAnimation().start("atlas/garbage", "garbage.open", 1);
					
				}});
			}
			else if(tweenFlag == FLAG_B_A){
				TweenLite.to(_topFusion, _topTweenTime_B, {y:-HIGH_A, ease:Linear.easeNone, onComplete:function():void{
					_wasteImg.getAnimation().start("atlas/garbage", "garbage.close", 1);
					
				}});
			}
		}
		
	}
}