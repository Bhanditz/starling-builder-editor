/**
 * Created by hyh on 8/14/15.
 */
package starlingbuilder.util.ui.inspector
{
    public class TextInputPropertyComponentHex extends TextInputPropertyComponent
    {
        public function TextInputPropertyComponentHex(propertyRetriever:IPropertyRetriever, param:Object, customParam:Object = null, setting:Object = null)
        {
            super(propertyRetriever, param, customParam, setting);
        }

        override public function update():void
        {
            var obj:Object = _propertyRetriever.get(_param.name);

            obj = int(obj).toString(16);

            _textInput.text = "0x" + String(obj);
        }
    }
}
