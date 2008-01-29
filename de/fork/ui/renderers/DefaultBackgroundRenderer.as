package de.fork.ui.renderers { 
	import de.fork.css.CSSProperty;
	import de.fork.css.propertyparsers.Background;
	import de.fork.css.propertyparsers.Filters;
	import de.fork.data.AdvancedColor;
	import de.fork.events.ResourceEvent;
	import de.fork.external.BitmapResource;
	import de.fork.external.ImageResource;
	import de.fork.utils.GfxUtil;
	import de.fork.utils.Gradient;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	public class DefaultBackgroundRenderer extends AbstractCSSRenderer
	{
	
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_backgroundImage : BitmapData = null;
		protected var m_backgroundImageLoader : BitmapResource;
		protected var m_backgroundAnimationLoader : ImageResource;
		protected var m_backgroundAnimationWrapper : Sprite;
		protected var m_backgroundAnimationContainer : Sprite;
		protected var m_backgroundMask : Sprite;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DefaultBackgroundRenderer() {}
	
		
		public override function draw() : void
		{
			m_display.graphics.clear();
			
			var color:AdvancedColor = m_styles.backgroundColor;
			var hasBackgroundGradient:Boolean = (m_styles.backgroundGradientType == 
				Background.GRADIENT_TYPE_LINEAR || m_styles.backgroundGradientType == 
				Background.GRADIENT_TYPE_RADIAL) && m_styles.backgroundGradientColors;
			
			if (color != null && color.alpha() >= 0 && !hasBackgroundGradient)
			{
				m_display.graphics.beginFill(color.rgb(), color.opacity());
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
				m_display.graphics.endFill();
			}
			
			if (hasBackgroundGradient)
			{
				var grad : Gradient = new Gradient(m_styles.backgroundGradientType);
				grad.setColors(m_styles.backgroundGradientColors);
				if (m_styles.backgroundGradientRatios)
				{
					grad.setRatios(m_styles.backgroundGradientRatios);
				}
				if (m_styles.backgroundGradientRotation != null)
				{
					grad.setRotation(m_styles.backgroundGradientRotation);
				}
				
				grad.beginGradientFill(m_display, m_width, m_height);
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
				m_display.graphics.endFill();
			}
			
			
			if (m_styles.backgroundImage != null && 
				m_styles.backgroundImage != Background.IMAGE_NONE)
			{
				loadBackgroundImage();
			}
			else
			{
				if (m_backgroundImage != null)
				{
					m_backgroundImage.dispose();
					m_backgroundImage = null;
				}
			}
			
			if (m_styles.backgroundShadowColor != null)
			{
				var dropShadow : DropShadowFilter = Filters.dropShadowFilterFromStyleObjectForName(
					m_styles, 'background');
				m_display.filters = [dropShadow];
			}
			
			drawBackgroundMask();
		}
	
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function loadBackgroundImage() : void
		{
			if (m_styles.backgroundImageType != 'animation')
			{
				if (m_backgroundAnimationWrapper != null)
				{
					if (m_backgroundAnimationWrapper.parent != null)
					{
						m_backgroundAnimationWrapper.parent.
							removeChild(m_backgroundAnimationWrapper);
					}
					m_backgroundAnimationWrapper = null;
					m_backgroundAnimationContainer = null;
				}
				
				m_backgroundImageLoader = new BitmapResource();
				m_backgroundImageLoader.setURL(m_styles.backgroundImage);
				m_backgroundImageLoader.setCacheBitmap(true);
				m_backgroundImageLoader.setCloneBitmap(false);
				m_backgroundImageLoader.setApplicationURL(
					m_display.loaderInfo.url);
				m_backgroundImageLoader.addEventListener(Event.COMPLETE, 
				 bitmapLoader_complete);
				m_backgroundImageLoader.execute();
				return;
			}
			
			//TODO: check if this is correct
			if (m_backgroundAnimationContainer.loaderInfo.url == 
				m_styles.backgroundImage)
			{
				imageLoader_complete();
				return;
			}
			
			if (m_backgroundAnimationWrapper == null)
			{
				m_backgroundAnimationWrapper = new Sprite();
				m_backgroundAnimationWrapper.name = 
					'm_backgroundAnimationWrapper';
				m_display.addChild(m_backgroundAnimationWrapper);
			}
	
			m_backgroundAnimationContainer = new Sprite();
			m_backgroundAnimationContainer.name = 'm_backgroundAnimation';
			m_backgroundAnimationWrapper.addChild(
				m_backgroundAnimationContainer);
	
			m_backgroundAnimationWrapper.visible = false;
			m_backgroundAnimationLoader = new ImageResource();
			m_backgroundAnimationLoader.setURL(m_styles.backgroundImage);
			m_backgroundAnimationLoader.addEventListener(Event.COMPLETE, 
				imageLoader_complete);
			m_backgroundAnimationLoader.execute();
		}
		
		protected function drawBackgroundMask() : void
		{
			//GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
			var radii : Array = [];
			var hasRoundBorder : Boolean = false;
			var order : Array = ['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
	
			var i : Number;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				if (!m_styles[order[i]] is Number)
				{
					radiusItem = 0;
				}
				else
				{
					radiusItem = m_styles[order[i]];
				}
				if (radiusItem != 0)
				{
					hasRoundBorder = true;
				}
				radii.push(radiusItem);
			}
	
			if (!hasRoundBorder)
			{
				m_display.mask = null;
				GfxUtil.drawRect(m_display, 0, 0, m_width, m_height);
			}
			else
			{
				if (!m_backgroundMask)
				{
					m_backgroundMask = new Sprite();
					m_backgroundMask.name = 'mask';
					m_backgroundMask.visible = false;
				}
				m_display.mask = m_backgroundMask;
				m_backgroundMask.graphics.clear();
				m_backgroundMask.graphics.beginFill(0x00ff00, 20);
				GfxUtil.drawRoundRect(
					m_backgroundMask, 0, 0, m_width, m_height, radii);
			}
		}
		
		
		protected function bitmapLoader_complete(e : ResourceEvent) : void
		{
			if (!e.success)
			{
				return;
			}
			
			if (!m_backgroundImageLoader.content() is BitmapData)
			{
				return;
			}
			var newBackgroundImage : BitmapData = 
				BitmapData(m_backgroundImageLoader.content());
			var imgWidth : Number = newBackgroundImage.width;
			var imgHeight : Number = newBackgroundImage.height;
			// prevent infinite loops
			if (imgWidth < 1 || imgHeight < 1)
			{
				return;
			}
	
			
			var backgroundRepeat : String = m_styles.backgroundRepeat;
			var origin : Point = new Point(
				m_styles.backgroundPositionX | 0, m_styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.unit() == CSSProperty.UNIT_PERCENT)
			{
				origin.x = 
					Math.round((m_width - imgWidth) / 100 * Number(xProperty));
			}
			var yProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.unit() == CSSProperty.UNIT_PERCENT)
			{
				origin.y = 
					Math.round((m_height - imgHeight) / 100 * Number(yProperty));
			}
	
			var scale9Rect : Rectangle = constructScale9Rect(imgWidth, imgHeight);
			if (scale9Rect != null)
			{
				if (m_styles.backgroundScale9Type == Background.SCALE9_TYPE_REPEAT)
				{
					drawScale9RepeatedBackground(newBackgroundImage, scale9Rect);
					return;
				}
					
				var scale9Bitmap : BitmapData = new BitmapData(m_width, m_height, true, 0);
				GfxUtil.scale9Bitmap(newBackgroundImage, scale9Bitmap, scale9Rect);
				backgroundRepeat = Background.REPEAT_NO_REPEAT;
				origin = new Point(0, 0);
				newBackgroundImage = scale9Bitmap;
				imgWidth = m_width;
				imgHeight = m_height;
			}
	
			
			var rect : Rectangle = new Rectangle(0, 0, m_width, m_height);
			var offset : Matrix = new Matrix();
			offset.translate(origin.x, origin.y);
					
			switch (backgroundRepeat)
			{
				case Background.REPEAT_REPEAT_XY:
				case undefined:
				{
					// we're all set
					break;
				}
				case Background.REPEAT_REPEAT_X:
				{
					rect.top = origin.y;
					rect.height = imgHeight;
					break;
				}
				case Background.REPEAT_REPEAT_Y:
				{
					rect.left = origin.x;
					rect.width = imgWidth;
					break;
				}
				case Background.REPEAT_NO_REPEAT:
				{
					rect.topLeft = origin;
					rect.size = new Point(imgWidth, imgHeight);
					break;
				}
			}
	
			rect.top = Math.max(0, rect.top);
			rect.left = Math.max(0, rect.left);
			rect.right = Math.min(m_width, rect.right);
			rect.bottom = Math.min(m_height, rect.bottom);
	
			m_display.graphics.beginBitmapFill(newBackgroundImage, offset, true, true);
			GfxUtil.drawRect(m_display, rect.left, rect.top, rect.width, rect.height);
			m_display.graphics.endFill();
		}
		
		protected function drawScale9RepeatedBackground(sourceImage : BitmapData, 
			scale9Rect : Rectangle, repeat : Boolean = false) : void
		{
			var imgWidth : Number = sourceImage.width;
			var imgHeight : Number = sourceImage.height;
			
			var bitmaps : Object = GfxUtil.segmentedBitmapsOfScale9RectInRectWithSize(
				sourceImage, scale9Rect);
			var offset : Matrix = new Matrix();
			
			// TL
			offset.translate(0, 0);
			m_display.graphics.beginBitmapFill(bitmaps.tl, offset, false, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, bitmaps.tl.width, bitmaps.tl.height);
			m_display.graphics.endFill();
			// T
			offset.tx = bitmaps.tl.width;
			offset.ty = 0;
			m_display.graphics.beginBitmapFill(bitmaps.t, offset, true, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				m_width - bitmaps.tl.width - bitmaps.tr.width, bitmaps.t.height);
			m_display.graphics.endFill();
			// TR
			offset.tx = m_width - bitmaps.tr.width;
			offset.ty = 0;
			m_display.graphics.beginBitmapFill(bitmaps.tr, offset, false, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				bitmaps.tr.width, bitmaps.tr.height);
			m_display.graphics.endFill();
			// R
			offset.tx = m_width - bitmaps.r.width;
			offset.ty = bitmaps.tr.height;
			m_display.graphics.beginBitmapFill(bitmaps.r, offset, true, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				bitmaps.r.width, m_height - bitmaps.tr.height - bitmaps.br.height);
			m_display.graphics.endFill();
			// BR
			offset.tx = m_width - bitmaps.br.width;
			offset.ty = m_height - bitmaps.br.height;
			m_display.graphics.beginBitmapFill(bitmaps.br, offset, false, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				bitmaps.br.width, bitmaps.br.height);
			m_display.graphics.endFill();
			// B
			offset.tx = bitmaps.bl.width;
			offset.ty = m_height - bitmaps.b.height;
			m_display.graphics.beginBitmapFill(bitmaps.b, offset, true, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				m_width - bitmaps.bl.width - bitmaps.br.width, bitmaps.b.height);
			m_display.graphics.endFill();
			// BL
			offset.tx = 0;
			offset.ty = m_height - bitmaps.bl.height;
			m_display.graphics.beginBitmapFill(bitmaps.bl, offset, false, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				bitmaps.bl.width, bitmaps.bl.height);
			m_display.graphics.endFill();
			// L
			offset.tx = 0;
			offset.ty = bitmaps.tl.height;
			m_display.graphics.beginBitmapFill(bitmaps.l, offset, true, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				bitmaps.l.width, m_height - bitmaps.tl.height - bitmaps.bl.height);
			m_display.graphics.endFill();
			// C
			offset.tx = bitmaps.tl.width;
			offset.ty = bitmaps.tl.height;
			m_display.graphics.beginBitmapFill(bitmaps.c, offset, true, true);
			GfxUtil.drawRect(m_display, offset.tx, offset.ty, 
				m_width - bitmaps.l.width - bitmaps.r.width, 
				m_height - bitmaps.t.height - bitmaps.b.height);
			m_display.graphics.endFill();
		}
		
		protected function imageLoader_complete(e : ResourceEvent = null) : void
		{
			var imgContainer : MovieClip = MovieClip(m_backgroundAnimationLoader.content());
			var imgWidth : Number = imgContainer.width;
			var imgHeight : Number = imgContainer.height;
					
			var scale9Rect : Rectangle = constructScale9Rect(imgWidth, imgHeight);
			if (scale9Rect != null)
			{
				imgContainer.x = imgContainer.y = 0;
				imgContainer.scale9Grid = scale9Rect;
				imgContainer.width = m_width;
				imgContainer.height = m_height;
				m_backgroundAnimationWrapper.visible = true;
				return;
			}
	
			imgContainer.scale9Grid = null;
			imgContainer.scaleX = imgContainer.scaleY = 100;
			var origin : Point = new Point(
				m_styles.backgroundPositionX | 0, m_styles.backgroundPositionY | 0);
			var xProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionX');
			if (xProperty && xProperty.unit() == CSSProperty.UNIT_PERCENT)
			{
				origin.x = 
					Math.round((m_width - imgWidth) / 100 * Number(xProperty));
			}
			var yProperty : CSSProperty = 
				m_complexStyles.getStyle('backgroundPositionY');
			if (yProperty && yProperty.unit() == CSSProperty.UNIT_PERCENT)
			{
				origin.y = 
					Math.round((m_height - imgHeight) / 100 * Number(yProperty));
			}
			
			imgContainer.x = origin.x;
			imgContainer.y = origin.y;
			m_backgroundAnimationWrapper.visible = true;
		}
		
		protected function constructScale9Rect(imgWidth : Number, imgHeight : Number) : Rectangle
		{
			if (m_styles.backgroundScale9Type == null || 
				m_styles.backgroundScale9Type == Background.SCALE9_TYPE_NONE ||
				m_styles.backgroundScale9RectTop == null ||
				m_styles.backgroundScale9RectRight == null ||
				m_styles.backgroundScale9RectBottom == null ||
				m_styles.backgroundScale9RectLeft == null)
			{
				return null;
			}
			
			var scale9Rect : Rectangle = new Rectangle();
			scale9Rect.top = m_styles.backgroundScale9RectTop;
			scale9Rect.left = m_styles.backgroundScale9RectRight;
			scale9Rect.width = imgWidth - m_styles.backgroundScale9RectRight - 
				m_styles.backgroundScale9RectLeft;
			scale9Rect.height = imgHeight - m_styles.backgroundScale9RectTop - 
				m_styles.backgroundScale9RectBottom;
	
			return scale9Rect;
		}
	}
}