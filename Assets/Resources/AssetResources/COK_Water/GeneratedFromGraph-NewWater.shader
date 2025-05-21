Shader "Shader Graphs/NewWater"
{
    Properties
    {
        _WaveStrength("WaveStrength", Float) = 0
        [HDR]_LowWaterColor("LowWaterColor", Color) = (0, 0.8215718, 1, 1)
        [NoScaleOffset]_WaveTex("WaveTex", 2D) = "white" {}
        [HDR]_HighWaterColor("HighWaterColor", Color) = (1, 1, 1, 1)
        _WaveDirection("WaveDirection", Vector) = (0, 0, 0, 0)
        _WaveSpeed("WaveSpeed", Float) = 0.1
        _Size("Size", Vector) = (0, 0, 0, 0)
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_760b58afca034330900df30be437ce2e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HighWaterColor) : _HighWaterColor;
            float4 _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_LowWaterColor) : _LowWaterColor;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            float4 _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2) );
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_R_4_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.r;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_G_5_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.g;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.b;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_A_7_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.a;
            float4 _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4;
            Unity_Lerp_float4(_Property_760b58afca034330900df30be437ce2e_Out_0_Vector4, _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4, (_SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float.xxxx), _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4);
            surface.BaseColor = (_Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_760b58afca034330900df30be437ce2e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HighWaterColor) : _HighWaterColor;
            float4 _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_LowWaterColor) : _LowWaterColor;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            float4 _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2) );
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_R_4_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.r;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_G_5_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.g;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.b;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_A_7_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.a;
            float4 _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4;
            Unity_Lerp_float4(_Property_760b58afca034330900df30be437ce2e_Out_0_Vector4, _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4, (_SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float.xxxx), _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4);
            surface.BaseColor = (_Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.NormalTS = IN.TangentSpaceNormal;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_760b58afca034330900df30be437ce2e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HighWaterColor) : _HighWaterColor;
            float4 _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_LowWaterColor) : _LowWaterColor;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            float4 _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2) );
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_R_4_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.r;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_G_5_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.g;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.b;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_A_7_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.a;
            float4 _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4;
            Unity_Lerp_float4(_Property_760b58afca034330900df30be437ce2e_Out_0_Vector4, _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4, (_SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float.xxxx), _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4);
            surface.BaseColor = (_Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _WaveStrength;
        float4 _LowWaterColor;
        float4 _WaveTex_TexelSize;
        float4 _HighWaterColor;
        float2 _WaveDirection;
        float _WaveSpeed;
        float2 _Size;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_WaveTex);
        SAMPLER(sampler_WaveTex);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4 = SAMPLE_TEXTURE2D_LOD(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2), 0);
            #endif
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_R_5_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.r;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_G_6_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.g;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.b;
            float _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_A_8_Float = _SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_RGBA_0_Vector4.a;
            float _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float = _WaveStrength;
            float _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float;
            Unity_Multiply_float_float(_SampleTexture2DLOD_b31b8067277b4795bd12eb303a006d79_B_7_Float, _Property_105a3d479a17467ca9ec511ada425ac5_Out_0_Float, _Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float);
            float _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float;
            Unity_Negate_float(_Multiply_8dd9a0f91de7427ca678b3f9ea567f8b_Out_2_Float, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float);
            float3 _Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3 = float3(0, _Negate_fc27bd49ce28444cb768a9a7a62a8a49_Out_1_Float, 0);
            float3 _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            Unity_Add_float3(_Vector3_fd23c63ad1f9439382ac002e5388b272_Out_0_Vector3, IN.ObjectSpacePosition, _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3);
            description.Position = _Add_6a292f1c71ad4bc6816f1680d5904fe8_Out_2_Vector3;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_760b58afca034330900df30be437ce2e_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_HighWaterColor) : _HighWaterColor;
            float4 _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_LowWaterColor) : _LowWaterColor;
            UnityTexture2D _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_WaveTex);
            float2 _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2 = _Size;
            float _Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float = _WaveSpeed;
            float2 _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2 = _WaveDirection;
            float2 _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2;
            Unity_Multiply_float2_float2((_Property_c4f35b07ec9e4123addfc6ef06c3c1c6_Out_0_Float.xx), _Property_d4cea6afbeb6435f928cf4285768e74a_Out_0_Vector2, _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2);
            float2 _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2;
            Unity_Multiply_float2_float2((IN.TimeParameters.x.xx), _Multiply_ae8b0d9601e9439bbbe8bbe03a6bd287_Out_2_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2);
            float2 _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_077c706921a244ef8daede88c9644a24_Out_0_Vector2, _Multiply_d2f05114b80d4ffea404f0a9713ac8e4_Out_2_Vector2, _TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2);
            float4 _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.tex, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.samplerstate, _Property_422ce8b57e8444d78a3ad9ee611aa558_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_fcf55787d6304c22b81a71050bc44f8e_Out_3_Vector2) );
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_R_4_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.r;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_G_5_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.g;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.b;
            float _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_A_7_Float = _SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_RGBA_0_Vector4.a;
            float4 _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4;
            Unity_Lerp_float4(_Property_760b58afca034330900df30be437ce2e_Out_0_Vector4, _Property_b1a1a2abe6d047d5b8c70d88bd81f58a_Out_0_Vector4, (_SampleTexture2D_dbeac5c632af45f79c618886dcb262ef_B_6_Float.xxxx), _Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4);
            surface.BaseColor = (_Lerp_cef1a06cfac1419586d8c2439ecb9177_Out_3_Vector4.xyz);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.uv0 =                                        input.uv0;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}