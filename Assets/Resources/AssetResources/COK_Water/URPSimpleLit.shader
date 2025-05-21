Shader "Custom/URPSimpleLit"
{
    Properties
    {
        		_Tess("Tessellation", Range(1, 32)) = 20
		_MaxTessDistance("Max Tess Distance", Range(1, 32)) = 20
		_Noise("Noise", 2D) = "gray" {}

	_Weight("Displacement Amount", Range(0, 2)) = 0

		[HDR] _LowColor("Low Water Color", Color) = (1,1,1,1)
		[HDR] _HighColor("High Water Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType" = "Opaque"
        }


        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }


            HLSLPROGRAM
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #pragma require tessellation
		    // This line defines the name of the vertex shader. 
            #pragma vertex TessellationVertexProgram
		    // This line defines the name of the fragment shader. 
            #pragma fragment frag
		    // This line defines the name of the hull shader. 
            #pragma hull hull
		    // This line defines the name of the domain shader. 
            #pragma domain domain

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "CustomTessellation.hlsl"


            float4 _LowColor;
	        float4 _HighColor;
		    sampler2D _Noise;
	        float _Weight;

            	// pre tesselation vertex program
	        ControlPoint TessellationVertexProgram(Attributes v)
	        {
		        ControlPoint p;

		        p.vertex = v.vertex;
		        p.uv = v.uv;
		        p.normal = v.normal;
		        p.color = v.color;
                p.worldPos = v.worldPos;

		        return p;
	        }


            Varyings vert (Attributes v)
            {
                Varyings o;

                float Noise = tex2Dlod(_Noise, float4(v.uv + _Time.x, 0, 0)).b;
		        float NoiseSmaller = tex2Dlod(_Noise, float4(v.uv * 2 + _Time.x, 0, 0)).b;
		        float combinedNoise = (Noise + NoiseSmaller) * 0.5;

		        v.vertex.xyz += (v.normal) *  combinedNoise * _Weight;

                o.vertex = TransformObjectToHClip(v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                o.normal = v.normal;
                return o;
            }

            
	        [UNITY_domain("tri")]
	        Varyings domain(TessellationFactors factors, OutputPatch<ControlPoint, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
	        {
		        Attributes v;

        #define DomainPos(fieldName) v.fieldName = \
				        patch[0].fieldName * barycentricCoordinates.x + \
				        patch[1].fieldName * barycentricCoordinates.y + \
				        patch[2].fieldName * barycentricCoordinates.z;

			        DomainPos(vertex)
			        DomainPos(uv)
			        DomainPos(color)
			        DomainPos(normal)
                    DomainPos(worldPos)

			        return vert(v);
	        }

            float3 Lambert(float3 lightColor, float3 lightDir, float3 normal)
            {
                float NdotL = saturate(dot(normal, lightDir));
                return lightColor * NdotL;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float Noise = tex2D(_Noise, float4(i.uv + _Time.x, 0, 0)).b;
		        float NoiseSmaller = tex2D(_Noise, float4(i.uv * 2 + _Time.x, 0, 0)).b;
		        float combinedNoise = (Noise + NoiseSmaller) * 0.5;

		        combinedNoise = saturate(combinedNoise);

		        float4 lerpedColor = lerp(_HighColor, _LowColor, combinedNoise);

                float3 lightPos = _MainLightPosition.xyz;
                float3 lightCol = Lambert(_MainLightColor * unity_LightData.z, lightPos, i.normal);

                uint lightsCount = GetAdditionalLightsCount();
                for (int j = 0; j < lightsCount; j++)
                {
                    Light light = GetAdditionalLight(j, i.worldPos);
                    lightCol += Lambert(light.color * (light.distanceAttenuation * light.shadowAttenuation), light.direction, i.normal);
                }

     

                lerpedColor.rgb += lightCol;

                return lerpedColor;
            }
            ENDHLSL
        }
    }
}
