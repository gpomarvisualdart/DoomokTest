// This shader adds tessellation in URP
Shader "Example/URPUnlitShaderTessallated"
{

	// The properties block of the Unity shader. In this example this block is empty
	// because the output color is predefined in the fragment shader code.
	Properties
	{
		_Tess("Tessellation", Range(1, 32)) = 20
		_MaxTessDistance("Max Tess Distance", Range(1, 32)) = 20
		_Noise("Noise", 2D) = "gray" {}
		_Noise2("Noise2", 2D) = "gray" {}
		_WaveSize("Wave Size", Float) = 1
		_WaveSpeed1("Wave Speed 1", Float) = 1
		_WaveSpeed2("Wave Speed 2", Float) = 1
	
	_Weight("Displacement Amount", Range(0, 2)) = 0

		[HDR] _LowColor("Low Water Color", Color) = (1,1,1,1)
		[HDR] _HighColor("High Water Color", Color) = (1,1,1,1)
	}

		// The SubShader block containing the Shader code. 
		SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

		Pass
	{
		Tags{ "LightMode" = "UniversalForward" }


		// The HLSL code block. Unity SRP uses the HLSL language.
		HLSLPROGRAM
		// The Core.hlsl file contains definitions of frequently used HLSL
		// macros and functions, and also contains #include references to other
		// HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"    
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"    
#include "CustomTessellation.hlsl"

#pragma require tessellation
		// This line defines the name of the vertex shader. 
#pragma vertex TessellationVertexProgram
		// This line defines the name of the fragment shader. 
#pragma fragment frag
		// This line defines the name of the hull shader. 
#pragma hull hull
		// This line defines the name of the domain shader. 
#pragma domain domain

	float4 _LowColor;
	float4 _HighColor;


		sampler2D _Noise;
		sampler2D _Noise2;
	float _Weight;
	float _WaveSize;
	float _WaveSpeed1;
	float _WaveSpeed2;


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

	// after tesselation
	Varyings vert(Attributes input)
	{
		Varyings output;
		float Noise = tex2Dlod(_Noise, float4(input.uv * _WaveSize+ _Time.x * _WaveSpeed1, 0, 0)).b;
		float NoiseSmaller = tex2Dlod(_Noise2, float4(input.uv * 2 * _WaveSize + _Time.x * _WaveSpeed2, 0, 0)).b;
		float combinedNoise = (Noise + NoiseSmaller) * 0.5;

		input.vertex.xyz += (input.normal) * -1 * combinedNoise * _Weight;
		output.vertex = TransformObjectToHClip(input.vertex.xyz);
		output.color = input.color;
		output.normal = input.normal;
		output.uv = input.uv;

		output.worldPos = TransformObjectToWorld(input.vertex.xyz);

		return output;
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

			return vert(v);

	}

	            float3 Lambert(float3 lightColor, float3 lightDir, float3 normal)
            {
                float NdotL = saturate(dot(normal, lightDir));
                return lightColor * NdotL;
            }


	// The fragment shader definition.            
	half4 frag(Varyings IN) : SV_Target
	{
		float4 Noise = tex2D(_Noise, float4(IN.uv * _WaveSize+ _Time.x * _WaveSpeed1 , 0, 0)).b;
		float4 NoiseSmaller = tex2D(_Noise2, float4(IN.uv * 2 *_WaveSize+ _Time.x * _WaveSpeed2, 0, 0)).b;
		float4 combinedNoise = (Noise + NoiseSmaller) * 0.5;

		combinedNoise = saturate(combinedNoise);		

		float4 lerpedColor = lerp(_HighColor, _LowColor, combinedNoise);
			
		float3 lightPos = _MainLightPosition.xyz;
        float3 lightCol = Lambert(_MainLightColor * unity_LightData.z, lightPos, IN.normal);

        uint lightsCount = GetAdditionalLightsCount();
        for (int j = 0; j < lightsCount; j++)
        {
            Light light = GetAdditionalLight(j, IN.worldPos);
            lightCol += Lambert(light.color * (light.distanceAttenuation * light.shadowAttenuation), light.direction, IN.normal);
        }
		lerpedColor.rgb += lightCol;

		
		return lerpedColor;
	}
		ENDHLSL
	}
	}
}