Shader "CottonUsagi/Glass"
{
    Properties
    {
        _MaxAlpha ("MaxAlpha", Range (0.0, 1.0)) = 0.5
        _MinAlpha ("MinAlpha", Range (0.0, 1.0)) = 0.0
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
                float3 worldNorm : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float _MaxAlpha;
            float _MinAlpha;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normal = normalize(i.worldNorm);
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                float rim = saturate(1 - dot(normal, view));

                float rim_l = lerp(_MinAlpha, _MaxAlpha, rim * rim);

                float3 color = float3(1, 1, 1);

                return float4(color.rgb, rim_l);
            }
            ENDCG
        }
    }

    Fallback "VRChat/Mobile/Diffuse"
}
