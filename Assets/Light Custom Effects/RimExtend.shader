Shader "Custom/RimExtend"
{
    Properties
    {
        //_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map (RGB)", 2D) = "bump" {}
        _RimColor ("Rim Colo", Color) = (1.0, 1.0, 1.0, 0.0)
        //_RimConcentration ("Rim Concentration",Range(0.5, 5.0))
        _RimStrength("Rim Strength",Range(1.0, 4.0)) = 1.45
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }


        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;
        float4 _RimColor;
        float _RimConcentration;
        float _RimStrength;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            //float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            float Lc = saturate (dot(normalize(IN.viewDir), o.Normal))
            half rim = 1.0 - Lc;
        
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap))
            o.Albedo = c.rgb;
            o.Alpha = c.a;
           // o.Emission = _RimColor.rgb * pow(rim, _RimConcentration);
           o.Emission = _RimStrength.rgb * (_RimColor.rgb * smoothstep(0.2, 0.6, rim));

        }
        ENDCG
    }
    FallBack "Diffuse"
}
