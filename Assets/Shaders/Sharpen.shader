Shader "Custom/Sharpen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _mX ("Mouse X",Float) = 0
        _mY ("Mouse Y", Float) = 0
    }
    SubShader
    { 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            //set variables to use from properties 
            sampler2D _MainTex; //Textures
            float4 _MainTex_ST;
            uniform float4 _MainTex_TexelSize; //special value
            uniform float _mY; //X Mouse Position
            uniform float _mX; //Y Mouse Position

            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) //setting uv to the texture
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {

                //create a pixel from texture, mY changes the lookup
                float2 texel = float2(
                    _MainTex_TexelSize.x * (_mY * .1f), 
                    _MainTex_TexelSize.y * (_mY * .1f)
                );
                
                // kernel using emboss matrix values
                float3x3 G = float3x3( -2, -1, 0, -1, 1, 1, 0, 1, 2 ); 

                
                // fetch the 3x3 neighborhood of a fragment
                float tx0y0 = tex2D( _MainTex, i.uv + texel * float2( -1, -1 ) ).rgb;
                float tx0y1 = tex2D( _MainTex, i.uv + texel * float2( -1,  0 ) ).rgb;
                float tx0y2 = tex2D( _MainTex, i.uv + texel * float2( -1,  1 ) ).rgb;

                float tx1y0 = tex2D( _MainTex, i.uv + texel * float2(  0, -1 ) ).rgb;
                float tx1y1 = tex2D( _MainTex, i.uv + texel * float2(  0,  0 ) ).rgb;
                float tx1y2 = tex2D( _MainTex, i.uv + texel * float2(  0,  1 ) ).rgb;

                float tx2y0 = tex2D( _MainTex, i.uv + texel * float2(  1, -1 ) ).rgb;
                float tx2y1 = tex2D( _MainTex, i.uv + texel * float2(  1,  0 ) ).rgb;
                float tx2y2 = tex2D( _MainTex, i.uv + texel * float2(  1,  1 ) ).rgb;

                //multiple each kernel and find the sum to create the new pixel color
                float valueG = G[0][0] * tx0y0 + G[1][0] * tx1y0 + G[2][0] * tx2y0 + 
                        G[0][1] * tx0y1 + G[1][1] * tx1y1 + G[2][1] * tx2y1 + 
                        G[0][2] * tx0y2 + G[1][2] * tx1y2 + G[2][2] * tx2y2;

                //set the color of each channel of the pixel
                float4 edgePix = float4( float3( valueG,valueG,valueG), 1.0);

                //set the texture
                float4 texPix = tex2D(_MainTex, i.uv);

                //interpolate between emboss and default texture through the position of mouse
                float4 edgeCol = lerp(texPix, edgePix, (_mX/_ScreenParams.x)); 
                
                return edgeCol;    
            }
            ENDCG
        }
    }
}
