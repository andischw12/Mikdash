// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Symbolsparticle"
{
	Properties
	{
		_Mask("Mask", 2D) = "white" {}
		_Symbol("Symbol", 2D) = "white" {}
		_MaskPower("MaskPower", Float) = 0
		_SymbolsPower("SymbolsPower", Float) = 0
		[HDR]_EmissionColor("EmissionColor", Color) = (0,0,0,0)
		[Toggle(_USEGLOBAL_ON)] _UseGlobal("UseGlobal", Float) = 0
		_CameraDepthFadeLenght("CameraDepthFadeLenght", Float) = 40
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _USEGLOBAL_ON
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float eyeDepth;
		};

		uniform float4 _EmissionColor;
		uniform sampler2D _Symbol;
		uniform float4 _Symbol_ST;
		uniform float _SymbolsPower;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _MaskPower;
		uniform sampler2D _MatrixMask;
		uniform float4 _MatrixMask_ST;
		uniform float _Matrix;
		uniform float _CameraDepthFadeLenght;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Symbol = i.uv_texcoord * _Symbol_ST.xy + _Symbol_ST.zw;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float temp_output_7_0 = ( pow( tex2D( _Symbol, uv_Symbol ).r , _SymbolsPower ) * pow( tex2D( _Mask, uv_Mask ).r , _MaskPower ) );
			o.Emission = ( _EmissionColor * temp_output_7_0 ).rgb;
			float2 uv_MatrixMask = i.uv_texcoord * _MatrixMask_ST.xy + _MatrixMask_ST.zw;
			float clampResult15 = clamp( ( tex2D( _MatrixMask, uv_MatrixMask ).r + _Matrix ) , 0.0 , 1.0 );
			float Mask16 = clampResult15;
			#ifdef _USEGLOBAL_ON
				float staticSwitch18 = Mask16;
			#else
				float staticSwitch18 = 1.0;
			#endif
			float cameraDepthFade20 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / _CameraDepthFadeLenght);
			float clampResult23 = clamp( ( 1.0 - cameraDepthFade20 ) , 0.0 , 1.0 );
			o.Alpha = ( temp_output_7_0 * i.vertexColor.a * staticSwitch18 * clampResult23 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				half4 color : COLOR0;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.vertexColor = IN.color;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
-1913;7;1906;1004;2166.679;58.64655;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;12;-998.5229,-359.7814;Inherit;False;Global;_Matrix;_Matrix;7;0;Create;True;0;0;False;0;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-1081.308,-568.3874;Inherit;True;Global;_MatrixMask;_MatrixMask;3;0;Create;True;0;0;False;0;-1;None;dfc0a75b18c63c34abf5bd6c5cea8c49;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-672.2032,-458.3554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1490.032,589.4003;Inherit;False;Property;_CameraDepthFadeLenght;CameraDepthFadeLenght;6;0;Create;True;0;0;False;0;40;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-453.8826,-457.9665;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1304.988,169.3338;Inherit;True;Property;_Mask;Mask;0;0;Create;True;0;0;False;0;-1;ec6ab63eee9aab64a958e39cbc33301a;ec6ab63eee9aab64a958e39cbc33301a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1310.742,-141.454;Inherit;True;Property;_Symbol;Symbol;1;0;Create;True;0;0;False;0;-1;None;98a1c1c91b9516d4dbe9d701909a8b31;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-1204.234,66.6667;Inherit;False;Property;_SymbolsPower;SymbolsPower;3;0;Create;True;0;0;False;0;0;0.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-204.4429,-462.6163;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1179.253,369.6436;Inherit;False;Property;_MaskPower;MaskPower;2;0;Create;True;0;0;False;0;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;20;-1143.603,572.5008;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;6;-882.2341,-29.3333;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;5;-875.2527,249.6436;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-865.4353,370.12;Inherit;False;Constant;_Const;Const;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-891.6953,445.8483;Inherit;False;16;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-819.0885,572.6854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;-568.0144,572.1099;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-637.8888,-80.5665;Inherit;False;Property;_EmissionColor;EmissionColor;4;1;[HDR];Create;True;0;0;False;0;0,0,0,0;7.906699,1.69725,1.69725,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-574.3527,115.9703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;18;-655.6953,421.8483;Inherit;False;Property;_UseGlobal;UseGlobal;5;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;11;-603.8888,237.4335;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-312.8888,155.4335;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-307.8888,19.4335;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;38,-29;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Custom/Symbolsparticle;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;13;1
WireConnection;14;1;12;0
WireConnection;15;0;14;0
WireConnection;16;0;15;0
WireConnection;20;0;21;0
WireConnection;6;0;3;1
WireConnection;6;1;2;0
WireConnection;5;0;1;1
WireConnection;5;1;4;0
WireConnection;22;0;20;0
WireConnection;23;0;22;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;18;1;19;0
WireConnection;18;0;17;0
WireConnection;10;0;7;0
WireConnection;10;1;11;4
WireConnection;10;2;18;0
WireConnection;10;3;23;0
WireConnection;8;0;9;0
WireConnection;8;1;7;0
WireConnection;0;2;8;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=6D96FE129FDB579491C15C6464C98009A259AA64