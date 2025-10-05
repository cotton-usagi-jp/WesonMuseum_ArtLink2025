Shader "CottonUsagi/HideinCamera Unlit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _CoverTex ("Cover Texture", 2D) = "white" {}
        [Toggle] _No_Photography ("No Photography", Float) = 0
        [Toggle] _Close_Range ("Prohibit Close Range", Float) = 0
        _Range ("Near Range", Float) = 3
        _Bound ("Bound", Float) = 0.1
        [Toggle] _Apply_Fog ("Apply Fog", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "CameraAnalyzer.cginc"

            #pragma shader_feature _NO_PHOTOGRAPHY_ON
            #pragma shader_feature _CLOSE_RANGE_ON
            #pragma shader_feature _APPLY_FOG_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CoverTex;
            float4 _CoverTex_ST;

            float _Range;
            float _Bound;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            bool isDisplayMainTex()
            {
                //if(isPlayerView() && isVRView())
                if(isPlayerView())
                {
                    return 1;
                }
                else
                {
                    return 0;
                }
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(0, 0, 0, 0);
                fixed4 mncol = tex2D(_MainTex, i.uv);

                #ifdef _NO_PHOTOGRAPHY_ON
                    fixed4 cvcol = tex2D(_CoverTex, i.uv);

                    #ifdef _CLOSE_RANGE_ON
                        float dist = abs(distance(i.worldPos, _WorldSpaceCameraPos));
                        float near = saturate((dist - _Range) / max(_Bound, 0.001));
                        col = lerp(lerp(cvcol, mncol, near), mncol, isDisplayMainTex());
                    #else
                        col = lerp(cvcol, mncol, isDisplayMainTex());
                    #endif
                #else
                    col = mncol;
                #endif


                #ifdef _APPLY_FOG_ON
                    UNITY_APPLY_FOG(i.fogCoord, col);
                #endif
                return col;
            }
            ENDCG
        }
    }
}
