/**
 * Created by hyh on 8/14/15.
 */
package com.sgn.tools.util.ui.inspector
{
    import feathers.controls.TextArea;
    import feathers.events.FeathersEventType;

    import starling.events.Event;

    public class TextAreaPropertyComponent extends BasePropertyComponent
    {
        protected var _textArea:TextArea;

        public function TextAreaPropertyComponent(propertyRetriver:IPropertyRetriever, param:Object)
        {
            super(propertyRetriver, param);

            _textArea = new TextArea();
            _textArea.maxWidth = 200;

            addChild(_textArea);

            if (param.disable)
            {
                _textArea.isEnabled = false;
            }
            else
            {
                _textArea.isEnabled = true;
            }

            update();

            _textArea.addEventListener(FeathersEventType.FOCUS_OUT, onTextInput);
            _textArea.addEventListener(FeathersEventType.ENTER, onTextInput);
        }

        private function onTextInput(event:Event):void
        {
            try
            {
                var value:Object = JSON.parse(_textArea.text);
                _oldValue = _propertyRetriever.get(_param.name);
                _propertyRetriever.set(_param.name, value);
                setChanged();
            }
            catch(e:Error)
            {
                trace("Invalid JSON object!")
            }
        }

        override public function update():void
        {
            var value:Object = _propertyRetriever.get(_param.name);

            if (value is String)
            {
                _textArea.text = String(_propertyRetriever.get(_param.name));
            }
            else
            {
                _textArea.text = JSON.stringify(value);
            }
        }
    }
}
