Shader "CottonUsagi/Liquid"
{
    Properties
    {
        [MainColor]_Color ("Color", Color) = (0.2, 0.2, 0.2, 1)
        _Alpha ("Alpha", Range (0.0, 1.0)) = 0.5
        _Reflection ("Reflection", Range (0.0, 1.0)) = 0.6
        _ReflectionColor ("Reflection Color", Color) = (0.8, 0.8, 0.8, 1)
        _ReflectionColorRate ("Reflection Color Rate", Range (0.0, 1.0)) = 0.0

        _WorldColor ("World (Light) Color", Color) = (1,1,1,1)
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

            float4 _Color;
            float _Alpha;

            float4 _WorldColor;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normal = normalize(i.worldNorm);
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                float rim = saturate(dot(normal, view));

                float outer_alpha = (_Alpha * 0.5) + 0.5;

                float4 color = _Color * _WorldColor;

                return float4(color.rgb, saturate(lerp(outer_alpha, _Alpha, rim)));
            }
            ENDCG
        }

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

            float _Reflection;
            float4 _ReflectionColor;
            float _ReflectionColorRate;

            float4 frag (VertexOutput i) : SV_Target
            {
                half3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 reflDir = reflect(-worldViewDir, i.worldNorm);

                float3 normal = normalize(i.worldNorm);
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);

                float rim = saturate(1 - dot(normal, view));

                float3 color = lerp(DecodeHDR(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, 0), unity_SpecCube0_HDR), _ReflectionColor.rgb, _ReflectionColorRate);

                return float4(color.rgb, rim * _Reflection);
            }
            ENDCG
        }

    }
    Fallback "VRChat/Mobile/Diffuse"
}
