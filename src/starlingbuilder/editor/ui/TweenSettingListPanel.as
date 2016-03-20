package starlingbuilder.editor.ui
{
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Header;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.Panel;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	
	import starlingbuilder.util.feathers.FeathersUIUtil;
	
	public class TweenSettingListPanel extends Panel
	{
		private var _editData:Object;
		private var _tweenList:List;
		public var onComplete:Function;
		
		public function TweenSettingListPanel(editData:Object)
		{
			super();
			this._editData = editData;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			var layout:VerticalLayout = new VerticalLayout();
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.gap = 5;
			layout.paddingTop = 15;
			layout.paddingLeft = 10;
			layout.paddingBottom = 20;
			this.width = 480;
			this.height = 480;
			this.backgroundSkin = new Quad(480, 480, 0x333333);
			this.layout = layout;
			
			var closeBtn:Button = FeathersUIUtil.buttonWithLabel("X", onClose);
			closeBtn.width = 40;
			this.headerProperties.rightItems = new <DisplayObject>[closeBtn];
			
			this.headerProperties.title = "tween属性列表";
			
			var btnLayout:LayoutGroup = FeathersUIUtil.layoutGroupWithHorizontalLayout();
			var addBtn:Button = FeathersUIUtil.buttonWithLabel("add", onAdd);
			_deleteBtn = FeathersUIUtil.buttonWithLabel("delete", onDelete);
			_deleteBtn.isEnabled = false;
			_editBtn = FeathersUIUtil.buttonWithLabel("edit", onEdit);
			_editBtn.isEnabled = false;
			btnLayout.addChild(addBtn);
			btnLayout.addChild(_deleteBtn);
			btnLayout.addChild(_editBtn);
			addChild(btnLayout);
			
			_tweenList = new List();
			_tweenList.width = 380;
			_tweenList.height = 320;
			addChild(_tweenList);
			_tweenList.addEventListener(Event.CHANGE, onTweenListChange);
			_tweenList.itemRendererFactory = function():IListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				renderer.labelField = "text";
				renderer.labelFactory = function():Label
				{
					var label:Label = new Label();
					label.styleName = Label.ALTERNATE_STYLE_NAME_HEADING;
					label.wordWrap = true;
					label.validate();
					return label;
				}
				renderer.validate();
				return renderer;
			}
			_tweenList.dataProvider = new ListCollection();
			var str:String;
			if(_editData.length > 1)
			{
				for(var i:int=0; i<_editData.length; ++i)
				{
					str = JSON.stringify(_editData[i], null, "\t");
					_tweenList.dataProvider.addItem({
						text:str
					});
				}
			}
			else 
			{
				str = JSON.stringify(_editData,null, "\t");
				_tweenList.dataProvider.addItem({
					text:str
				});
			}
			
			var group:LayoutGroup = FeathersUIUtil.layoutGroupWithHorizontalLayout();
			var yesButton:Button = FeathersUIUtil.buttonWithLabel("Save", onYes);
			var noButton:Button = FeathersUIUtil.buttonWithLabel("Cancel", onCanel);
			group.addChild(yesButton);
			group.addChild(noButton);
			this.footerFactory = function():Header
			{
				var header:Header = new Header();
				header.styleName = Header.DEFAULT_CHILD_STYLE_NAME_TITLE;
				header.centerItems = new <DisplayObject>[group];
				return header;
			}
		}
		
		private var _index:int;
		private var _tweenStr:String;
		private var _deleteBtn:Button;
		private var _editBtn:Button;
		private function onTweenListChange(e:Event):void
		{
			if(_tweenList.selectedItem == null) return;
			if(_tweenList.selectedIndex == -1)
				_tweenList.selectedIndex = _index;
			_index = _tweenList.selectedIndex;
			_tweenStr = _tweenList.selectedItem.text;
			_deleteBtn.isEnabled = true;
			_editBtn.isEnabled = true;
		}
		
		private function onAdd(e:Event):void
		{
			var tweenPanel:TweenSettingPanel = new TweenSettingPanel(null);
			tweenPanel.onComplete = onComplete;
			PopUpManager.addPopUp(tweenPanel);
			
			function onComplete(data:Object):void
			{
//				trace(JSON.stringify(data));
				var str:String = JSON.stringify(data, null, "\t");
				_tweenList.dataProvider.addItem({
					text:str
				});
			}
		}
		
		private function onDelete(e:Event):void
		{
			Alert.show("delete this item ?", "warning", new ListCollection(
				[{
					label:"Ok",
					triggered:onOk
				},
				{
					label:"Cancel"
				}]
			));
			function onOk(e:Event):void
			{
				_tweenList.dataProvider.removeItemAt(_index);
			}
		}
		
		private function onEdit(e:Event):void
		{
			var editData:Object = JSON.parse(_tweenStr);
			var tweenPanel:TweenSettingPanel = new TweenSettingPanel(editData);
			tweenPanel.onComplete = onComplete;
			PopUpManager.addPopUp(tweenPanel);
			
			function onComplete(data:Object):void
			{
//				trace(JSON.stringify(data));
				var str:String = JSON.stringify(data, null, "\t");
				_tweenList.dataProvider.setItemAt({text:str}, _index);
				//trace(_tweenList.dataProvider.getItemAt(_index).text);
			}
			
		}
		
		private function onClose(e:Event):void
		{
			onCanel(null);
		}
		
		private function onYes(e:Event):void
		{
			var resultData:Object;
			var str:String;
			if(_tweenList.dataProvider.length == 1)
			{
				str = _tweenList.dataProvider.getItemAt(i).text;
				resultData = JSON.parse(str);
			}else
			{
				resultData = new Array();
				for(var i:int=0; i<_tweenList.dataProvider.length; ++i)
				{
					str = _tweenList.dataProvider.getItemAt(i).text;
					resultData[i] = JSON.parse(str);
				}
			}
//			var resultStr:String = JSON.stringify(resultData);
			if(onComplete != null)
				onComplete.call(this, resultData);
			onCanel(null);
		}
		
		private function onCanel(e:Event):void
		{
			if(PopUpManager.isPopUp(this))
			{
				PopUpManager.removePopUp(this);
			}
		}
	}
}