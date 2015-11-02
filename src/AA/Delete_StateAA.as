package AA
{
	import com.greensock.OverwriteManager;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Sine;
	
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.agony2d.display.AnimeAA;
	import org.agony2d.display.ButtonAA;
	import org.agony2d.display.DragFusionAA;
	import org.agony2d.display.FusionAA;
	import org.agony2d.display.ImageAA;
	import org.agony2d.display.StateAA;
	import org.agony2d.events.AEvent;
	import org.agony2d.events.ATouchEvent;
	import org.agony2d.input.Touch;
	import org.agony2d.utils.AColor;

	public class Delete_StateAA extends StateAA {
		
		override public function onEnter():void
		{
			var imgA:ImageAA;
			
			imgA = new ImageAA;
			imgA.textureId = "temp/bg2.png";
			this.getFusion().addNode(imgA);
			
			this.____doInitBottom();
			this.____doInitTop();
			
			OverwriteManager.mode = 1;
			
			
//			Agony.getTick().timeScale = 0.33;
		}
		
		override public function onExit() : void {
			TweenMax.killAll();
		}
		
		
		private const _topTweenTime_B:Number = 0.35;
		private const _garbageTime_A:Number = 0.2;
		private const _topTweenTime_O:Number = 0.45;
		private const g_dragDelayStartupTime:Number = 0.3;
		private const DRAG_OFFSET_Y:int = -70;
		private const PRESS_SCALE:Number = 0.9;
		private const _g_flyToGarbageTime:Number = 0.55;
		private const _pressIconScale:Number = 1.35;;
		private const _revertTime:Number = 0.6;
		private const _readyToDeleteTweenTime:Number = 0.3;
		private const _readyToDeleteTweenTime2:Number = 0.25;
		
		private const FLAG_O_A:int = 1; // O -> A
		private const FLAG_BACK_TO_O:int = 2; // A -> O
		private const FLAG_A_B:int = 3; // A -> B
		private const FLAG_B_A:int = 4; // B -> A
		private const FLAG_B_C:int = 5; // B -> C
		
		private var topStatus_offsetY_A:int;
		
		private var garbage_offsetY_O:int; // -190
		private var garbage_offsetY_A:int; // -50
		private var garbage_offsetY_B:int; // 0
		
		private var topBg_offsetY_O:int; // -topBg sourceHeight
		private var topBg_offsetY_A:int; // -topBg sourceHeight+110
		private var topBg_offsetY_B:int; // -topBg sourceHeight+190
		private var topBg_offsetY_C:int; // 0
		
		private var bottom_offsetY_A:int; // 0
		private var bottom_offsetY_B:int; // 
		private var bottom_offsetY_C:int; // 
		
		private var coordY_for_delete:int; // 270
		
		
		private var _topStatus:ImageAA;
		private var _garbageImg:AnimeAA;
		private var _topRay:ImageAA;
		private var _topFusion_bg:FusionAA; // 背景
		private var _topFusion_garbage:FusionAA; // garbage
		private var _bottomFusion:FusionAA;
		private var _pressIcon:DragFusionAA;
		private var _currTouch:Touch;
		private var _dragging:Boolean;
		private var _readyToWaste:Boolean;
		
		
		private var _numIcons:int;
		private var _iconTextureList:Array = 
			[
				"browser",
				"calculator",
				"phone",
				"theme",
				"flashlight",
				"theme",
				"camera",
				"folder",
				
				"browser",
				"calculator",
				"phone",
				"theme",
				"flashlight",
				"theme",
				"camera",
				"folder",
				
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
			
			// top status
			_topStatus = new ImageAA;
			_topStatus.textureId = "temp/topStatus.png";
			this.getFusion().addNode(_topStatus);
			topStatus_offsetY_A = -_topStatus.sourceHeight;
			
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
			
			bottom_offsetY_B = -garbage_offsetY_A + 25;
			bottom_offsetY_C = bottom_offsetY_B-topBg_offsetY_B;
			
			coordY_for_delete = 270;
			
			//==================================================
			
			// top garbage
			_topFusion_garbage = new FusionAA;
			this.getFusion().addNode(_topFusion_garbage);
			
			_topRay = new AnimeAA();
			_topRay.textureId = "temp/topRay.png";
			_topFusion_garbage.addNode(_topRay);
			
			_garbageImg = new AnimeAA();
			_garbageImg.textureId = "atlas/garbageA0";
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
			var img_A:ImageAA;
			
			_bottomFusion = new FusionAA;
			this.getFusion().addNode(_bottomFusion);
			
			// navigator
			img_A = new ImageAA;
			img_A.textureId = "temp/navigator.png";
			_bottomFusion.addNode(img_A);
			img_A.x = (this.getRoot().getAdapter().rootWidth - img_A.sourceWidth) / 2;
			img_A.y = 1580;
			
			
			_numIcons = _iconTextureList.length;
			while(i < _numIcons){
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
			var AY:Array;
			
			dragFusion = new DragFusionAA;
			dragFusion.touchMerged = true;
			dragFusion.userData = AY = [index];
			
			iconName = _iconTextureList[index];
			
			imgA = AAUtil.createScaleImg(iconName);
			dragFusion.addNode(imgA);
			
			imgA = AAUtil.createScaleImg(iconName + "_text");
			dragFusion.addNode(imgA);
			imgA.y = 110;
			
			this.____doLayoutIcon(dragFusion, index);
			AY[1] = dragFusion.x = cachePoint.x;
			AY[2] = dragFusion.y = cachePoint.y;
			
			dragFusion.addEventListener(ATouchEvent.PRESS, onPressIcon);
			return dragFusion;
		}
		
		
		private const paddingW:int = 150;
		private var cachePoint:Point = new Point;
		private function ____doLayoutIcon( dragFusion:FusionAA, index:int ) : void {
			var gapW:Number;
			
			if(index < _numIcons - 4) {
				gapW = (this.getRoot().getAdapter().rootWidth - paddingW * 2) / 3;
				cachePoint.x = (index % 4) * gapW + paddingW;
				cachePoint.y = int(index / 4) * 270 + 260;
			}
			// 最后四个
			else {
				gapW = (this.getRoot().getAdapter().rootWidth - paddingW * 2) / 3;
				cachePoint.x = (index % 4) * gapW + paddingW;
				cachePoint.y = 1750;
			}
			
		}
		
		
		
		
		
		
		////////////////////////////////////////////
		////////////////////////////////////////////
		////////////////////////////////////////////
		////////////////////////////////////////////
		// Event
		////////////////////////////////////////////
		////////////////////////////////////////////
		////////////////////////////////////////////
		////////////////////////////////////////////
		
		private function onUnbindingIcon(e:ATouchEvent) : void {
//			Agony.getLog().simplify("onUnbindingIcon");
			
			_pressIcon.removeEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
			
			// 图标
			(_pressIcon.getNodeAt(0) as ImageAA).color = null;
			
//			_pressIcon.scaleX = 1.0;
//			_pressIcon.scaleY = 1.0;
			TweenLite.killTweensOf(_pressIcon);
			
			TweenLite.to(_pressIcon, g_dragDelayStartupTime, {scaleX:1, scaleY:1, ease:Linear.easeNone});
			_pressIcon = null;
			_currTouch = null;
			
		}
		
		// 1. press
		private function onPressIcon(e:ATouchEvent):void {
//			Agony.getLog().simplify("onPressIcon");
			
			_currTouch = e.touch;
			_pressIcon = e.target as DragFusionAA;
			
			// 图标
			(_pressIcon.getNodeAt(0) as ImageAA).color = new AColor(0xAAAAAA);
			
			TweenLite.to(_pressIcon, g_dragDelayStartupTime, {scaleX:PRESS_SCALE, scaleY:PRESS_SCALE, onComplete:onStartDragIcon, ease:Cubic.easeOut});
			
			_pressIcon.addEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
		}
		
		private function onStartDragIcon() : void {
//			Agony.getLog().simplify("onStartDragIcon");
			
			_pressIcon.removeEventListener(ATouchEvent.UNBINDING, onUnbindingIcon);
			
			// 图标
			(_pressIcon.getNodeAt(0) as ImageAA).color = null;
			
			_pressIcon.touchable = false;
			_dragging = true;
			
			TweenLite.to(_pressIcon, g_dragDelayStartupTime, {scaleX:_pressIconScale, scaleY:_pressIconScale, ease:Back.easeOut});
			
			_pressIcon.startDrag(_currTouch, null, 0, DRAG_OFFSET_Y, true);
			_currTouch.addEventListener(AEvent.CHANGE,   onMoveIcon);
			_currTouch.addEventListener(AEvent.COMPLETE, onReleaseIcon);
			_currTouch = null;
			
			// 更换容器
			this.getFusion().addNode(_pressIcon);
			
			// 隐藏文本
			_pressIcon.getNodeAt(1).visible = false;
			
//			this.doTweenGarbage(FLAG_O_A);
			if(_pressIcon.y <= coordY_for_delete) {
				_readyToWaste = true;
				this.doTweenGarbage(FLAG_A_B);
				
				this.doModifyIconTexture(_pressIcon, false);
			}
			else if(_pressIcon.y > coordY_for_delete) {
				_readyToWaste = false;
//				this.doTweenGarbage(FLAG_B_A);
				this.doTweenGarbage(FLAG_O_A);
				
				this.doModifyIconTexture(_pressIcon, true);
			}
		}
		
		// 2. drag
		private function onMoveIcon(e:AEvent):void{
			var touch:Touch;
			
			touch = e.target as Touch;
			

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
				this.doRevertIcon(false);
				this.doTweenGarbage(FLAG_BACK_TO_O);
//				_garbageImg.getAnimation().start("atlas/garbageA", "garbage.close", 1);
				
			}
			
			_dragging = _readyToWaste = false;
			
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
			
//			trace(_garbageImg.y);
//			TweenLite.to(_pressIcon, _g_flyToGarbageTime, {alpha:0.2, ease:Linear.easeNone });
			TweenMax.to(_pressIcon,  _g_flyToGarbageTime, {alpha:0.3, scaleX:0.2, scaleY:0.2, rotation:rotation,
				bezier:[{x:controlX, y:controlY}, {x:_garbageImg.x, y:_garbageImg.y - 5}], 
				ease:Sine.easeOut, 
				onComplete:function():void{
					_pressIcon.kill();
					_pressIcon = null;
					
					_garbageImg.getAnimation().start("atlas/garbageA", "garbage.shake", 1, 
						function():void{
							TweenLite.to(_alertBg, _readyToDeleteTweenTime, {alpha:0, ease:Linear.easeOut, onComplete:function():void{
								_alertBg.kill();
							}})
							
							doTweenGarbage(FLAG_BACK_TO_O);
							
//							TweenLite.to(_bottomFusion, _topTweenTime_B, {alpha:1.0, ease:Linear.easeOut});
							TweenLite.to(_bottomFusion, _topTweenTime_B, {alpha:1.0, y:bottom_offsetY_A, ease:Cubic.easeOut});
							
							getRoot().getAdapter().getTouch().touchEnabled = true;
							
						});
					
				}});
		}
		
		private function doRevertIcon( forCancelToCast:Boolean ) : void {
			var index:int;
			var gapW:Number;
			var AY:Array;
			
			_pressIcon.touchable = true;
			
			AY = _pressIcon.userData as Array;
			index = int(AY[0]);
//			_pressIcon.scaleX = 1.0;
//			_pressIcon.scaleY = 1.0;
			this.doModifyIconTexture(_pressIcon, true);
			
			// 更换容器
			_bottomFusion.addNode(_pressIcon);
			if(forCancelToCast){
				_pressIcon.y -= bottom_offsetY_C;
			}
			
			// 重现文本
			_pressIcon.getNodeAt(1).visible = true;
			
			TweenLite.to(_pressIcon, _revertTime, 
				{x:AY[1], 
				y:AY[2],
				scaleX:1.0,
				scaleY:1.0,
				ease:Cubic.easeOut});
			
			_pressIcon = null;
		}
		
		private function doModifyIconTexture( dragFusion:DragFusionAA, normal:Boolean ) : void {
			var index:int;
			var imgA:ImageAA;
			var iconName:String;
			
			index = int(_pressIcon.userData[0]);
			imgA = dragFusion.getNodeAt(0) as ImageAA;
			iconName = normal ? _iconTextureList[index] : _iconTextureList[index] + "2";
			imgA.textureId = "temp/" + iconName + ".png";
		}
		
		////////////////////////////////////////////
		// Interaction
		////////////////////////////////////////////
		
		private var alertFusion:FusionAA;
		private var _alertBg:ImageAA;
		private var text_A:ImageAA;
		private var _btnDetermine:ButtonAA;
		private var _btnCancel:ButtonAA;
		private const BTN_GAP_X:int = 305;
		private const BTN_COORD_Y:int = 385;
		private var _garbageDelayID:int;
		
		private function doTweenGarbage( tweenFlag:int ) : void {
			var img_A:ImageAA;
			
			if(tweenFlag == FLAG_O_A){
				TweenLite.to(_topStatus,         _topTweenTime_B, {y:topStatus_offsetY_A, ease:Cubic.easeOut});
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_A,     ease:Cubic.easeOut});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_A,   ease:Cubic.easeOut});
				
			}
			else if(tweenFlag == FLAG_BACK_TO_O){
				TweenLite.to(_topStatus,         _topTweenTime_O, {y:0,                 ease:Cubic.easeOut, delay:_topTweenTime_B});
				TweenLite.to(_topFusion_bg,      _topTweenTime_O, {y:topBg_offsetY_O,   ease:Cubic.easeOut});
				
//				TweenLite.to(_bottomFusion,      _topTweenTime_O, {alpha:1.0,           ease:Linear.easeOut});
				TweenLite.to(_bottomFusion,      _topTweenTime_O, {alpha:1.0, y:bottom_offsetY_A,  ease:Cubic.easeOut });
				TweenLite.to(_topFusion_garbage, _topTweenTime_O, {y:garbage_offsetY_O, ease:Cubic.easeOut});
				_garbageImg.getAnimation().start("atlas/garbageA", "garbage.close", 1);
				if(alertFusion){
					alertFusion.kill();
					alertFusion = null;
				}
			}
			else if(tweenFlag == FLAG_A_B){
//				Agony.getLog().simplify("FLAG_A_B");
				
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_B,   ease:Cubic.easeOut});
				TweenLite.to(_bottomFusion,      _topTweenTime_B, {y:bottom_offsetY_B,  ease:Cubic.easeOut});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_B, ease:Cubic.easeOut})
				if(_garbageDelayID >= 0){
					clearTimeout(_garbageDelayID);
				}
				_garbageDelayID = setTimeout(function():void{
					_garbageImg.getAnimation().start("atlas/garbageA", "garbage.open", 1);
					_garbageDelayID = -1;
				}, _garbageTime_A * 1000);
			}
			else if(tweenFlag == FLAG_B_A){
//				Agony.getLog().simplify("FLAG_B_A");
				
				TweenLite.to(_topFusion_bg,      _topTweenTime_B, {y:topBg_offsetY_A,   ease:Cubic.easeOut});
				TweenLite.to(_bottomFusion,      _topTweenTime_B, {y:bottom_offsetY_A,  ease:Cubic.easeOut});
				TweenLite.to(_topFusion_garbage, _topTweenTime_B, {y:garbage_offsetY_A, ease:Cubic.easeOut});
				if(_garbageDelayID >= 0){
					clearTimeout(_garbageDelayID);
				}
				_garbageDelayID = setTimeout(function():void{
					_garbageImg.getAnimation().start("atlas/garbageA", "garbage.close", 1);
				}, _garbageTime_A * 1000);
			}
			else if(tweenFlag == FLAG_B_C){
				TweenLite.to(_topFusion_bg,      _readyToDeleteTweenTime, {y:topBg_offsetY_C,  ease:Cubic.easeOut, onComplete:onTopBg});
//				TweenLite.to(_bottomFusion,      _readyToDeleteTweenTime, {alpha:0.3,          ease:Linear.easeOut});
				TweenLite.to(_bottomFusion,      _readyToDeleteTweenTime, {alpha:0.3, y:bottom_offsetY_C, ease:Cubic.easeOut});
				TweenLite.to(_pressIcon,         _readyToDeleteTweenTime + _readyToDeleteTweenTime2, {x:215, y:265, scaleX:1.0, scaleY:1.0, ease:Cubic.easeOut});
				this.doModifyIconTexture(_pressIcon, true);
				
				function onTopBg() : void {
//					TweenLite.to(_bottomFusion,      _readyToDeleteTweenTime2, {alpha:0.3, ease:Linear.easeOut});
					
					// 遮挡层
					_alertBg = new ImageAA;
					_alertBg.textureId = "temp/alertBg.png";
					getFusion().addNodeAt(_alertBg, 2);
					TweenLite.from(_alertBg,         _readyToDeleteTweenTime2, {alpha:0, ease:Linear.easeOut, onComplete:function():void{
						alertFusion.touchable = true;
					}});
					alertFusion = new FusionAA;
					getFusion().addNode(alertFusion);
					alertFusion.touchable = false;
						
					TweenLite.from(alertFusion,     _readyToDeleteTweenTime2, {alpha:0, ease:Linear.easeOut});
					
					text_A = new ImageAA;
					text_A.textureId = "temp/text_A.png";
					text_A.x = (getRoot().getAdapter().rootWidth - text_A.sourceWidth) / 2 + 80;
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
				}
			}
		}
		
		private function onCancel(e:ATouchEvent):void{
//			TweenLite.to(_bottomFusion, _readyToDeleteTweenTime, {alpha:1.0,          ease:Linear.easeOut});
			TweenLite.to(_bottomFusion, _readyToDeleteTweenTime, {alpha:1.0, y:bottom_offsetY_A, ease:Cubic.easeOut});
			
			TweenLite.to(_alertBg, _readyToDeleteTweenTime, {alpha:0, ease:Linear.easeOut, onComplete:function():void{
				_alertBg.kill();
			}})
			
			alertFusion.touchable = false;
			
			this.doRevertIcon(true);
			this.doTweenGarbage(FLAG_BACK_TO_O);
//			_garbageImg.getAnimation().start("atlas/garbageA", "garbage.close", 1);
			
			
		}
		
		private function onDetermine(e:ATouchEvent):void{
//			_alertBg.kill();
			alertFusion.touchable = false;
			
			this.doCastToGarbage();
		}
		
	}
}