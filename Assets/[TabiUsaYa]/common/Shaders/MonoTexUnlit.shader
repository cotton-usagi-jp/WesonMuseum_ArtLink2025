Shader "CottonUsagi/MonoTexUnlit"
{
    Properties
    {
        [KeywordEnum(None, Front, Back)] _Cull("Culling", Int) = 2

        [MainTexture]_MainTex("Texture", 2D) = "white" {}
        [MainColor]_MainColor("Main Color", Color) = (1.0,1.0,1.0,1)

        _RimBrightRange ("Rim Bright Range", Range (0.0, 1.0)) = 0.9
        _RimDarkRange ("Rim Dark Range", Range (0.0, 1.0)) = 0.2

        _BrightTop ("Bright Top", Range (0.0, 1.0)) = 1.0
        _BrightBottom ("Bright Bottom", Range (0.0, 1.0)) = 0

        _LightColor ("Light Color (+)", Color) = (0.8,0.8,0.8,1)
        _DarkColor ("Dark Color (x)", Color) = (0.2,0.2,0.2,1)

        _WorldColor ("World (Light) Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Cull [_Cull]
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 worldNorm : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            UNITY_DECLARE_TEX2D(_MainTex);
            half4 _MainTex_ST;
            float4 _MainColor;

            float _RimBrightRange;
            float _RimDarkRange;

            float _BrightTop;
            float _BrightBottom;

            float4 _LightColor;
            float4 _DarkColor;

            float4 _WorldColor;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normal = normalize(i.worldNorm);
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 spot = normalize((float3(0,1,0) * 0.6) + (view * 0.4));

                float nrm = dot(normal, spot);
                float rim = saturate(1 - dot(normal, view));

                float nrm_l = saturate((nrm - (_BrightBottom)) / max(0.001, _BrightTop - _BrightBottom));
                float nrm_d = saturate(-nrm + 0.3);
                float rim_l = saturate((rim - _RimBrightRange) / (1.0 - _RimBrightRange));
                float rim_d = saturate(((_RimDarkRange - rim) / (_RimDarkRange - 1.0)) - rim_l);

                float4 color = UNITY_SAMPLE_TEX2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex)) * _MainColor;

                float4 worldbright = _LightColor0 + UNITY_LIGHTMODEL_AMBIENT;
                float4 worlddark   = UNITY_LIGHTMODEL_AMBIENT;

                color = lerp(color, color + _LightColor * worldbright, max(rim_l , nrm_l));
                color = lerp(color, color * _DarkColor * worlddark, max(rim_d , nrm_d));

                color = color * _WorldColor;

                return float4(color.rgb, 1);
            }
            ENDCG
        }
    }

    Fallback "VRChat/Mobile/Diffuse"
}
