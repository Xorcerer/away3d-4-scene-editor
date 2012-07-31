/**
 *	资源管理界面 
 */
package blade3d.Editor
{
	import away3d.debug.Debug;
	
	import blade3d.Resource.BlResource;
	import blade3d.Resource.BlResourceEvent;
	import blade3d.Resource.BlResourceManager;
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.aswing.ASColor;
	import org.aswing.Box;
	import org.aswing.Insets;
	import org.aswing.JFrame;
	import org.aswing.JLabel;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.SolidBackground;
	import org.aswing.UIManager;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.LineBorder;
	import org.aswing.geom.IntRectangle;
	import org.aswing.tree.DefaultMutableTreeNode;
	import org.aswing.tree.DefaultTreeModel;
	import org.aswing.tree.TreePath;
	
	public class BlResourceEditor extends JFrame
	{
		
		private var _panel : JPanel;
		private var _resTreeCtrl : BlResourceTree;
		private var _resTreeModel : DefaultTreeModel;
		private var _rootTreeNode : DefaultMutableTreeNode;
		
		private var frameWide:int = 150;
		
		private var _unLoadColor : ASColor = ASColor.LIGHT_GRAY;
		private var _loadColor : ASColor = ASColor.DARK_GRAY;
		
		public function BlResourceEditor(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			_panel = new JPanel();
			
			setContentPane(_panel);
			_panel.setBorder(new LineBorder(null, ASColor.GREEN));
			
//			setBackgroundDecorator(new SolidBackground(UIManager.getColor("window")));
			
			
//			setComBoundsXYWH(100, 100, 100 ,200);
			
			setSizeWH(frameWide, 400);
			
			var parent:Sprite = Sprite(owner);
			setLocationXY( parent.width - (frameWide+30), 0 );
			show();
			
			BlResourceManager.instance().addEventListener(BlResourceEvent.RESOURCE_LIST, onResourceList);
			BlResourceManager.instance().addEventListener(BlResourceEvent.RESOURCE_COMPLETE, onResourceLoaded);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			
		}
		
		private function onFocusIn(evt : FocusEvent):void
		{
//			Debug.trace("onFocusIn");
		}
		
		private function onFocusOut(evt : FocusEvent):void
		{
//			Debug.trace("onFocusOut");
		}
		
		// 资源列表加载完毕，创建资源界面
		private function onResourceList(evt: BlResourceEvent):void
		{
			_resTreeCtrl = new BlResourceTree();
			_resTreeCtrl.setPreferredWidth(frameWide);
			_panel.append(new JScrollPane(_resTreeCtrl));
						
			_rootTreeNode = new DefaultMutableTreeNode("root");
			_resTreeModel = new DefaultTreeModel(_rootTreeNode);
			_resTreeCtrl.setModel(_resTreeModel);
			
			UpdateTree();
			
			_resTreeCtrl.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function UpdateTree():void
		{
			// clear
			_rootTreeNode.removeAllChildren();
			
			var resMap : Dictionary = BlResourceManager.instance().ResourceMap;
			for each(var res:BlResource in resMap)
			{
				var currentNode:DefaultMutableTreeNode = _rootTreeNode;
				// 添加树路径
				var pathArray:Array = res.url.split("/");
				for(var i:int=0; i<pathArray.length-1; i++)
				{
					// 检查是否存在该节点
					var newChild : DefaultMutableTreeNode = null;
					for(var ni:int = 0; ni < currentNode.getChildCount(); ni++)
					{
						var name:String = DefaultMutableTreeNode(currentNode.getChildAt(ni)).getUserObject();
						if(name == pathArray[i])
							newChild = DefaultMutableTreeNode(currentNode.getChildAt(ni));
					}
					
					if(newChild)
					{
						currentNode = newChild;
					}
					else
					{
						newChild = new DefaultMutableTreeNode(pathArray[i]);
						newChild.color = _loadColor;
						currentNode.append(newChild);
						currentNode = newChild;
					}
										
				}
				
				// 添加树节点
				var leafNode:DefaultMutableTreeNode = new DefaultMutableTreeNode(pathArray[pathArray.length-1]);
				leafNode.color = _unLoadColor;
				currentNode.append(leafNode);
				
			}
		}
		
		private function onResourceLoaded(evt: BlResourceEvent):void
		{
			// 资源加载完毕，改变界面颜色
			var pathArray:Array = evt.res.url.split("/");
			
			var childNode : DefaultMutableTreeNode = _rootTreeNode;
			for(var i:int = 0; i<pathArray.length; i++)
			{
				childNode = childNode.findChildByUserObject(pathArray[i]);				
			}
			
			childNode.color = _loadColor;
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			if(evt.keyCode == Keyboard.L)
			{
				var treePath:TreePath = _resTreeCtrl.getSelectionPath();
				
				var path : Array = treePath.getPath();
				var urlString : String = "";
				for(var i:int = 1; i<path.length; i++)		// no root
				{
					urlString += path[i];
					if(i != path.length-1)
						urlString += "/";
				}
				
				
				var res:BlResource = BlResourceManager.instance().findResource(urlString);
				if(res)
					res.load();
				
			}
		}
	}
}