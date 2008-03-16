package de.fork.css { 
	
	
	
	public class CSSDeclarationList
	{
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_items : Array;
		protected	var m_declarationIndex : Number = 0;
		protected	var m_declarationCache : Array;	
			
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclarationList()
		{
			m_items = [];
			m_declarationCache = [];		
		}	
		
		public function addDeclarationWithSelectorFromFile(
			decl : Object, path : String, file : String) : void
		{
			m_items.push(new CSSDeclarationListItem(
				path, decl, m_declarationIndex++, file));
		}
		
		public function getStyleForSelectorsPath(sp:String) : CSSDeclaration
		{
			// prefer cached results
			var decl : CSSDeclaration = CSSDeclaration(m_declarationCache[ sp ]);
			if (decl)
			{
				return decl;
			}
			
			var matches : Array = [];
			var i : Number = m_items.length;
			var item : CSSDeclarationListItem;
	 		decl = new CSSDeclaration();
			
			while (i--)
			{
				item = m_items[i];
				if (item.matchesSubjectPath(sp))
				{
					matches.push(item);
				}
			}
	
			matches.sortOn(['m_declarationSpecificity', 'm_declarationIndex'], 
				Array.NUMERIC | Array.DESCENDING);
			i = matches.length;
			
			while (i--)
			{
				decl.mergeCSSDeclaration(CSSDeclarationListItem(matches[i]).declaration());
			}
			
			// cache result
			m_declarationCache[sp] = decl;
			
			return decl;
		}
	}
}