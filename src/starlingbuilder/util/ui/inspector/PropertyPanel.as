/**
 * Created by hyh on 5/15/15.
 */
package starlingbuilder.util.ui.inspector
{
    import feathers.controls.Check;

    import starlingbuilder.engine.util.ObjectLocaterUtil;
    import starlingbuilder.engine.util.ParamUtil;
    import starlingbuilder.util.feathers.FeathersUIUtil;

    import feathers.controls.LayoutGroup;
    import feathers.controls.ScrollContainer;

    import starling.display.DisplayObject;

    import starling.events.Event;
    import starling.events.EventDispatcher;

    public class PropertyPanel extends LayoutGroup
    {
        public static var globalDispatcher:EventDispatcher = new EventDispatcher();

        protected var _container:ScrollContainer;

        protected var _target:Object;
        protected var _params:Array;

        protected var _propertyRetrieverFactory:Function;

        protected var _linkedProperties:Array;
        protected var _linkedPropertiesInitValues:Object;
        protected var _linkedPropertiesCheck:Check;

        public function PropertyPanel(target:Object = null, params:Array = null, propertyRetrieverFactory:Function = null)
        {
            _linkedPropertiesInitValues = {};
            _linkedPropertiesCheck = new Check();
            _linkedPropertiesCheck.label = "link";

            _propertyRetrieverFactory = propertyRetrieverFactory;

            _container = FeathersUIUtil.scrollContainerWithVerticalLayout();
            addChild(_container);

            if (target && params)
                reloadData(target, params);

            globalDispatcher.addEventListener(UIMapperEventType.PROPERTY_CHANGE, onGlobalPropertyChange);
        }

        private function onGlobalPropertyChange(event:Event):void
        {
            if (event.data.target === _target)
            {
                changeLinkedProperties(event);

                reloadTarget(_target);
            }
        }

        public function reloadTarget(target:Object = null, force:Boolean = false):void
        {
            if (_target !== target || force)
            {
                _target = target;

                _container.removeChildren(0, -1, true);

                for each (var param:Object in _params)
                {
                    if (hasProperty(_target, param.name))
                    {
                        var mapper:BasePropertyUIMapper = new BasePropertyUIMapper(_target, param, _propertyRetrieverFactory);
                        _container.addChild(mapper);
                    }
                }

                if (_linkedProperties)
                {
                    if (_target && _params)
                    {
                        var index:int = findLastLinkedPropertyIndex();
                        _container.addChildAt(_linkedPropertiesCheck, index + 1);
                    }
                }
                else
                {
                    _linkedPropertiesCheck.removeFromParent();
                }
            }
            else
            {
                BasePropertyUIMapper.updateAll(this);
            }
        }

        public function reloadData(target:Object = null, params:Array = null):void
        {
            if (target !== _target)
            {
                if (params !== _params) //both target and params change
                {
                    _params = params;
                    reloadTarget(target);
                }
                else    //only target changes
                {
                    _target = target;
                    BasePropertyUIMapper.updateAll(this, _target);
                }
            }
            else
            {
                if (params !== _params) //only params changes
                {
                    _params = params;
                }
                else    //none of them change
                {
                }

                reloadTarget(target);
            }
        }

        public function reset():void
        {
            _container.removeChildren(0, -1, true);
            _target = null;
            _params = null;
        }

        private function hasProperty(target:Object, name:String):Boolean
        {
            //Always allow as3 plain object to visible even if property does not exist
            if (ParamUtil.getClassName(target) == "Object")
                return true;

            return ObjectLocaterUtil.hasProperty(target, name);
        }

        override public function dispose():void
        {
            globalDispatcher.removeEventListener(UIMapperEventType.PROPERTY_CHANGE, onGlobalPropertyChange);

            super.dispose();
        }


        public function get linkedProperties():Array
        {
            return _linkedProperties;
        }

        public function set linkedProperties(value:Array):void
        {
            _linkedProperties = value;
        }

        private function findLastLinkedPropertyIndex():int
        {
            var index:int = 0;

            for each (var name:String in _linkedProperties)
            {
                for (var i:int = 0; i < _params.length; ++i)
                {
                    var param:Object = _params[i];

                    if (param.name == name)
                    {
                        index = Math.max(index, i);
                    }
                }
            }

            return index;
        }

        private function changeLinkedProperties(event:Event):void
        {
            var name:String = event.data.propertyName;

            if (_linkedPropertiesCheck.isSelected && _linkedProperties.indexOf(name) != -1 && linkedCondition(_target))
            {
                for each (var item:String in _linkedProperties)
                {
                    if (item == name) continue;

                    if (_target && _target.hasOwnProperty(item))
                    {
                        //special case for locking width/height ratio
                        if (_target is DisplayObject)
                        {
                            if (name == "width")
                            {
                                _target["scaleY"] = _target["scaleX"];
                            }
                            else if (name == "height")
                            {
                                _target["scaleX"] = _target["scaleY"];
                            }
                        }
                    }
                }
            }
        }

        //special case for rotation/size race condition
        private function linkedCondition(target:Object):Boolean
        {
            return target is DisplayObject && target.rotation == 0;
        }
    }
}
