using System;
using UnityEngine.UIElements;
using UnityEngine;
using Graphlit.Nodes;
using Graphlit.Nodes.PortType;
using System.Linq;
using UnityEditor.UIElements;

namespace Graphlit
{
    [NodeInfo("Constants/Color"), Serializable]
    public class ColorNode : ConstantPropertyNode, IConvertablePropertyNode
    {
        const int OUT = 0;
        [SerializeField] private Vector4 _value = Vector4.one;
        [SerializeField] private bool _hdr = false;

        ColorField _colorField;

        PropertyDescriptor _descriptor;
        PropertyDescriptor Descriptor
        {
            get
            {
                _descriptor ??= new(PropertyType.Color) { guid = viewDataKey };
                _descriptor.defaultAttributes = _hdr ? MaterialPropertyAttribute.HDR : 0;
                return _descriptor;
            }
        }

        public override bool DisablePreview => true;
        public override void Initialize()
        {
            AddPort(new(PortDirection.Output, new Float(4), OUT));

            onUpdatePreviewMaterial += (mat) =>
            {
                mat.SetColor(Descriptor.GetReferenceName(GenerationMode.Preview), _value);
            };

            _colorField = new ColorField() { value = _value, hdr = _hdr };
            _colorField.style.width = 60;
            _colorField.Children().First().style.minWidth = 0;
            _colorField.RegisterValueChangedCallback((evt) =>
            {
                _value = evt.newValue;
                UpdatePreviewMaterial();
            });
            inputContainer.Add(_colorField);
        }

        public override void BuildContextualMenu(ContextualMenuPopulateEvent evt)
        {
            base.BuildContextualMenu(evt);

            evt.menu.AppendAction("HDR", (action) =>
            {
                _hdr = !_hdr;
                if (_colorField != null)
                {
                    _colorField.hdr = _hdr;
                }
                UpdatePreviewMaterial();
            }, _hdr ? DropdownMenuAction.Status.Checked : DropdownMenuAction.Status.Normal);
        }

        protected override void Generate(NodeVisitor visitor)
        {
            if (visitor.GenerationMode == GenerationMode.Preview)
            {
                Descriptor.VectorValue = _value;
                visitor.AddProperty(Descriptor);
                PortData[OUT] = new GeneratedPortData(new Float(4), Descriptor.GetReferenceName(GenerationMode.Preview));
            }
            else
            {
                Vector4 v;
                if (_hdr)
                {
                    // HDR values are authored directly in linear intensity space,
                    // matching an [HDR] material color property - no gamma decode.
                    v = _value;
                }
                else
                {
                    v.x = MathF.Pow(_value.x, 2.2f);
                    v.y = MathF.Pow(_value.y, 2.2f);
                    v.z = MathF.Pow(_value.z, 2.2f);
                    //v.w = MathF.Pow(_value.w, 2.2f);
                    v.w = _value.w;
                }

                SetVariable(OUT, $"{PrecisionString(4)}{v}");
            }
        }

        public void CopyConstant(PropertyDescriptor propertyDescriptor)
        {
            _value = propertyDescriptor.VectorValue;
            _hdr = propertyDescriptor.defaultAttributes.HasFlag(MaterialPropertyAttribute.HDR);
        }

        public PropertyNode ToProperty()
        {
            var graphData = GraphView.graphData;

            var prop = new ColorPropertyNode
            {
                _ref = viewDataKey
            };

            var desc = new PropertyDescriptor(PropertyType.Color, GetSuggestedPropertyName())
            {
                guid = viewDataKey,
                VectorValue = _value,
                defaultAttributes = _hdr ? MaterialPropertyAttribute.HDR : 0
            };

            graphData.properties.Add(desc);
            return prop;
        }
    }
}