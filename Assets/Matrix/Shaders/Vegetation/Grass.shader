// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grass"
{
	Properties
	{
		_Symbols("Symbols", 2D) = "black" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		[HideInInspector]_null("null", 2D) = "bump" {}
		_Masks("Masks", 2D) = "white" {}
		_WindUVScale("WindUVScale", Float) = 0.5
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_WindNoiseScale("WindNoiseScale", Float) = 0.5
		_WindUVPower("WindUVPower", Float) = 0
		_WindUVPanner("WindUVPanner", Vector) = (0,0,0,0)
		_WindNoiseUVPanner("WindNoiseUVPanner", Vector) = (0,0,0,0)
		_WindNoisePower("WindNoisePower", Float) = 0
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		_ThicknessPower("ThicknessPower", Float) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float eyeDepth;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform sampler2D _Masks;
		uniform float2 _WindUVPanner;
		uniform float _WindUVScale;
		uniform float _WindUVPower;
		uniform float _WindNoisePower;
		uniform float2 _WindNoiseUVPanner;
		uniform float _WindNoiseScale;
		uniform sampler2D _MatrixMask;
		uniform float4 _MatrixMask_ST;
		

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _null;
		uniform float4 _null_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _SymbolsColor;
		uniform sampler2D _Symbols;
		uniform float4 _Symbols_ST;
		uniform float4 _SpecularColor;
		uniform float _Smoothness;
		uniform float4 _Masks_ST;
		uniform float _ThicknessPower;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult76 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 panner80 = ( 1.0 * _Time.y * _WindUVPanner + ( appendResult76 * _WindUVScale ));
			float temp_output_23_0 = ( tex2Dlod( _Masks, float4( panner80, 0, 0.0) ).r * _WindUVPower );
			float3 appendResult39 = (float3(temp_output_23_0 , 0.0 , temp_output_23_0));
			float2 panner61 = ( 1.0 * _Time.y * _WindNoiseUVPanner + ( appendResult76 * _WindNoiseScale ));
			float4 tex2DNode55 = tex2Dlod( _Masks, float4( panner61, 0, 0.0) );
			float3 appendResult94 = (float3(tex2DNode55.b , tex2DNode55.b , tex2DNode55.b));
			float3 lerpResult67 = lerp( float3( 0,0,0 ) , mul( float4( ( appendResult39 + ( _WindNoisePower * appendResult94 * _SinTime.z ) ) , 0.0 ), unity_ObjectToWorld ).xyz , v.color.r);
			float2 uv_MatrixMask = v.texcoord * _MatrixMask_ST.xy + _MatrixMask_ST.zw;
			float clampResult136 = clamp( ( tex2Dlod( _MatrixMask, float4( uv_MatrixMask, 0, 0.0) ).r + _Matrix ) , 0.0 , 1.0 );
			//float Mask101 = clampResult136;
			float3 lerpResult112 = lerp( lerpResult67 , float3( 0,0,0 ) , Mask101);
			v.vertex.xyz += lerpResult112;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + d;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float2 uv_null = i.uv_texcoord * _null_ST.xy + _null_ST.zw;
			float2 uv_MatrixMask = i.uv_texcoord * _MatrixMask_ST.xy + _MatrixMask_ST.zw;
			float clampResult136 = clamp( ( tex2D( _MatrixMask, uv_MatrixMask ).r + _Matrix ) , 0.0 , 1.0 );
			float Mask101 = clampResult136;
			float3 lerpResult103 = lerp( UnpackNormal( tex2D( _Normal, uv_Normal ) ) , UnpackNormal( tex2D( _null, uv_null ) ) , Mask101);
			o.Normal = lerpResult103;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			float4 lerpResult102 = lerp( tex2DNode1 , float4( 0,0,0,0 ) , Mask101);
			o.Albedo = lerpResult102.rgb;
			float2 uv_Symbols = i.uv_texcoord * _Symbols_ST.xy + _Symbols_ST.zw;
			float cameraDepthFade123 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 40.0);
			float clampResult130 = clamp( ( 1.0 - cameraDepthFade123 ) , 0.0 , 1.0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV128 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode128 = ( 0.0 + 0.01 * pow( 1.0 - fresnelNdotV128, 3.0 ) );
			float clampResult133 = clamp( fresnelNode128 , 0.0 , 1.0 );
			float4 lerpResult119 = lerp( float4( 0,0,0,0 ) , ( ( _SymbolsColor * tex2D( _Symbols, uv_Symbols ).r * clampResult130 ) + clampResult133 ) , Mask101);
			o.Emission = lerpResult119.rgb;
			float4 lerpResult106 = lerp( _SpecularColor , float4( 0,0,0,0 ) , Mask101);
			o.Specular = lerpResult106.rgb;
			float lerpResult109 = lerp( _Smoothness , 0.0 , Mask101);
			o.Smoothness = lerpResult109;
			float2 uv_Masks = i.uv_texcoord * _Masks_ST.xy + _Masks_ST.zw;
			float lerpResult111 = lerp( pow( tex2D( _Masks, uv_Masks ).g , _ThicknessPower ) , 0.0 , Mask101);
			float3 temp_cast_3 = (lerpResult111).xxx;
			o.Transmission = temp_cast_3;
			o.Alpha = 1;
			clip( tex2DNode1.a - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecularCustom keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecularCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecularCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
-1913;7;1906;1004;1403.978;329.9314;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;75;-3168.565,720.3649;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;77;-2898.785,897.7565;Float;False;Property;_WindUVScale;WindUVScale;5;0;Create;True;0;0;False;0;0.5;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;76;-2873.082,741.7092;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2800.958,1273.686;Float;False;Property;_WindNoiseScale;WindNoiseScale;7;0;Create;True;0;0;False;0;0.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2529.459,1116.787;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2627.285,740.8566;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;78;-2635.577,856.2526;Float;False;Property;_WindUVPanner;WindUVPanner;9;0;Create;True;0;0;False;0;0,0;0.1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;59;-2537.751,1232.182;Float;False;Property;_WindNoiseUVPanner;WindNoiseUVPanner;10;0;Create;True;0;0;False;0;0,0;0.1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;80;-2395.978,739.5527;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;61;-2298.15,1115.482;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-2129.298,42.42662;Inherit;False;Constant;_CameraDepth;CameraDepth;19;0;Create;True;0;0;False;0;40;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2051.627,1087.979;Inherit;True;Property;_Noise2;Noise2;4;0;Create;True;0;0;False;0;-1;None;542d7ff83dda1df4486385f0718b2c50;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;81;-2089.493,712.3041;Inherit;True;Property;_Masks;Masks;4;0;Create;True;0;0;False;0;-1;None;542d7ff83dda1df4486385f0718b2c50;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-1992.871,928.4495;Float;False;Property;_WindUVPower;WindUVPower;8;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1733.323,986.7676;Float;False;Property;_WindNoisePower;WindNoisePower;12;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;95;-1694.732,1257.959;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1695.879,738.7125;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;-2234.172,-789.15;Inherit;True;Global;_MatrixMask;_MatrixMask;11;0;Create;True;0;0;False;0;-1;None;dfc0a75b18c63c34abf5bd6c5cea8c49;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;100;-2144.774,-569.5157;Inherit;False;Global;_Matrix;_Matrix;20;0;Create;True;0;0;False;0;0;-1.000296;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1691.404,1113.683;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CameraDepthFade;123;-1916.452,24.5565;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1736.262,153.6485;Inherit;False;Constant;_FrScale;FrScale;16;0;Create;True;0;0;False;0;0.01;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-1457.614,741.678;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;-1884.62,-172.1198;Inherit;True;Property;_Symbols;Symbols;0;0;Create;True;0;0;False;0;None;973d6773a15339e42b198b6fb965ed77;False;black;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1465.585,993.7062;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1719.67,245.3087;Inherit;False;Constant;_FrPower;FrPower;15;0;Create;True;0;0;False;0;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;126;-1611.682,24.4199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-1805.332,-676.344;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;128;-1490.89,157.2661;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;-1466.766,-344.2812;Inherit;False;Global;_SymbolsColor;_SymbolsColor;2;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1.223529,6.65098,1.098039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;131;-1551.815,-170.9306;Inherit;True;Property;_TextureSample0;Texture Sample 0;21;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;130;-1406.608,25.8444;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;136;-1587.011,-675.955;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1208.944,741.3135;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;31;-1195.006,896.9044;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VertexColorNode;66;-879.0132,879.7902;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;133;-1117.108,-5.255595;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-884.5684,743.2932;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-1114.371,-147.0697;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-1326.622,-681.7197;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-998.5283,643.2325;Float;False;Property;_ThicknessPower;ThicknessPower;14;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1087.827,433.7665;Inherit;True;Property;_Thickness;Thickness;4;0;Create;True;0;0;False;0;-1;5bdbe53dce2414e458937234dce49479;5bdbe53dce2414e458937234dce49479;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;-879.3188,281.4362;Float;False;Property;_Smoothness;Smoothness;15;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;71;-668.4171,482.393;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-670.9423,-268.0589;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-607.6891,864.933;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-932.3864,-583.4583;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;-1;9a1568052101f2f48ba76e7342adc3f3;9a1568052101f2f48ba76e7342adc3f3;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;104;-749.6738,-671.5133;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-690.5096,366.4633;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;70;-943.6363,67.29522;Float;False;Property;_SpecularColor;SpecularColor;13;0;Create;True;0;0;False;0;1,1,1,0;0.4317999,0.5377356,0.3576449,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;107;-710.1577,159.316;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-676.6428,627.957;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-872.7843,-873.267;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;-1;9bf68c6e5059e7549b60e91ca11987a6;9bf68c6e5059e7549b60e91ca11987a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;120;-973.5934,-379.8937;Inherit;True;Property;_null;null;3;1;[HideInInspector];Create;True;0;0;False;0;-1;9a1568052101f2f48ba76e7342adc3f3;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;117;-759.7475,-20.64246;Inherit;False;101;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;67;-624.4774,721.5583;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-847.3746,-146.7585;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;106;-478.1577,72.316;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;112;-347.6893,719.933;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;119;-476.875,-170.2808;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;103;-430.1371,-395.6061;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;109;-458.5099,285.4633;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;111;-416.6427,482.9571;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;102;-382.7281,-595.696;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;8;35.79775,6.563354;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Grass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;76;0;75;1
WireConnection;76;1;75;3
WireConnection;60;0;76;0
WireConnection;60;1;58;0
WireConnection;79;0;76;0
WireConnection;79;1;77;0
WireConnection;80;0;79;0
WireConnection;80;2;78;0
WireConnection;61;0;60;0
WireConnection;61;2;59;0
WireConnection;55;1;61;0
WireConnection;81;1;80;0
WireConnection;23;0;81;1
WireConnection;23;1;24;0
WireConnection;94;0;55;3
WireConnection;94;1;55;3
WireConnection;94;2;55;3
WireConnection;123;0;122;0
WireConnection;39;0;23;0
WireConnection;39;2;23;0
WireConnection;64;0;65;0
WireConnection;64;1;94;0
WireConnection;64;2;95;3
WireConnection;126;0;123;0
WireConnection;135;0;137;1
WireConnection;135;1;100;0
WireConnection;128;2;124;0
WireConnection;128;3;125;0
WireConnection;131;0;127;0
WireConnection;130;0;126;0
WireConnection;136;0;135;0
WireConnection;93;0;39;0
WireConnection;93;1;64;0
WireConnection;133;0;128;0
WireConnection;32;0;93;0
WireConnection;32;1;31;0
WireConnection;132;0;129;0
WireConnection;132;1;131;1
WireConnection;132;2;130;0
WireConnection;101;0;136;0
WireConnection;71;0;4;2
WireConnection;71;1;72;0
WireConnection;67;1;32;0
WireConnection;67;2;66;1
WireConnection;134;0;132;0
WireConnection;134;1;133;0
WireConnection;106;0;70;0
WireConnection;106;2;107;0
WireConnection;112;0;67;0
WireConnection;112;2;113;0
WireConnection;119;1;134;0
WireConnection;119;2;117;0
WireConnection;103;0;3;0
WireConnection;103;1;120;0
WireConnection;103;2;105;0
WireConnection;109;0;99;0
WireConnection;109;2;108;0
WireConnection;111;0;71;0
WireConnection;111;2;110;0
WireConnection;102;0;1;0
WireConnection;102;2;104;0
WireConnection;8;0;102;0
WireConnection;8;1;103;0
WireConnection;8;2;119;0
WireConnection;8;3;106;0
WireConnection;8;4;109;0
WireConnection;8;6;111;0
WireConnection;8;10;1;4
WireConnection;8;11;112;0
ASEEND*/
//CHKSM=4A8DD893CBBD01C9869D88FF768D689A14EB4EAB