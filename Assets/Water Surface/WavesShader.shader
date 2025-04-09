Shader "Custom/WavesShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        //Normal map
        _NormalMap ("Normal Map", 2D) = "bump" {}
        //Direção
        _Direction ("Direction", Vector) = (1.0, 0, 0, 1.0)
        //Inclinação
        _Steepness ("Stepness", Range(0.1, 1.0)) = 0.5
        //Frequência
        _Freq ("Frequency", Range(1.0, 10.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NormalMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Propriedades das ondas
        float4 _Direction;
        float _Steepness, _Freq;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v){
            float3 pos = v.vertex.xyz;
            float4 dir = normalize(_Direction);
            float defaultWavelenght = 2 * UNITY_PI;
            float wl = defaultWavelenght / _Freq;
            float phase = sqrt(9.8 / wl);

            float disp = wl * ((dot(dir, pos)) - (phase * _Time.y));

            //Implementação do deslocamento dos vértices
            float peak = _Steepness/wl;
            pos.x += dir.x * (peak * cos(disp));
            pos.y += peak * sin(disp);
            pos.z += dir.z * (peak * cos(disp));
            // atualiza as posições dos vértices para que a 
            // onda seja gerada
            v.vertex.xyz = pos;
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
