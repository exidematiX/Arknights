Shader "Custom/GenshinImpact"
{
    Properties
    {
        [Header(Base)]
        _MainTex ("Base Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        
        [Header(Lighting)]
        _ShadowMap ("Shadow Map", 2D) = "white" {}
        _ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 1, 1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 1)) = 0.05
        
        [Header(Specular)]
        _SpecularMap ("Specular Map", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _SpecularSize ("Specular Size", Range(0, 1)) = 0.1
        _SpecularSoftness ("Specular Softness", Range(0, 1)) = 0.05
        
        [Header(Rim Light)]
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 10)) = 2
        _RimIntensity ("Rim Intensity", Range(0, 2)) = 0.5
        
        [Header(Outline)]
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.005
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        
        [Header(Normal)]
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalScale ("Normal Scale", Range(0, 2)) = 1
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline"="UniversalPipeline"
        }
        
        // Outline Pass
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            
            Cull Front
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex OutlineVertex
            #pragma fragment OutlineFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float _OutlineWidth;
                half4 _OutlineColor;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            Varyings OutlineVertex(Attributes input)
            {
                Varyings output;
                
                // 法线外扩
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                positionWS += normalWS * _OutlineWidth;
                
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }
            
            half4 OutlineFragment(Varyings input) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
        
        // Main Toon Shading Pass
        Pass
        {
            Name "ToonForward"
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Back
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex ToonVertex
            #pragma fragment ToonFragment
            
            // URP keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_ShadowMap);
            SAMPLER(sampler_ShadowMap);
            
            TEXTURE2D(_SpecularMap);
            SAMPLER(sampler_SpecularMap);
            
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _BaseColor;
                
                half4 _ShadowColor;
                half _ShadowThreshold;
                half _ShadowSmoothness;
                
                half4 _SpecularColor;
                half _SpecularSize;
                half _SpecularSoftness;
                
                half4 _RimColor;
                half _RimPower;
                half _RimIntensity;
                
                half _NormalScale;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
                float4 shadowCoord : TEXCOORD6;
                float fogCoord : TEXCOORD7;
            };
            
            Varyings ToonVertex(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                
                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                
                output.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                output.shadowCoord = GetShadowCoord(positionInputs);
                output.fogCoord = ComputeFogFactor(positionInputs.positionCS.z);
                
                return output;
            }
            
            // Toon Ramp Function
            half ToonRamp(half NdotL, half threshold, half smoothness)
            {
                half ramp = smoothstep(threshold - smoothness, threshold + smoothness, NdotL);
                return ramp;
            }
            
            // Specular Calculation
            half CalculateSpecular(half3 normalWS, half3 lightDirWS, half3 viewDirWS, half specularSize, half softness)
            {
                half3 halfVec = normalize(lightDirWS + viewDirWS);
                half NdotH = saturate(dot(normalWS, halfVec));
                half specular = pow(NdotH, (1 - specularSize) * 128);
                specular = smoothstep(0.5 - softness, 0.5 + softness, specular);
                return specular;
            }
            
            half4 ToonFragment(Varyings input) : SV_Target
            {
                // Sample textures
                half4 baseMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half4 shadowMap = SAMPLE_TEXTURE2D(_ShadowMap, sampler_ShadowMap, input.uv);
                half4 specularMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, input.uv);
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv), _NormalScale);
                
                // Calculate normal in world space
                half3 normalWS = TransformTangentToWorld(normalTS, 
                    half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
                normalWS = normalize(normalWS);
                
                half3 viewDirWS = normalize(input.viewDirWS);
                
                // Get main light
                Light mainLight = GetMainLight(input.shadowCoord);
                half3 lightDirWS = normalize(mainLight.direction);
                
                // Base color
                half3 albedo = baseMap.rgb * _BaseColor.rgb;
                
                // Calculate lighting
                half NdotL = dot(normalWS, lightDirWS);
                half halfLambert = NdotL * 0.5 + 0.5;
                
                // Shadow mask from texture
                half shadowMask = shadowMap.r;
                
                // Toon lighting with shadow map influence
                half toonRamp = ToonRamp(halfLambert * shadowMask, _ShadowThreshold, _ShadowSmoothness);
                
                // Mix base color with shadow color
                half3 diffuse = lerp(_ShadowColor.rgb * albedo, albedo, toonRamp);
                diffuse *= mainLight.color * mainLight.distanceAttenuation;
                
                // Specular
                half specular = CalculateSpecular(normalWS, lightDirWS, viewDirWS, _SpecularSize, _SpecularSoftness);
                specular *= specularMap.r * toonRamp; // Only show specular in lit areas
                half3 specularColor = specular * _SpecularColor.rgb * mainLight.color;
                
                // Rim lighting
                half rim = 1.0 - saturate(dot(viewDirWS, normalWS));
                rim = pow(rim, _RimPower);
                half3 rimColor = rim * _RimColor.rgb * _RimIntensity;
                
                // Combine all lighting
                half3 color = diffuse + specularColor + rimColor;
                
                // Add ambient lighting
                color += albedo * unity_AmbientSky.rgb * 0.3;
                
                // Apply fog
                color = MixFog(color, input.fogCoord);
                
                return half4(color, _BaseColor.a);
            }
            ENDHLSL
        }
        
        // Shadow Caster Pass (for casting shadows)
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back
            
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
    
    CustomEditor "ToonShaderGUI"
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}
