Shader "CottonUsagi/GroupButton"
{
    Properties
    {
        _FaceColor ("Face Color", Color) = (1,1,1,1)
        _BoardColor ("Board Color", Color) = (0,0,0,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
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
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float4 color : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNorm : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };


            float4 _FaceColor;
            float4 _BoardColor;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normal = normalize(i.worldNorm);
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                float rim = 1 - saturate(dot(normal, view));
                float dark = 1 - (rim * rim);

                half4 color = saturate(lerp(_BoardColor, _FaceColor, i.color) * dark);

                return float4(color.rgb, 1);
            }
            ENDCG
        }
    }

    Fallback "VRChat/Mobile/Diffuse"
}
