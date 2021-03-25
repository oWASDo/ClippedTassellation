
Shader "Custom/ClipTessallated"
{

	// The properties block of the Unity shader. In this example this block is empty
	// because the output color is predefined in the fragment shader code.
	Properties
	{
		_Tess("Tessellation", Range(1, 64)) = 20
		_MaxTessDistance("Max Tess Distance", Range(1, 32)) = 20
		_Noise("Noise", 2D) = "gray" {}
		_Channel("Channel to sample", Range(1, 4)) = 1
		_Weight("Displacement Amount", Range(0, 5)) = 0
		CubeScalee("CubeScale", Vector) = (0,0,0)
		//CurveInverseTransformmm("CurveInverseTransform", Vector) = (0,0,0)



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




		sampler2D _Noise;
		float _Weight;
		int _Channel;
		float4 CubeScalee;
		uniform float4x4 CurveInverseTransformmm;
		//fixed _ClipBoxSide;


		// pre tesselation vertex program
			ControlPoint TessellationVertexProgram(Attributes v)
			{
				ControlPoint p;

				p.vertex = v.vertex;
				p.uv = v.uv;
				p.normal = v.normal;
				p.color = v.color;

				return p;
			}

			// after tesselation
			Varyings vert(Attributes input)
			{
				Varyings output;
				float Noise = 0.0;
				if (_Channel == 1)
					{
						Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)).r;

					}
				else if (_Channel == 2)
					{
						Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)).g;

					}
				else if (_Channel == 3)
					{
						Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)).b;

					}
				else
					{
						Noise = tex2Dlod(_Noise, float4(input.uv, 0, 0)).a;

					}

				input.vertex.xyz += (input.normal) * Noise * _Weight;
				//output.pos = float4(UnityObjectToClipPos(input.vertex.xyz), 0.0);
				output.pos = mul(unity_ObjectToWorld, input.vertex);
				//output.pos = input.vertex;
				
				output.vertex = TransformObjectToHClip(input.vertex.xyz);
				output.color = input.color;
				output.normal = input.normal;
				output.uv = input.uv;
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

			inline float PointVsBox(float3 worldPosition, float3 boxSize, float4x4 boxInverseTransform)
			{
				float3 distance = abs(mul(boxInverseTransform, float4(worldPosition, 1.0))) - boxSize;
				return length(max(distance, 0.0)) + min(max(distance.x, max(distance.y, distance.z)), 0.0);
			}

			// The fragment shader definition.            
			float4 frag(Varyings IN) : SV_Target
			{
				float4 tex = tex2D(_Noise, IN.uv);

				float primitiveDistance = 1.0;

				primitiveDistance = min(primitiveDistance, PointVsBox(IN.pos.xyz, CubeScalee.xyz, CurveInverseTransformmm) * 1.0);


				if (primitiveDistance <= 0.0)
				{
					discard;
				}

				
				return tex;
			}
			ENDHLSL
		}
	}
}

