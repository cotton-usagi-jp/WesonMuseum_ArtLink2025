Shader "CottonUsagi/MuseumShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Matcap ("Matcap", 2D) = "black" {}
        _MatcapCutout ("Matcap Cutout", Range (0.0, 1.0)) = 0
        _MatcapRange ("Matcap Range", Range (0.0, 1.0)) = 1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                float3 worldNorm : TEXCOORD2;
                float2 matcapUV : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Matcap;
            float4 _Matcap_ST;
            float _MatcapCutout;
            float _MatcapRange;

            float2 matcapSample(float3 viewDirection, float3 normalDirection)
            {
                half3 worldUp = float3(0,1,0);
                half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
                half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
                half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection));
                return matcapUV;
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNorm = UnityObjectToWorldNormal(v.normal);
                o.matcapUV = matcapSample(normalize(_WorldSpaceCameraPos - o.worldPos), UnityObjectToWorldNormal(v.normal)); //worldNorm.xy * 0.5 + 0.5;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 mat = tex2D(_Matcap, (i.matcapUV * 0.5 + 0.5));
                mat = saturate((mat - _MatcapCutout) / (1 - _MatcapCutout));
                col = col + (mat * _MatcapRange);

                return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
