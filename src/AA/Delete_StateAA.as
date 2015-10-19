package AA
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Linear;
	
	import flash.geom.Point;
	
	import org.agony2d.Agony;
	import org.agony2d.display.AnimeAA;
	import org.agony2d.display.ButtonAA;
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
		
		override public function onExit() : void {
			TweenMax.killAll();
		}
		
		
		private const _topTweenTime_B:Number = 0.15;
		private const _topTweenTime_A:Number = 0.3;
		private const g_dragDelayStartupTime:Number = 0.3;
		private const DRAG_OFFSET_Y:int = -70;
		private const PRESS_SCALE:Number = 0.9;
		private const _g_flyToGarbageTime:Number = 0.55;
		private const _pressIconScale:Number = 1.35;
		private const _revertTime:Number = 0.55;
		private const _readyToDeleteTweenTime:Number = 0.3;
		
		private const FLAG_O_A:int = 1; // O -> A
		private const FLAG_BACK_TO_O:int = 2; // A -> O
		private const FLAG_A_B:int = 3; // A -> B
		private const FLAG_B_A:int = 4; // B -> A
		private const FLAG_B_C:int = 5; // B -> C
		
		private var garbage_offsetY_O:int; // -190
		private var garbage_offsetY_A:int; // -50
		private var garbage_offsetY_B:int; // 0
		
		private var topBg_offsetY_O:int; // -topBg sourceHeight
		private var topBg_offsetY_A:int; // -topBg sourceHeight+110
		private var topBg_offsetY_B:int; // -topBg sourceHeight+190
		private var topBg_offsetY_C:int; // 0
		
		private var coordY_for_delete:int; // 270
		
		
		private var _garbageImg:AnimeAA;
		private var _topRay:ImageAA;
		private var _topFusion_bg:FusionAA; // 背景
		private var _topFusion_garbage:FusionAA; // garbage
		private var _bottomFusion:FusionAA;
		private var _pressIcon:DragFusionAA;
		private var _currTouch:Touch;
		private var _dragging:Boolean;
		private var _readyToWaste:Boolean;
		
	
		
		private var _iconTextureList:Array = 
			[
				"browser",
				"calculator",
				"phone",
				"theme",
				"flashlight",
				"theme",
				"camera",
				"folder"
			]
		
		
		private function ____doInitTop() : void {
			var imgA:ImageAA;
			
			// top bg
			_topFusion_bg = new FusionAA;
			this.getFusion().addNode(_topFusion_bg);
			
			imgA = new ImageAA;
			imgA.textureId = "temp/topBg_A.png";
			_topFusion_bg.addNode(imgA);
			
			//==================================================
			
			garbage_offsetY_O = -190;
			garbage_offsetY_A = -50; //imgA.sourceHeight;
			
			topBg_offsetY_O = - imgA.sourceHeight;
			topBg_offsetY_A = 140 - imgA.sourceHeight;
			topBg_offsetY_B = 190 - imgA.sourceHeight;
			
			coordY_for_delete = 270;
			
			//==================================================
			
			// top garbage
			_topFusion_garbage = new FusionAA;
			this.getFusion().addNode(_topFusion_garbage);
			
			_topRay = new AnimeAA();
			_topRay.textureId = "temp/topRay.png";
			_topFusion_garbage.addNode(_topRay);
			
			_garbageImg = new AnimeAA();
			_garbageImg.textureId = "atlas/garbage0";
			_garbageImg.pivotX = _garbageImg.sourceWidth / 2;
			_garbageImg.pivotY = _garbageImg.sourceHeight / 2;
			
			_garbageImg.x = this.getRoot().getAdapter().rootWidth / 2;
			_garbageImg.y = 190 - 65;
			_topFusion_garbage.addNode(_garbageImg);
			
			_topFusion_bg.y = topBg_offsetY_O;
			_topFusion_garbage.y = garbage_offsetY_O;
			
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
			var iconName:String;
			
			dragFusion = new DragFusionAA;
			dragFusion.touchMerged = true;
			dragFusion.userData = index;
			
			// template
			iconName = _iconTextureList[index];
			imgA = AAUtil.createScaleImg(iconName);
			
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
			
			TweenLite.to(_pressIcon, g_dragDelayStartupTime, {scaleX:PRESS_SCALE, scaleY:PRESS_SCALE, onComplete:onStartDragIcon, ease:Linear.easeNone});
			
			_pressIcon.addEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
		}
		
		private function onStartDragIcon() : void {
			_pressIcon.removeEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
			
			_dragging = true;
			
			_pressIcon.scaleX = _pressIconScale;
			_pressIcon.scaleY = _pressIconScale;
			//_pressIcon.alpha = _pressIconAlpha;
			
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
			if(_pressIcon.y <= coordY_for_delete && !_readyToWaste) {
				_readyToWaste = true;
				this.doTweenGarbage(FLAG_A_B);
				
				this.doModifyIconTexture(_pressIcon, false);
			}
			else if(_pressIcon.y > coordY_for_delete && _readyToWaste) {
				_readyToWaste = false;
				this.doTweenGarbage(FLAG_B_A);
				
				this.doModifyIconTexture(_pressIcon, true);
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
				this.doTweenGarbage(FLAG_B_C);
//				doCastToGarbage();
			}
			// 恢复原状
			else {
				this.doRevertIcon();
				this.doTweenGarbage(FLAG_BACK_TO_O);
			}
			
			_dragging = _readyToWaste = false;
			
//			Agony.getLog().simplify(touch.getHoveringNode());
		}
		
		private function doCastToGarbage() : void {
			var index:int;
			var touch:Touch;
			var controlX:Number;
			var controlY:Number;
			var rotation:Number;
			
			controlX = _garbageImg.x + (_pressIcon.x - _garbageImg.x) * 1 / 4;
			controlY = -150;
			rotation = _pressIcon.x - _garbageImg.x < 0 ? 540 : -540;
			
			this.getRoot().getAdapter().getTouch().touchEnabled = false;
			
			TweenMax.to(_pressIcon, _g_flyToGarbageTime, {scaleX:0.2, scaleY:0.2, alpha:0.2, rotation:rotation,
				bezier:[{x:controlX, y:controlY}, {x:_garbageImg.x, y:_garbageImg.y}], 
				ease:Linear.easeNone, 
				onComplete:function():void{
					_pressIcon.kill();
					_pressIcon = null;
					
					_garbageImg.getAnimation().start("atlas/garbage", "garbage.shake", 1, 
						function():void{
							
							doTweenGarbage(FLAG_BACK_TO_O);
							
							
							getRoot().getAdapter().getTouch().touchEnabled = true;
							
						});
					
				}});
		}
		
		private function doRevertIcon() : void {
			var index:int;
			var gapW:Number;
			
			index = int(_pressIcon.userData);
			_pressIcon.scaleX = 1.0;
			_pressIcon.scaleY = 1.0;
			this.doModifyIconTexture(_pressIcon, true);
			
			gapW = (this.getRoot().getAdapter().rootWidth - paddingW * 2) / 3;
			TweenLite.to(_pressIcon, _revertTime, 
				{x:(index % 4) * gapW + paddingW, 
				y:int(index / 4) * 280 + 1100,
				ease:Cubic.easeOut});
			_pressIcon = null;
		}
		
		private function doModifyIconTexture( dragFusion:DragFusionAA, normal:Boolean ) : void {
			var index:int;
			var imgA:ImageAA;
			var iconName:String;
			
			index = int(_pressIcon.userData);
			imgA = dragFusion.getNodeAt(0) as ImageAA;
			iconName = normal ? _iconTextureList[index] : _iconTextureList[index] + "2";
			imgA.textureId = "temp/" + iconName + ".png";
		}
		
		////////////////////////////////////////////
		// Interaction
		////////////////////////////////////////////
		
		private var alertFusion:FusionAA;
		private var alertBg:ImageAA;
		private var text_A:ImageAA;
		private var _btnDetermine:ButtonAA;
		private var _btnCancel:ButtonAA;
		private const BTN_GAP_X:int = 285;
		private const BTN_COORD_Y:int = 385;
		
		private function doTweenGarbage( tweenFlag:int ) : void {
			var img_A:ImageAA;
			
			if(tweenFlag == FLAG_O_A){
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_A,   ease:Linear.easeNone});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_A, ease:Linear.easeNone});
			}
			else if(tweenFlag == FLAG_BACK_TO_O){
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_O,   ease:Linear.easeNone});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_O, ease:Linear.easeNone});
				if(alertFusion){
					alertFusion.kill();
					alertFusion = null;
				}
			}
			else if(tweenFlag == FLAG_A_B){
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_B,   ease:Linear.easeNone });
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_B, ease:Linear.easeNone, onComplete:function():void{
					_garbageImg.getAnimation().start("atlas/garbage", "garbage.open", 1);
				}});
			}
			else if(tweenFlag == FLAG_B_A){
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_A,   ease:Linear.easeNone});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_A, ease:Linear.easeNone, onComplete:function():void{
					_garbageImg.getAnimation().start("atlas/garbage", "garbage.close", 1);
				}});
			}
			else if(tweenFlag == FLAG_B_C){
				TweenLite.to(_topFusion_bg,      _readyToDeleteTweenTime, {y:topBg_offsetY_C,   ease:Linear.easeNone});
				TweenLite.to(_pressIcon,         _readyToDeleteTweenTime, {x:200, y:260, ease:Cubic.easeOut});
				
				alertBg = new ImageAA;
				alertBg.textureId = "temp/alertBg.png";
				this.getFusion().addNode(alertBg);
				TweenLite.from(alertBg,         _readyToDeleteTweenTime, {alpha:0, ease:Linear.easeNone, onComplete:function():void{
					alertFusion = new FusionAA;
					getFusion().addNode(alertFusion);
					
					text_A = new ImageAA;
					text_A.textureId = "temp/text_A.png";
					text_A.x = (getRoot().getAdapter().rootWidth - text_A.sourceWidth) / 2 + 100;
					text_A.y = 210;
					alertFusion.addNode(text_A);
					
					_btnCancel = new ButtonAA;
					_btnCancel.skinId = "A";
					_btnCancel.pivotX = _btnCancel.getBackground().sourceWidth / 2;
					_btnCancel.x = BTN_GAP_X;
					_btnCancel.y = BTN_COORD_Y;
					alertFusion.addNode(_btnCancel);
					
					img_A = new ImageAA;
					img_A.textureId = "temp/text_cancel.png";
					_btnCancel.addNode(img_A);
					
					_btnDetermine = new ButtonAA;
					_btnDetermine.skinId = "A";
					_btnDetermine.pivotX = _btnDetermine.getBackground().sourceWidth / 2;
					_btnDetermine.x = getRoot().getAdapter().rootWidth - BTN_GAP_X;
					_btnDetermine.y = BTN_COORD_Y;
					alertFusion.addNode(_btnDetermine);
					
					img_A = new ImageAA;
					img_A.textureId = "temp/text_determine.png";
					_btnDetermine.addNode(img_A);
					
					_btnCancel.addEventListener(ATouchEvent.CLICK, onCancel);
					_btnDetermine.addEventListener(ATouchEvent.CLICK,  onDetermine);
				}});
				
			}
		}
		
		private function onCancel(e:ATouchEvent):void{
			TweenLite.to(alertBg, _readyToDeleteTweenTime, {alpha:0, ease:Linear.easeNone, onComplete:function():void{
				alertBg.kill();
			}})
			
			alertFusion.touchable = false;
			
			this.doRevertIcon();
			this.doTweenGarbage(FLAG_BACK_TO_O);
		}
		
		private function onDetermine(e:ATouchEvent):void{
			alertBg.kill();
			alertFusion.touchable = false;
			
			this.doCastToGarbage();
		}
		
	}
}