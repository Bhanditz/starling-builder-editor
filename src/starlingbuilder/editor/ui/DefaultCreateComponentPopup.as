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
    import starlingbuilder.editor.controller.DocumentManager;
    import starlingbuilder.util.feathers.popup.InfoPopup;
    import starlingbuilder.util.ui.inspector.DefaultPropertyRetriever;
    import starlingbuilder.util.ui.inspector.IPropertyRetriever;
    import starlingbuilder.util.ui.inspector.PropertyPanel;

    import feathers.controls.LayoutGroup;

    import starling.events.Event;

    public class DefaultCreateComponentPopup extends InfoPopup
    {
        private var _data:Object;

        private var _propertyPanel:PropertyPanel;

        private var _documentManager:DocumentManager;

        private var _onComplete:Function;

        private var _target:Object;

        public function DefaultCreateComponentPopup(data:Object, onComplete:Function)
        {
            _documentManager = UIEditorApp.instance.documentManager;

            _data = data;

            _onComplete = onComplete;

            super();

            title = "Create Component";
            buttons = ["OK", "Cancel"];

            addEventListener(Event.COMPLETE, onDialogComplete);
        }

        override protected function createContent(container:LayoutGroup):void
        {
            var params:Array = _data.constructorParams;

            _target = {};

            getData();

            _propertyPanel = new PropertyPanel(_target, params, propertyRetrieverFactory);
            addChild(_propertyPanel);
        }

        private function onDialogComplete(event:Event):void
        {
            var index:int = int(event.data);

            if (index == 0)
            {
                setData();

                _onComplete(_data);
            }
            else
            {
                _onComplete = null;
            }
        }

        private function getData():void
        {
            for each (var param:Object in _data.constructorParams)
            {
                //for custom param
                if (param.hasOwnProperty("textureName"))
                {
                    _target[param.name] = param.textureName;
                }
                else if (param.hasOwnProperty("name"))
                {
                    _target[param.name] = param.value;
                }
            }
        }

        private function setData():void
        {
            for each (var param:Object in _data.constructorParams)
            {
                //for custom param
                if (param.hasOwnProperty("textureName"))
                {
                    param.textureName = _target[param.name];
                }
                else if (_target.hasOwnProperty(param.name))
                {
                    param.value = _target[param.name];
                }
            }

            delete param.options;
        }

        private function propertyRetrieverFactory(target:Object, param:Object):IPropertyRetriever
        {
            if (param.name == "texture" || param.name == "textures")
            {
                param.options = toArray(AssetTab.assetList);
            }

            return new DefaultPropertyRetriever(target, param);
        }

        private static function toArray(vector:Vector.<String>):Array
        {
            var array:Array = [];

            for each (var v:String in vector)
            {
                array.push(v);
            }

            return array;
        }
    }
}
