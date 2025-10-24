Shader "CottonUsagi/ArchEnd"
{
    Properties
    {
        _WhiteMin ("White Min", Float) = 3.00
        _WhiteMax ("White Max", Float) = 5.00
        _WhiteColor ("White Color", Color) = (1, 1, 1, 1)
        _ColorMax ("Color Max", Float) = 10.00
        _FarColor ("Far Color", Color) = (0.5, 0.5, 0.5, 1)
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma skip_variants SHADOWS_SHADOWMASK SHADOWS_SCREEN SHADOWS_DEPTH SHADOWS_CUBE

            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float EnterDistance : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float _WhiteMin;
            float _WhiteMax;
            float4 _WhiteColor;
            float _ColorMax;
            float4 _FarColor;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                float3 objectWorldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;

                o.EnterDistance = abs(distance(objectWorldPos, _WorldSpaceCameraPos));

                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {

                float4 trns = float4(1, 1, 1, 0);

                float alpha = saturate((i.EnterDistance - _WhiteMin) / (_WhiteMax - _WhiteMin));
                float4 white = lerp(trns, _WhiteColor, alpha);

                float range = saturate((i.EnterDistance - _WhiteMax) / (_ColorMax - _WhiteMax));
                float4 color = lerp(white, _FarColor, range);

                return color;
            }
            ENDCG
        }
    }

    Fallback "VRChat/Mobile/Diffuse"
}
