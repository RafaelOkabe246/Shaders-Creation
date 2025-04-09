Shader "Custom/TransparentShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        //Normal map
        _Normal ("Normal", 2D) = "bump" {}

        //Propriedade para reflexo do ambiente
        _EnvMap ("Environment Map", CUBE) = "" {}

        //Opacidade
        _Opacity ("Opacity", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType" = "Transparent" "IgnoreProjection" = "True"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        //Normal map
        sampler2D _Normal;
        //Cube map
        sampler2D _EnvMap;

        struct Input
        {
            float2 uv_MainTex;
            // Uv da normal map
            float2 uv_Normal;

            //Obtém o reflexo do vetor
            float3 worldRefl;
            INTERNAL_DATA
        };

        half _Glossiness;
        half _Metallic;
        half _Opacity; //Referencia para opacidade
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            //Reduz o valor pela metade (* 0.5) para deixar a reflexão menos intensa
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * 0.5 * _Color;
            float3 n = tex2D (_Normal, IN.uv_Normal);
            o.Albedo = c.rgb;

            // Cálculos do reflexo e distorção escrevendo no emission
            o.Emission = texCUBE(_EnvMap, IN.worldRefl * n).rgb;

            //Cálculo da normal map
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a * _Opacity; //Multiplica o canal alpha pela opacidade
        }
        ENDCG
    }
    FallBack "Diffuse"
}
