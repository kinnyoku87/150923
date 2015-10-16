package AA
{
	import org.agony2d.display.ImageAA;

	public class AAUtil
	{
		
		public static function createScaleImg( id:String, scale:Number = 1.0 ) : ImageAA {
			var imgA:ImageAA;
			
			imgA = new ImageAA;
			imgA.textureId = "temp/" + id + ".png";
			imgA.scaleX = imgA.scaleY = scale;
			imgA.pivotX = imgA.sourceWidth / 2;
			imgA.pivotY = imgA.sourceHeight / 2;
			return imgA;
		}
		
	}
}