package de.fork.data
{ 
	public class AdvancedColor
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var g_htmlColors : Object =
		{
			black: 0x0,
			silver: 0xc0c0c0,
			grey: 0x808080,
			white: 0xFFFFFF,
			maroon: 0x800000,
			red: 0xff0000,
			purple: 0x800080,
			fuchsia: 0xff00ff,
			green: 0x008000,
			lime: 0x00ff00,
			olive: 0x808000,
			yellow: 0xffff00,
			navy: 0x000080,
			blue: 0x0000ff,
			teal: 0x008080,
			aqua: 0x00ffff
		};	
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_value : uint;
		protected var m_alpha : uint;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function AdvancedColor(rgb : uint = 0)
		{
			setRGB(rgb);
		}
		
		
		public function setRGB(rgb:uint) : void
		{
			m_value = rgb;
			m_alpha = 100;
		}
		
		public function rgb() : uint
		{
			return m_value;
		}
		
		public function setRGBA(rgba:uint) : void
		{
	 		m_alpha = (rgba & 0xFF) / 0xFF * 100;
			m_value = rgba >>> 8;
		}
		
		public function rgba() : uint
		{
			return uint(m_value << 8) | uint(m_alpha / 100 * 0xFF);
		}
		
		public function setARGB(argb:uint) : void
		{
			m_alpha = (argb >> 32 & 0xFF) / 0xFF * 100;
			m_value = argb & ~(0xFF << 32);
		}
		
		public function argb() : uint
		{
			return m_value | ((m_alpha / 100 * 0xFF) << 32);
		}
		
		public function setRGBComponents(r:uint, g:uint, b:uint) : void
		{
			m_value = (r << 16) | (g << 8) | b;
			m_alpha = 100;
		}
		
		public function rgbComponents() : Object
		{
			var rgb : Object = 
			{
				r : m_value >> 16 & 0xFF,
				g : m_value >> 8 & 0xFF,
				b : m_value & 0xFF
			};
			return rgb;
		}
		
		public function setRGBAComponents(r:uint, g:uint, b:uint, a:uint) : void
		{
			setRGBComponents(r, g, b);
			m_alpha = a / 255 * 100;
		}
		
		public function rgbaComponents() : void
		{
			var rgba : Object = rgbComponents();
			rgba.a = m_alpha / 100;
		}
		
		public function setColorString(colorString:String) : void
		{
			if (colorString.charAt(0) == '#')
			{
				var r : uint;
				var g : uint;
				var b : uint;
				var a : uint;
				var char : String;
				switch (colorString.length)
				{
					// #RGB
					case 4:
					{
						colorString += "FF";
					}
					// #RGBA
					case 5:
					{
						char = colorString.charAt(1);
						r = parseInt(char + char, 16);
						char = colorString.charAt(2);
						g = parseInt(char + char, 16);
						char = colorString.charAt(3);
						b = parseInt(char + char, 16);
						char = colorString.charAt(4);
						a = parseInt(char + char, 16);
						break;
					}
					// #RRGGBB
					case 7:
					{
						colorString += 'FF';
					}
					// #RRGGBBAA
					default:
					{
						r = parseInt(colorString.substr(1, 2), 16);
						g = parseInt(colorString.substr(3, 2), 16);
						b = parseInt(colorString.substr(5, 2), 16);
						a = parseInt(colorString.substr(7, 2), 16);
					}
				}
				setRGBAComponents(r, g, b, a);
				return;			
			}
			
			colorString = colorString.toLowerCase();		
			if (colorString == 'transparent')
			{
				m_value = 0;
				m_alpha = 0;
				return;
			}
			
			// can be either rgb or rgba
			if (colorString.indexOf('rgb') == 0)
			{
				var lBracketIdx:uint = colorString.indexOf( '(' );
				var rBracketIdx:uint = colorString.indexOf( ')' );
				var components:Array = colorString.substring(lBracketIdx + 1, rBracketIdx).split('  ').
					join('').split(' ').join('').split(',');
				if (components.length == 3)
				{
					components.push("1");
				}
				setRGBAComponents(parseInt(components[0]), parseInt(components[1]), 
					parseInt(components[2]), parseFloat(components[3]));
				return;
			}
			
	
		
			m_alpha = 100;
			m_value = g_htmlColors[colorString];
			if (isNaN(m_value))
			{
				m_value = 0x0;
			}
		}
		
		public function setHSB(h:uint, s:uint, br:uint) : void
		{
			var r : uint;
			var g : uint;
			var b : uint;
		
			if (!isNaN(s)) 
			{
				s = (100 - s) / 100;
				br = (100 - br) / 100;
			}
		
			if ((h  > 300 && h <= 360) || (h >= 0 && h <= 60)) 
			{
				r = 255;
				g = (h / 60) * 255;
				b = ((360 - h) / 60) * 255;
			} 
			else if (h > 60 && h <= 180) 
			{
				r = ((120 - h) / 60) * 255;
				g = 255;
				b = ((h - 120) / 60) * 255;
			} 
			else 
			{
				r = ((h - 240) / 60) * 255;
				g = ((240 - h) / 60) * 255;
				b = 255;
			}
			
			if (r > 255 || r < 0) r = 0;
			if (g > 255 || g < 0) g = 0;
			if (b > 255 || b < 0) b = 0;
			
			if (!isNaN(s)) 
			{	
				r += (255 - r) * s;
				g += (255 - g) * s;
				b += (255 - b) * s;
				r -= r * br;
				g -= g * br;
				b -= b * br;
				r = Math.round(r);
				g = Math.round(g);
				b = Math.round(b);
			}
			
			m_value = b | (g << 8) | (r << 16);
			m_alpha = 100;
		}
		
		public function hsb() : Object
		{
			var r : uint = m_value >> 16 & 0xFF;
			var g : uint = m_value >> 8 & 0xFF;
			var b : uint = m_value & 0xFF;
			
			var hsb : Object = {};
			hsb.b = Math.max(Math.max(r, g), b);
			var min:uint = Math.min(r, Math.min(g, b));
			hsb.s = (hsb.b <= 0) ? 0 : Math.round(100 * (hsb.b - min) / hsb.b);
			hsb.b = Math.round((hsb.b / 255) * 100);
			hsb.h = 0;
	                
			if ((r == g) && (g == b))
				hsb.h = 0;
			else if (r >= g && g >= b)
				hsb.h = 60 * (g - b) / (r - b);
			else if (g >= r && r >= b)
				hsb.h = 60 + 60 * (g - r) / (g - b);
			else if (g >= b && b >= r)
				hsb.h = 120 + 60 * (b - r) / (g - r);
			else if (b >= g && g >= r)
				hsb.h = 180 + 60 * (b - g) / (b - r);
			else if (b >= r && r >=  g)
				hsb.h = 240 + 60 * (r - g) / (b - g);
			else if (r >= b && b >= g)
				hsb.h = 300 + 60 * (r - b) / (r - g);
			else
				hsb.h = 0;
	
			hsb.h = Math.round(hsb.h);
			return hsb;		
		}
		
		public function setAlpha(alpha:uint) : void
		{
			alpha = Math.max(0, alpha);
			alpha = Math.min(100, alpha);
			m_alpha = alpha;
		}
		
		public function alpha() : uint
		{
			return m_alpha;
		}
		
		public function setOpacity(opacity:uint) : void
		{
			m_alpha = opacity * 100;
		}
		
		public function opacity() : uint
		{
			return m_alpha / 100;
		}
		
	
		public function equals(color : AdvancedColor) : Boolean
		{
			return color.rgba() == rgba();
		}
		
		public function valueOf() : Object
		{
			return m_value;
		}
		
		public function toString() : String
		{
			var colorString : String = rgba().toString(16);
			while(colorString.length < 8)
			{
				colorString = '0' + colorString;
			}
			return '#' + colorString;
		}
	}
}