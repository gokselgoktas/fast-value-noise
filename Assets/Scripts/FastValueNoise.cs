using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FastValueNoise : MonoBehaviour
{
    private Shader m_Shader;
    private Shader shader
    {
        get
        {
            if (m_Shader == null)
                m_Shader = Shader.Find("Hidden/Fast Value Noise");

            return m_Shader;
        }
    }

    private Material m_Material;
    private Material material
    {
        get
        {
            if (m_Material == null)
            {
                if (shader == null || !shader.isSupported)
                    return null;

                m_Material = new Material(shader);
            }

            return m_Material;
        }
    }

    public Texture2D m_LookupTexture;
    private Texture2D lookupTexture
    {
        get
        {
            if (m_LookupTexture == null)
            {
                m_LookupTexture = new Texture2D(256, 256, TextureFormat.RGBAFloat, false);
                m_LookupTexture.name = "Lookup";
                m_LookupTexture.wrapMode = TextureWrapMode.Repeat;

                for (int i = 0; i < m_LookupTexture.height; ++i)
                {
                    for (int k = 0; k < m_LookupTexture.width; ++k)
                    {
                        Color color = new Color(Random.value, 0f, 0f, 0f);
                        m_LookupTexture.SetPixel(k, i, color);
                    }
                }

                for (int i = 0; i < m_LookupTexture.height; ++i)
                {
                    for (int k = 0; k < m_LookupTexture.width; ++k)
                    {
                        Color color = m_LookupTexture.GetPixel(k, i);
                        color.g = m_LookupTexture.GetPixel(k + 37, i + 17).r;
                        color.b = m_LookupTexture.GetPixel(k + 59, i + 83).r;
                        color.a = m_LookupTexture.GetPixel(k + 96, i + 100).r;

                        m_LookupTexture.SetPixel(k, i, color);
                    }
                }

                m_LookupTexture.Apply();
            }

            return m_LookupTexture;
        }
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetTexture("_LookupTexture", lookupTexture);
        Graphics.Blit(source, destination, material);
    }
}
