Shader "CottonUsagi/SunsetMonoColor"
{
    Properties
    {
        [KeywordEnum(None, Front, Back)] _Cull("Culling", Int) = 2
        _MainColor ("Main Color", Color) = (0.5,0.5,0.5,1)
        _BrightColor ("Bright Color", Color) = (0.1,0.1,0.1,1)
        _FogForce ("Fog Force", Range (0.0, 2.0)) = 1
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Cull [_Cull]


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            float4 _MainColor;
            float4 _BrightColor;

            float _FogForce;

            struct VertexInput
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 pos:SV_POSITION;
                half3 normal:TEXCOORD0;
                float4 color : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                UNITY_FOG_COORDS(3)
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.color = v.color;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            fixed4 frag(VertexOutput i, fixed facing : VFACE) : SV_Target
            {

                float4 _LightColor = _MainColor * (_LightColor0 + UNITY_LIGHTMODEL_AMBIENT) + _BrightColor;
                float4 _MidColor = _MainColor * (_LightColor0 + UNITY_LIGHTMODEL_AMBIENT);
                float4 _DarkColor = _MainColor * (UNITY_LIGHTMODEL_AMBIENT);

                float3 normal = normalize(i.normal) * facing;
                float l = saturate(normal.z);
                float d = min(saturate(1 + normal.z), (i.color.r));

                float4 color = lerp(_DarkColor, lerp(_MidColor, _LightColor, l*l), d*d);


                float4 undersea = color * 0.4 + float4(.0, .0, .1, 1) * 0.6;
                float depth = -i.worldPos.y;
                color = lerp( lerp(color, undersea, saturate(depth*10)), float4(.0, .0, .1, 1), saturate(depth / 3));

                UNITY_APPLY_FOG(i.fogCoord * _FogForce, color);

                return float4(color.xyz,1);
            }
            ENDCG
        }
    }
}
