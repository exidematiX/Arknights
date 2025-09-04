Shader "Custom/ToonShader-2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color", Color) = (0.5,0.5,0.8,1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
        _OutlineWidth ("Outline Width", Range(0, 0.01)) = 0.003
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        
        // 描边Pass
        Pass
        {
            Name "Outline"
            Cull Front
            
            HLSLPROGRAM
            #pragma vertex OutlineVert
            #pragma fragment OutlineFrag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            float _OutlineWidth;
            half4 _OutlineColor;
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            Varyings OutlineVert(Attributes input)
            {
                Varyings output;
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                positionWS += normalWS * _OutlineWidth;
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }
            
            half4 OutlineFrag() : SV_Target
            {
                return _OutlinweColor;
            }
            ENDHLSL
        }
        
        // ����ȾPass
        Pass
        {
            Name "ToonLit"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            
            HLSLPROGRAM
            #pragma vertex ToonVert
            #pragma fragment ToonFrag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
                half4 _ShadowColor;
                half _ShadowThreshold;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };
            
            Varyings ToonVert(Attributes input)
            {
                Varyings output;
                
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                
                return output;
            }
            
            half4 ToonFrag(Varyings input) : SV_Target
            {
                // ��������
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half3 baseColor = tex.rgb * _Color.rgb;
                
                // ��ȡ����Դ
                Light mainLight = GetMainLight();
                half3 lightDir = normalize(mainLight.direction);
                half3 normal = normalize(input.normalWS);
                
                // �������
                half NdotL = dot(normal, lightDir);
                half lightIntensity = NdotL * 0.5 + 0.5; // Half Lambert
                
                // ToonЧ�������ݻ�����
                half toonRamp = step(_ShadowThreshold, lightIntensity);
                
                // �������ɫ��
                half3 finalColor = lerp(_ShadowColor.rgb * baseColor, baseColor, toonRamp);
                finalColor *= mainLight.color;
                
                // ���ӻ�����
                finalColor += baseColor * unity_AmbientSky.rgb * 0.2;
                
                return half4(finalColor, _Color.a);
            }
            ENDHLSL
        }
        
        // ��ӰͶ��Pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex ShadowVert
            #pragma fragment ShadowFrag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            Varyings ShadowVert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }
            
            half4 ShadowFrag() : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
    }