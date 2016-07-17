/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.editor.ui
{
    import starlingbuilder.editor.UIEditorApp;

    import feathers.controls.LayoutGroup;
    import feathers.controls.List;
    import feathers.controls.TextInput;
    import feathers.controls.renderers.IListItemRenderer;
    import feathers.data.ListCollection;
    import feathers.layout.VerticalLayout;

    import starling.events.Event;
    import starling.utils.AssetManager;

    import starlingbuilder.editor.controller.ComponentRenderSupport;

    import starlingbuilder.editor.controller.IComponentRenderSupport;
    import starlingbuilder.engine.IAssetMediator;

    public class ObjectPropertyPopup extends AbstractPropertyPopup
    {
        protected var _searchTextInput:TextInput;
        protected var _list:List;

        protected var _assetMediator:IAssetMediator;

        public function ObjectPropertyPopup(owner:Object, target:Object, targetParam:Object, customParam:Object, onComplete:Function)
        {
            super(owner, target, targetParam, customParam, onComplete);

            _assetMediator = ComponentRenderSupport.support.assetMediator;

            title = "Select data";
            buttons = ["OK", "Cancel"];

            addEventListener(Event.COMPLETE, onDialogComplete);
        }

        override protected function createContent(container:LayoutGroup):void
        {
            container.layout = new VerticalLayout();

            _searchTextInput = new TextInput();
            _searchTextInput.prompt = "Search...";
            _searchTextInput.addEventListener(Event.CHANGE, onSearch);

            addChild(_searchTextInput);

            _list = new List();
            _list.width = 200;
            _list.height = 400;
            _list.selectedIndex = -1;

            addChild(_list);

            refreshAssets();
        }

        private function onSearch(event:Event):void
        {
            refreshAssets();
        }

        private function filterList(text:String, array:Vector.<String>):Vector.<String>
        {
            if (text.length)
            {
                var result:Vector.<String> = new Vector.<String>();

                for each (var s:String in array)
                {
                    if (s.indexOf(text) != -1)
                    {
                        result.push(s);
                    }
                }

                return result;
            }
            else
            {
                return array;
            }
        }

        private function refreshAssets():void
        {
            var data:ListCollection = new ListCollection();

            var array:Vector.<String> = filterList(_searchTextInput.text, getDataNames());

            for each (var name:String in array)
            {
                data.push({label:name});
            }

            _list.dataProvider = data;
        }

        protected function onDialogComplete(event:Event):void
        {
            var index:int = int(event.data);

            if (index == 0)
            {
                if (_list.selectedIndex >= 0)
                {
                    var name:String = _list.selectedItem.label;
                    _target = getData(name);

                    setCustomParam(name);
                }
                else
                {
                    _target = null;
                }

                complete();
            }
            else
            {
                _owner[_targetParam.name] = _oldTarget;
                _onComplete = null;
            }
        }

        protected function complete():void
        {
            _onComplete(_target);
        }

        protected function setCustomParam(name:String):void
        {
            if (_customParam)
            {
                if (_customParam.params == undefined)
                {
                    _customParam.params = {};
                }

                _customParam.params[_targetParam.name] =
                {
                    cls:"Object",
                    name: name
                };
            }
        }

        protected function getDataNames():Vector.<String>
        {
            return UIEditorApp.instance.assetManager.getObjectNames();
        }

        protected function getData(name:String):Object
        {
            return UIEditorApp.instance.assetManager.getObject(name);
        }
    }
}

