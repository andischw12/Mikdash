using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatrixControl : MonoBehaviour
{
    public Texture2D noise;

    [ColorUsage(true, true)]
    public Color symbolsColor; 

    bool activate;

    private void Start()
    {
        Shader.SetGlobalFloat("_Matrix", -1);
       
    }

    void Update()
    {
 
            if (Input.GetKeyDown(KeyCode.E))
        {
            if (Shader.GetGlobalFloat("_MainTex") <= -1)


                activate = true;
            else
                activate = false;
        }

        if (activate && Shader.GetGlobalFloat("_Matrix") < 1)
        {
            Shader.SetGlobalColor("_SymbolsColor", symbolsColor);
            Shader.SetGlobalTexture("_MatrixMask", noise);
            Shader.SetGlobalFloat("_Matrix", Shader.GetGlobalFloat("_Matrix") + Time.deltaTime);
            
           
        }
        if (activate == false && Shader.GetGlobalFloat("_Matrix") > -1)
        {
            Shader.SetGlobalFloat("_Matrix", Shader.GetGlobalFloat("_Matrix") - Time.deltaTime);
        }
    
    }
}
