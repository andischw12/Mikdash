// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Terrain"
{
	Properties
	{
		_Symbols("Symbols", 2D) = "white" {}
		_terrain_grass_01_a("terrain_grass_01_a", 2D) = "white" {}
		_terrain_grass_01_n("terrain_grass_01_n", 2D) = "bump" {}
		_terrain_grass_01_sg("terrain_grass_01_sg", 2D) = "white" {}
		_terrain_01_o("terrain_01_o", 2D) = "white" {}
		_terrain_mudslide_01_a("terrain_mudslide_01_a", 2D) = "white" {}
		_terrain_mudslide_01_sg("terrain_mudslide_01_sg", 2D) = "bump" {}
		_terrain_mudslide_01_n("terrain_mudslide_01_n", 2D) = "white" {}
		_terrain_01_n("terrain_01_n", 2D) = "bump" {}
		_null("null", 2D) = "bump" {}
		_NormalScale("NormalScale", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _terrain_grass_01_n;
		uniform float4 _terrain_grass_01_n_ST;
		uniform sampler2D _terrain_mudslide_01_sg;
		uniform float4 _terrain_mudslide_01_sg_ST;
		uniform sampler2D _terrain_01_o;
		uniform float4 _terrain_01_o_ST;
		uniform float _NormalScale;
		uniform sampler2D _terrain_01_n;
		uniform float4 _terrain_01_n_ST;
		uniform sampler2D _null;
		uniform float4 _null_ST;
		uniform sampler2D _MatrixMask;
		uniform float4 _MatrixMask_ST;
		uniform float _Matrix;
		uniform sampler2D _terrain_grass_01_a;
		uniform float4 _terrain_grass_01_a_ST;
		uniform sampler2D _terrain_mudslide_01_a;
		uniform float4 _terrain_mudslide_01_a_ST;
		uniform float4 _SymbolsColor;
		uniform sampler2D _Symbols;
		uniform float4 _Symbols_ST;
		uniform sampler2D _terrain_grass_01_sg;
		uniform float4 _terrain_grass_01_sg_ST;
		uniform sampler2D _terrain_mudslide_01_n;
		uniform float4 _terrain_mudslide_01_n_ST;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_terrain_grass_01_n = i.uv_texcoord * _terrain_grass_01_n_ST.xy + _terrain_grass_01_n_ST.zw;
			float2 uv_terrain_mudslide_01_sg = i.uv_texcoord * _terrain_mudslide_01_sg_ST.xy + _terrain_mudslide_01_sg_ST.zw;
			float2 uv_terrain_01_o = i.uv_texcoord * _terrain_01_o_ST.xy + _terrain_01_o_ST.zw;
			float temp_output_15_0 = ( 1.0 - tex2D( _terrain_01_o, uv_terrain_01_o ).r );
			float3 lerpResult13 = lerp( UnpackNormal( tex2D( _terrain_grass_01_n, uv_terrain_grass_01_n ) ) , UnpackNormal( tex2D( _terrain_mudslide_01_sg, uv_terrain_mudslide_01_sg ) ) , temp_output_15_0);
			float2 uv_terrain_01_n = i.uv_texcoord * _terrain_01_n_ST.xy + _terrain_01_n_ST.zw;
			float2 uv_null = i.uv_texcoord * _null_ST.xy + _null_ST.zw;
			float2 uv_MatrixMask = i.uv_texcoord * _MatrixMask_ST.xy + _MatrixMask_ST.zw;
			float clampResult40 = clamp( ( tex2D( _MatrixMask, uv_MatrixMask ).r + _Matrix ) , 0.0 , 1.0 );
			float Mask29 = clampResult40;
			float3 lerpResult34 = lerp( BlendNormals( lerpResult13 , UnpackScaleNormal( tex2D( _terrain_01_n, uv_terrain_01_n ), _NormalScale ) ) , UnpackNormal( tex2D( _null, uv_null ) ) , Mask29);
			o.Normal = lerpResult34;
			float2 uv_terrain_grass_01_a = i.uv_texcoord * _terrain_grass_01_a_ST.xy + _terrain_grass_01_a_ST.zw;
			float2 uv_terrain_mudslide_01_a = i.uv_texcoord * _terrain_mudslide_01_a_ST.xy + _terrain_mudslide_01_a_ST.zw;
			float4 lerpResult12 = lerp( tex2D( _terrain_grass_01_a, uv_terrain_grass_01_a ) , tex2D( _terrain_mudslide_01_a, uv_terrain_mudslide_01_a ) , temp_output_15_0);
			float4 lerpResult35 = lerp( lerpResult12 , float4( 0,0,0,0 ) , Mask29);
			o.Albedo = lerpResult35.rgb;
			float2 uv_Symbols = i.uv_texcoord * _Symbols_ST.xy + _Symbols_ST.zw;
			float4 lerpResult27 = lerp( float4( 0,0,0,0 ) , ( _SymbolsColor * tex2D( _Symbols, uv_Symbols ).r ) , Mask29);
			o.Emission = lerpResult27.rgb;
			float2 uv_terrain_grass_01_sg = i.uv_texcoord * _terrain_grass_01_sg_ST.xy + _terrain_grass_01_sg_ST.zw;
			float4 tex2DNode7 = tex2D( _terrain_grass_01_sg, uv_terrain_grass_01_sg );
			float2 uv_terrain_mudslide_01_n = i.uv_texcoord * _terrain_mudslide_01_n_ST.xy + _terrain_mudslide_01_n_ST.zw;
			float4 lerpResult14 = lerp( tex2DNode7 , tex2D( _terrain_mudslide_01_n, uv_terrain_mudslide_01_n ) , temp_output_15_0);
			float4 lerpResult32 = lerp( lerpResult14 , float4( 0,0,0,0 ) , Mask29);
			o.Specular = lerpResult32.rgb;
			float lerpResult16 = lerp( tex2DNode7.a , 0.0 , temp_output_15_0);
			float lerpResult33 = lerp( lerpResult16 , 0.0 , Mask29);
			o.Smoothness = lerpResult33;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
-1913;7;1906;1004;3095.034;1351.615;1.468434;True;False
Node;AmplifyShaderEditor.SamplerNode;30;-2293.226,-809.022;Inherit;True;Global;_MatrixMask;_MatrixMask;10;0;Create;True;0;0;False;0;-1;None;aaacb0e66f4b9ef40ad41b5e268e4ee3;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-2199.916,-575.3264;Inherit;False;Global;_Matrix;_Matrix;13;0;Create;True;0;0;False;0;0;1.00065;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-1851.767,-664.5818;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1819.978,-46.28401;Inherit;True;Property;_terrain_01_o;terrain_01_o;4;0;Create;True;0;0;False;0;-1;7b895c7902f0f4f43908aba30ba6c079;7b895c7902f0f4f43908aba30ba6c079;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-1111.499,-445.1333;Inherit;True;Property;_terrain_grass_01_n;terrain_grass_01_n;2;0;Create;True;0;0;False;0;-1;84956715d52a7f040a6a341dfd449801;84956715d52a7f040a6a341dfd449801;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1186.144,-259.9042;Inherit;True;Property;_terrain_mudslide_01_sg;terrain_mudslide_01_sg;6;0;Create;True;0;0;False;0;-1;3d2140ec449eb0049bc3eb51c3a7cf7b;527b74b713b11c54b8b3ee728b61cd6f;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;40;-1633.446,-664.1928;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-1474.142,-19.76277;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-1314.707,154.6775;Inherit;True;Property;_Symbols;Symbols;0;0;Create;True;0;0;False;0;None;973d6773a15339e42b198b6fb965ed77;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-974.7631,-98.10114;Inherit;False;Property;_NormalScale;NormalScale;10;0;Create;True;0;0;False;0;0;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-749.658,-195.779;Inherit;True;Property;_terrain_01_n;terrain_01_n;8;0;Create;True;0;0;False;0;-1;e0a154ce4939e8e4c82784703d1a9221;e0a154ce4939e8e4c82784703d1a9221;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-890.643,575.5329;Inherit;True;Property;_terrain_mudslide_01_n;terrain_mudslide_01_n;7;0;Create;True;0;0;False;0;-1;527b74b713b11c54b8b3ee728b61cd6f;3d2140ec449eb0049bc3eb51c3a7cf7b;True;0;True;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;13;-616.5066,-322.1798;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;9;-710.2245,-599.7704;Inherit;True;Property;_terrain_mudslide_01_a;terrain_mudslide_01_a;5;0;Create;True;0;0;False;0;-1;afbd2772cfa009b46bbd9838dd988440;afbd2772cfa009b46bbd9838dd988440;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;38;-943.1443,-10.2431;Inherit;False;Global;_SymbolsColor;_SymbolsColor;2;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1.223529,6.65098,1.098039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;26;-1028.008,154.8775;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;20;-955.407,523.3002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;19;-984.9331,707.1368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-924.6575,339.1198;Inherit;True;Property;_terrain_grass_01_sg;terrain_grass_01_sg;3;0;Create;True;0;0;False;0;-1;592277751c386d34fa5609a321b5618e;592277751c386d34fa5609a321b5618e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-1365.597,-668.3077;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-668.6902,-797.3597;Inherit;True;Property;_terrain_grass_01_a;terrain_grass_01_a;1;0;Create;True;0;0;False;0;-1;7379bd0702051604e95990811452abc6;7379bd0702051604e95990811452abc6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;21;-1180.545,-452.3283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;12;-284.701,-435.6461;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;-262.4684,599.3486;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;18;-349.6516,-240.8165;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;14;-294.051,341.3207;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-427.0096,178.8866;Inherit;False;29;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-430.2997,-115.5892;Inherit;True;Property;_null;null;9;0;Create;True;0;0;False;0;-1;e0a154ce4939e8e4c82784703d1a9221;e0a154ce4939e8e4c82784703d1a9221;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-614.8218,73.63986;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;33;59.15894,490.0561;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;35;81.071,-281.5571;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;32;48.20285,252.1551;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;34;9.074624,-100.001;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;27;-56.68291,49.56924;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;340.3375,1.162498;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;39;0;30;1
WireConnection;39;1;28;0
WireConnection;40;0;39;0
WireConnection;15;0;8;1
WireConnection;17;5;37;0
WireConnection;13;0;6;0
WireConnection;13;1;10;0
WireConnection;13;2;15;0
WireConnection;26;0;24;0
WireConnection;20;0;15;0
WireConnection;19;0;15;0
WireConnection;29;0;40;0
WireConnection;21;0;15;0
WireConnection;12;0;5;0
WireConnection;12;1;9;0
WireConnection;12;2;21;0
WireConnection;16;0;7;4
WireConnection;16;2;19;0
WireConnection;18;0;13;0
WireConnection;18;1;17;0
WireConnection;14;0;7;0
WireConnection;14;1;11;0
WireConnection;14;2;20;0
WireConnection;23;0;38;0
WireConnection;23;1;26;1
WireConnection;33;0;16;0
WireConnection;33;2;31;0
WireConnection;35;0;12;0
WireConnection;35;2;31;0
WireConnection;32;0;14;0
WireConnection;32;2;31;0
WireConnection;34;0;18;0
WireConnection;34;1;36;0
WireConnection;34;2;31;0
WireConnection;27;1;23;0
WireConnection;27;2;31;0
WireConnection;0;0;35;0
WireConnection;0;1;34;0
WireConnection;0;2;27;0
WireConnection;0;3;32;0
WireConnection;0;4;33;0
ASEEND*/
//CHKSM=622F5ECBC850FC3F397B74A7E2BA9E6CB06DE662