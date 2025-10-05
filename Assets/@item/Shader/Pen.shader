Shader "CottonUsagi/QvPenLite"
{
    Properties
    {
        _WoodColor ("Wood Color", Color) = (0.9,0.7,0.5,1)
        _PenColor ("Pen Color", Color) = (0,0,0,1)
        _DarkRate("DarkRate", Range (0.0, 1.0)) = 0.7
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                fixed4 color : TEXCOORD2;
                float2 matcapUV : TEXCOORD5;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _WoodColor;
            float4 _PenColor;
            float _DarkRate;

            float2 matcapSample(float3 viewDirection, float3 normalDirection)
            {
                half3 worldUp = float3(0,1,0);
                half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
                half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
                half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
                return matcapUV;
            }

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(VertexOutput, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;

				if(v.uv.y < 0.5){
					o.color = _WoodColor;
				}
				else{
					o.color = _PenColor;
				}

                float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
                worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
                o.matcapUV = matcapSample(normalize(_WorldSpaceCameraPos - o.worldPos), UnityObjectToWorldNormal(v.normal)); //worldNorm.xy * 0.5 + 0.5;

                return o;
            }

            fixed4 frag (VertexOutput i, float facing : VFACE) : SV_Target
            {
                fixed4 albedo = i.color;

                float light_distance = length(i.matcapUV - float2(0.5, 0.5));
                float dark = light_distance * 2 * _DarkRate;

                half4 final = albedo * (1 - dark * dark);

                return half4(final.rgb, 1);
            }
            ENDCG
        }
    }

    Fallback "VRChat/Mobile/Diffuse"
}
